# Cookbook Name:: cloudstack
# Attribute:: systemvm_template
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


# System VM templates
default['cloudstack']['cloud-install-sys-tmplt'] = "/usr/share/cloudstack-common/scripts/storage/secondary/cloud-install-sys-tmplt"

if node['cloudstack']['version'].empty?
    validate_version =  node['cloudstack']['release_major']
else 
    validate_version =  node['cloudstack']['version']
end
case validate_version
when "4.4"
    default['cloudstack']['hypervisor_tpl'] = {
        "xenserver" => "http://cloudstack.apt-get.eu/systemvm/4.4/systemvm64template-4.4.0-6-xen.vhd.bz2",
        "vmware" => "http://cloudstack.apt-get.eu/systemvm/4.4/systemvm64template-4.4.0-6-vmware.ova",
        "kvm" => "http://cloudstack.apt-get.eu/systemvm/4.4/systemvm64template-4.4.0-6-kvm.qcow2.bz2",
        "lxc" => "http://cloudstack.apt-get.eu/systemvm/4.4/systemvm64template-4.4.0-6-kvm.qcow2.bz2",
        "hyperv" => "http://cloudstack.apt-get.eu/systemvm/4.4/systemvm64template-4.4.0-6-hyperv.vhd"
    }
when "4.3" || "4.3.1"
    default['cloudstack']['hypervisor_tpl'] = {
        "xenserver" => "http://download.cloud.com/templates/4.3/systemvm64template-2014-06-23-master-xen.vhd.bz2",
        "vmware" => "http://download.cloud.com/templates/4.3/systemvm64template-2014-06-23-master-vmware.ova",
        "kvm" => "http://download.cloud.com/templates/4.3/systemvm64template-2014-06-23-master-kvm.qcow2.bz2",
        "lxc" => "http://download.cloud.com/templates/4.3/systemvm64template-2014-06-23-master-kvm.qcow2.bz2",
        "hyperv" => "http://download.cloud.com/templates/4.3/systemvm64template-2014-06-23-master-hyperv.vhd.bz2"
    }
when "4.2.0" || "4.2.1"
    default['cloudstack']['hypervisor_tpl'] = {
        "xenserver" => "http://d21ifhcun6b1t2.cloudfront.net/templates/4.2/systemvmtemplate-2013-07-12-master-xen.vhd.bz2",
        "vmware" => "http://d21ifhcun6b1t2.cloudfront.net/templates/4.2/systemvmtemplate-4.2-vh7.ova",
        "kvm" => "http://d21ifhcun6b1t2.cloudfront.net/templates/4.2/systemvmtemplate-2013-06-12-master-kvm.qcow2.bz2",
        "lxc" => "http://d21ifhcun6b1t2.cloudfront.net/templates/acton/acton-systemvm-02062012.qcow2.bz2"
    }
end