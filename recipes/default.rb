# Cookbook Name:: netdata
# Recipe:: default
#
# Copyright 2016, Abiquo
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

case node['platform_family'] 
when 'rhel', 'redhat', 'centos', 'amazon', 'scientific', 'oracle' 
	node.default['yum']['epel-testing']['enabled'] = true
	node.default['yum']['epel-testing']['managed'] = true
	include_recipe 'yum-epel'
when 'ubuntu','debian'
	true
else
	raise("Unsupported platform family")
end

include_recipe "netdata::install_netdata"
