#
# Cookbook Name:: cloudstack
# Provider:: api_keys
# Author:: Pierre-Luc Dion (<pdion@cloudops.com>)
# Copyright:: Copyright (c) 2014 CloudOps.com
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Generate api keys for specified CloudStack user.


require 'uri'
require 'net/http'
require 'json'
include Cloudstack

# Support whyrun
def whyrun_supported?
  true
end

#########
# ACTIONS
#########

action :create do
  wait_count = 0
  until cloudstack_api_is_running? or wait_count == 5 do
    cloudstack_api_is_running?
    sleep(5)
    wait_count +=1
    if wait_count == 1
      Chef::Log.info 'Waiting CloudStack to start'
    end
  end

  if cloudstack_api_is_running?
    # bypass the section if CloudStack is not running.
    if (!@current_resource.admin_apikey.nil? or !@current_resource.admin_secretkey.nil?) and !Chef::Config[:solo]
      # if keys attributes are empty search in Chef environment for other node having API-KEYS.
      other_nodes = search(:node, "chef_environment:#{node.chef_environment} AND cloudstack_admin_api_key:* NOT name:#{node.name}")
      unless other_nodes.empty?
        @current_resource.admin_apikey(other_nodes.first['cloudstack']['admin']['api_key'])
        @current_resource.admin_secretkey(other_nodes.first['cloudstack']['admin']['secret_key'])
      end

      if keys_valid?
        # API-KEYS from other nodes are valids, so updating current node attributes.
        #@current_resource.exists = true
        Chef::Log.info 'api keys: found valid keys from another node in the environment.'
        Chef::Log.info 'api keys: updating node attributes'
        node.normal['cloudstack']['admin']['api_key'] = @current_resource.admin_apikey
        node.normal['cloudstack']['admin']['secret_key'] = @current_resource.admin_secretkey
        node.save unless Chef::Config[:solo]
      end
    elsif keys_valid?
      # test API-KEYS on cloudstack, if they work, skip the section.
      @current_resource.exists = true
      Chef::Log.info 'api keys: are valid, nothing to do.'
    else
      if @current_resource.username == 'admin'
        admin_keys = retrieve_admin_keys(@current_resource.url, @current_resource.password)
        if admin_keys[:api_key].nil?
          converge_by('Creating api keys for admin') do
            admin_keys = generate_admin_keys(@current_resource.url, @current_resource.password)
            Chef::Log.info 'admin api keys: Generate new'
          end
        else
          Chef::Log.info 'admin api keys: use existing'
        end
        #puts admin_keys
        node.normal['cloudstack']['admin']['api_key'] = admin_keys[:api_key]
        node.normal['cloudstack']['admin']['secret_key'] = admin_keys[:secret_key]
        node.save unless Chef::Config[:solo]
        $admin_apikey = admin_keys[:api_key]
        $admin_secretkey = admin_keys[:secret_key]
        Chef::Log.info "$admin_apikey = #{$admin_apikey}"
      end
    end
  else
    Chef::Log.error 'CloudStack not running, cannot generate API keys.'
  end
end

action :reset do
  # force generate new API keys
  #load_current_resource
  if cloudstack_is_running?
    if @current_resource.username == 'admin'
      converge_by('Reseting admin api keys') do
        admin_keys = generate_admin_keys(@current_resource.url, @current_resource.password)
        Chef::Log.info 'admin api keys: Generate new'
        node.normal['cloudstack']['admin']['api_key'] = admin_keys[:api_key]
        node.normal['cloudstack']['admin']['secret_key'] = admin_keys[:secret_key]
        node.save unless Chef::Config[:solo]
        $admin_apikey = admin_keys[:api_key]
        $admin_secretkey = admin_keys[:secret_key]
      end
    end
  else
    Chef::Log.error 'CloudStack not running, cannot generate API keys.'
  end

  puts $admin_apikey
end


