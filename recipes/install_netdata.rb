# Cookbook Name:: netdata
# Recipe:: install_netdata
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
  runtime_dependencies = %w(zlib-devel libuuid-devel libmnl-devel gcc make git autoconf autogen automake pkgconfig)
  if node['netdata']['plugins']['python']['mysql']['enabled']
    runtime_dependencies << 'MySQL-python'
  end
  runtime_dependencies.each do |pkg|
    package pkg do
      action :install
    end
  end

  git node['netdata']['source']['directory'] do
    repository node['netdata']['source']['git_repository']
    reference node['netdata']['source']['git_revision']
    action :sync
    notifies :run, 'execute[install]', :immediately
  end

  execute 'install' do
    cwd node['netdata']['source']['directory']
    command "#{node['netdata']['source']['directory']}/netdata-installer.sh --zlib-is-really-here --dont-wait"
    action :nothing
  end
when 'ubuntu', 'debian'
  runtime_dependencies = %w(zlib1g-dev uuid-dev libmnl-dev gcc make git autoconf autogen automake pkg-config)
  if node['netdata']['plugins']['python']['mysql']['enabled']
    runtime_dependencies << 'python-mysqldb'
  end
  runtime_dependencies.each do |pkg|
    package pkg do
      action :install
    end
  end

  git node['netdata']['source']['directory'] do
    repository node['netdata']['source']['git_repository']
    reference node['netdata']['source']['git_revision']
    action :sync
    notifies :run, 'execute[install]', :immediately
  end

  execute 'install' do
    cwd node['netdata']['source']['directory']
    command "#{node['netdata']['source']['directory']}/netdata-installer.sh --zlib-is-really-here --dont-wait"
    action :nothing
  end
else
  raise 'Unsupported platform family'
end

# Update the netdata.conf if there's any configuration to include
template "/etc/netdata/netdata.conf" do
  source "netdata.conf.erb"
  mode 0664
  owner node['netdata']['user']
  group node['netdata']['group']
  notifies :restart, "service[netdata]", :delayed
  only_if { node['netdata']['conf'].any? }
end

service 'netdata' do
  supports restart: true
  action :nothing
end
