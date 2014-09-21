# Cookbook Name:: cloudstack
# Recipe:: kvm_agent
# Author:: Pierre-Luc Dion (<pdion@cloudops.com>)
# Copyright 2013, Roeland Kuipers
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
# Install cloudstack-agent required on KVM hosts

include_recipe 'cloudstack::repo'

package 'cloudstack-agent' do
  action :install
end

service 'cloudstack-agent' do
  supports :status => true, :restart => true
  action [:enable, :start]
end