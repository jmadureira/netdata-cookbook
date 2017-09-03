# Cookbook Name:: netdata
# Resources:: netdata_install
#
# Copyright 2017, Nick Willever
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

resource_name :netdata_install

default_action :install

property :git_repository, kind_of: String,
                          default: 'https://github.com/firehol/netdata.git'
property :git_revision, kind_of: String, default: 'include-missing-assets'
property :git_source_directory, kind_of: String, default: '/tmp/netdata'
property :install_path, kind_of: String, default: ''
property :autoupdate, kind_of: [TrueClass, FalseClass], default: false

include NetdataInstall::Helper

action :install do
  if new_resource.git_source_directory == '/tmp/netdata'
    Chef::Log.warn 'Use of the default value for `git_source_directory` ' \
              'is now deprecated and will be removed in a future release.' \
              'The path `/opt/netdata.git` should be used instead.'
  end

  unless node['netdata'].empty?
    Chef::Log.warn "Use of `node['netdata']` attributes is now deprecated " \
            'and will be removed in a future release.' \
            '`netdata_install` resource should be used instead.'
  end

  case node['platform_family']
  when 'rhel', 'amazon'
    if node['platform_version'] =~ /^6/
      node.default['yum']['epel-testing']['enabled'] = true
      node.default['yum']['epel-testing']['managed'] = true
      include_recipe 'yum-epel'
    end
  when 'debian'
    include_recipe 'apt'
  end

  package 'compile_packages' do
    package_name compile_packages
    action :nothing
  end

  package 'plugin_packages' do
    package_name %w(git bash curl iproute python python-yaml)
  end

  git new_resource.git_source_directory do
    repository new_resource.git_repository
    reference new_resource.git_revision
    action :sync
  end

  execute 'install' do
    cwd new_resource.git_source_directory
    command <<-EOF
      ./netdata-installer.sh #{enable_autoupdate} #{custom_install_path} \
      --zlib-is-really-here --dont-wait --dont-start-it
    EOF
    notifies :install, 'package[compile_packages]', :before
    notifies :restart, 'service[netdata]', :delayed
    not_if { autoupdate_enabled_on_system? }
    not_if { netdata_installed? }
  end

  service 'netdata' do
    supports status: true, restart: true, reload: true
    action [:start, :enable]
  end
end
