#
# Cookbook Name:: cloudstack
# Provider:: prefill_database
# Author:: Ian Duffy (<ian@ianduffy.ie>)
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
# prefill the database with custom values.
###############################################################################

# Support whyrun
def whyrun_supported?
  true
end

action :run do
  bash 'Prefilling database' do
    code "mysql -u#{ new_resource.user } -p#{ new_resource.password } -h #{ new_resource.ip } < #{new_resource.name}"
    only_if do
      ::File.exists?(new_resource.name)
    end
  end
end

def load_current_resource
  @current_resource = Chef::Resource::CloudstackPrefillDatabase.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.user(@new_resource.user)
  @current_resource.password(@new_resource.password)
  @current_resource.ip(@new_resource.ip)
end