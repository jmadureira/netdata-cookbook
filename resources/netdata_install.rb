# Cookbook Name:: netdata
# Resources:: netdata_install
#
# Copyright 2017, Nick Willever
# Copyright 2018, Serge A. Salamanka
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

property :install_method, kind_of: String, default: 'source'
property :binary_repository, kind_of: String, default: 'https://raw.githubusercontent.com/firehol/binary-packages/master'
property :binary_package, kind_of: String, default: 'netdata-latest.gz.run'
property :binary_install_options, Array, default: ['--accept']
property :binary_post_install_options, Array, default: []
property :git_repository, kind_of: String,
                          default: 'https://github.com/firehol/netdata.git'
property :git_revision, kind_of: String, default: 'master'
property :git_source_directory, kind_of: String, default: '/tmp/netdata'
property :install_path, kind_of: String, default: ''
property :autoupdate, kind_of: [TrueClass, FalseClass], default: false
property :update, kind_of: [TrueClass, FalseClass], default: false

include NetdataInstall::Helper

action :install do
  case new_resource.install_method
  when 'source'

    if new_resource.git_source_directory == '/tmp/netdata'
      Chef::Log.warn 'Use of the default value for `git_source_directory` ' \
                'is now deprecated and will be removed in a future release. ' \
                'The path `/opt/netdata.git` should be used instead.'
    end

    unless node['netdata'].empty?
      Chef::Log.warn "Use of `node['netdata']` attributes is now deprecated " \
              'and will be removed in a future release. ' \
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
      only_if { update || !netdata_installed? }
    end

    service 'netdata' do
      supports status: true, restart: true, reload: true
      action [:start, :enable]
    end

  when 'binary'
    unless %w(amd64 x86_64).include?(node['kernel']['machine'])
      raise "Static binary versions of netdata are available only for 64bit Intel/AMD CPUs (x86_64), but yours is: #{node['kernel']['machine']}."
    end

    binary_package = new_resource.binary_package
    binary_repository = new_resource.binary_repository

    if binary_package == 'netdata-latest.gz.run'
      remote_file "#{Chef::Config[:file_cache_path]}/netdata_latest.txt" do
        source "#{binary_repository}/#{binary_package}"
        action :create
      end
      ruby_block 'set_netdata_binary_package' do
        block do
          node.run_state['NETDATA_BINARY_PACKAGE'] = ::File.read("#{Chef::Config[:file_cache_path]}/netdata_latest.txt")
        end
      end
      remote_file "#{Chef::Config[:file_cache_path]}/netdata-package.gz.run" do
        source lazy { "#{binary_repository}/#{::File.read("#{::Chef::Config[:file_cache_path]}/netdata_latest.txt")}" }
        action :create
        not_if { netdata_binary_package_installed? }
      end
      file "#{Chef::Config[:file_cache_path]}/netdata_latest.txt" do
        action :delete
      end
    else
      ruby_block 'set_netdata_binary_package' do
        block do
          node.run_state['NETDATA_BINARY_PACKAGE'] = binary_package
        end
      end
      remote_file "#{Chef::Config[:file_cache_path]}/netdata-package.gz.run" do
        source "#{binary_repository}/#{binary_package}"
        action :create
        not_if { netdata_binary_package_installed? }
      end
    end

    unless new_resource.binary_install_options.include?('--accept')
      Chef::Log.warn 'It is required to provide --accept option to the binary package installation script to accept the license' \
                     'otherwise automated installation will fail.'
    end

    binary_install_options = new_resource.binary_install_options.join(' ')
    binary_post_install_options =
      new_resource.binary_post_install_options.empty? ? ' ' : '--' + ' ' + new_resource.binary_post_install_options.join(' ')

    bash 'install_netdata_binary_package' do
      code <<-EOH
        sh #{Chef::Config[:file_cache_path]}/netdata-package.gz.run #{binary_install_options} #{binary_post_install_options}
      EOH
      notifies :create, 'file[/opt/netdata/version.txt]', :immediately
      notifies :restart, 'service[netdata]', :delayed
      not_if { netdata_binary_package_installed? }
    end

    file "#{Chef::Config[:file_cache_path]}/netdata-package.gz.run" do
      action :delete
    end

    file '/opt/netdata/version.txt' do
      content lazy { node.run_state['NETDATA_BINARY_PACKAGE'] }
      owner 'netdata'
      group 'netdata'
      action :nothing
    end

    service 'netdata' do
      supports status: true, restart: true, reload: true
      action [:start, :enable]
      not_if { new_resource.binary_install_options.include?('--noexec') }
      not_if { new_resource.binary_post_install_options.include?('--dont-start-it') }
    end

  else
    raise "Unsupported installation method requested: #{new_resource.install_method}. Supported: source or binary."
  end
end
