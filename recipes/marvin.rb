#
# Cookbook Name:: marvin
# Recipe:: default
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

chef_gem 'cloudstack_ruby_client' do
  action :nothing
end.run_action(:install)
Gem.clear_paths


include_recipe 'cloudstack::repo'

if platform?(%w{redhat centos fedora oracle})
  bash 'Install Development tools' do
    code <<-EOH
        yum groupinstall "Development tools" -y
    EOH
    not_if "yum grouplist installed | grep 'Development tools'"
  end
elsif platform?(%w{ubuntu debian})
  package 'build-essential'
end

package 'gmp-devel'
package 'python-pip'
package 'python-setuptools'
package 'python-devel'

python_pip 'cloudstack-marvin' do
  options "--allow-external mysql-connector-python"
end