def generate_admin_keys(url='http://localhost:8080/client/api', password='password')
  login_params = {:command => 'login', :username => 'admin', :password => password, :response => 'json'}
  # create sessionkey and cookie of the api session initiated with username and password
  uri = URI(url)
  uri.query = URI.encode_www_form(login_params)
  http = Net::HTTP.new(uri.hostname, uri.port)
  res = http.get(uri.request_uri)
  get_keys_params = {
      :sessionkey => JSON.parse(res.body)['loginresponse']['sessionkey'],
      :command => 'registerUserKeys',
      :response => 'json',
      :id => '2'
  }

  # use sessionkey + cookie to generate admin API and SECRET keys.
  uri2 = URI(url)
  uri2.query = URI.encode_www_form(get_keys_params)
  sleep(2) # add some delay to have the session working 
  query_for_keys = http.get(uri2.request_uri, {'Cookie' => res.response['set-cookie'].split('; ')[0]})

  if users.code == '200'
    keys = {
        :api_key => JSON.parse(query_for_keys.body)['registeruserkeysresponse']['userkeys']['apikey'],
        :secret_key => JSON.parse(query_for_keys.body)['registeruserkeysresponse']['userkeys']['secretkey']
    }
  else
    Chef::Log.info "Error creating keys errorcode: #{users.code}"
  end
  return keys
end


def keys_valid?
  # Test if current defined keys from Chef are valid
  #
  if @current_resource.admin_apikey.nil? or @current_resource.admin_secretkey.nil?
    return false
  else
    # return false if one key is empty
    require 'cloudstack_ruby_client'
    begin
      client = CloudstackRubyClient::Client.new(@current_resource.url, @current_resource.admin_apikey, @current_resource.admin_secretkey, @current_resource.ssl)
      list_apis = client.list_apis
    rescue
      return false
    end
    if list_apis.nil?
      return false
    else
      return true
    end
  end
end


def retrieve_admin_keys(url='http://localhost:8080/client/api', password='password')
  login_params = {:command => 'login', :username => 'admin', :password => password, :response => 'json'}
  # create sessionkey and cookie of the api session initiated with username and password
  uri = URI(url)
  uri.query = URI.encode_www_form(login_params)
  http = Net::HTTP.new(uri.hostname, uri.port)
  res = http.get(uri.request_uri)
  get_keys_params = {
      :sessionkey => JSON.parse(res.body)['loginresponse']['sessionkey'],
      :command => 'listUsers',
      :response => 'json',
      :id => '2'
  }
  # use sessionkey + cookie to generate admin API and SECRET keys.
  uri2 = URI(url)
  uri2.query = URI.encode_www_form(get_keys_params)
  sleep(2) # add some delay to have the session working 
  users = http.get(uri2.request_uri, {'Cookie' => res.response['set-cookie'].split('; ')[0]})
  if users.code == '200'
    keys = {
        :api_key => JSON.parse(users.body)['listusersresponse']['user'].first['apikey'],
        :secret_key => JSON.parse(users.body)['listusersresponse']['user'].first['secretkey']
    }
  else
    Chef::Log.info "Error creating keys errorcode: #{users.code}"
  end
  return keys
end


def load_current_resource
  @current_resource = Chef::Resource::CloudstackApiKeys.new(@new_resource.name)
  @current_resource.username(@new_resource.name)
  @current_resource.password(@new_resource.password)
  @current_resource.url(@new_resource.url)
  @current_resource.admin_apikey(@new_resource.admin_apikey)
  @current_resource.admin_secretkey(@new_resource.admin_secretkey)
  @current_resource.ssl(@new_resource.ssl)

  #if keys_valid?
  #  @current_resource.exists = true
  #end
  #if @current_resource.username == "admin" and  node["cloudstack"]["admin"]["api_key"] == retrieve_admin_keys(@current_resource.url, @current_resource.password)[:api_key]
  #  @current_resource.exists = true
  #end

end
