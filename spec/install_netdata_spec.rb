# Cookbook Name:: netdata
# Specs:: install_netdata_spec
#
# Copyright 2016, Abiquo
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

require 'spec_helper'

shared_examples_for :install do
  it 'runs the netdata install custom resource' do
    expect(chef_run).to install_netdata_install('default')
  end

  it 'installs packages for NetData plugins' do
    expect(chef_run).to install_package('plugin_packages')
  end

  it 'checks out NetData git repository' do
    expect(chef_run).to sync_git('/tmp/netdata')
  end

  it 'installs the NetData service' do
    expect(chef_run).to run_execute('install')
  end

  it 'restarts NetData service on install' do
    resource = chef_run.execute('install')
    expect(resource).to notify('service[netdata]').to(:restart).delayed
  end

  it 'enables and starts the NetData service' do
    expect(chef_run).to start_service('netdata')
  end

  it 'converges successfully' do
    expect { chef_run }.to_not raise_error
  end
end

describe 'netdata::install_netdata' do
  context 'Ubuntu' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['netdata_install']) do |node|
        node.override['netdata']['plugins']['python']['mysql']['enabled'] = true
      end.converge(described_recipe)
    end

    it 'installs the python mysql package for NetData mysql plugin' do
      expect(chef_run).to install_package('python_mysql').with(package_name: 'python-mysqldb')
    end

    it 'installs compile packages' do
      expect(chef_run).to_not install_package('compile_packages')
        .with(package_name: %w(zlib-devel libuuid-devel libmnl-devel nc pkgconfig autoconf autogen automake gcc make))
    end

    it 'includes apt cookbook' do
      expect(chef_run).to include_recipe('apt')
    end

    it_behaves_like :install
  end
end

shared_examples_for :mysql_plugin do
  it 'installs the python mysql package for NetData mysql plugin' do
    expect(chef_run).to install_package('python_mysql').with(package_name: 'MySQL-python')
  end
end

describe 'netdata::install_netdata' do
  context 'CentOS' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'centos', version: 6.7,
        step_into: ['netdata_install']) do |node|
        node.override['netdata']['plugins']['python']['mysql']['enabled'] = true
      end.converge(described_recipe)
    end

    it 'installs compile packages' do
      expect(chef_run).to_not install_package('compile_packages')
        .with(package_name: %w(zlib-devel libuuid-devel libmnl-devel nc pkgconfig autoconf autogen automake gcc make))
    end

    it 'includes yum-epel cookbook' do
      expect(chef_run).to include_recipe('yum-epel')
    end

    it_behaves_like :install
    it_behaves_like :mysql_plugin
  end
end

describe 'netdata::install_netdata' do
  context 'Fedora' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'fedora', version: 25,
        step_into: ['netdata_install']) do |node|
        node.override['netdata']['plugins']['python']['mysql']['enabled'] = true
      end.converge(described_recipe)
    end

    it 'installs compile packages' do
      expect(chef_run).to_not install_package('compile_packages')
        .with(package_name: %w(zlib-devel
                               libuuid-devel libmnl-devel autoconf-archive pkgconfig nc findutils autoconf autogen automake gcc make))
    end

    it_behaves_like :install
    it_behaves_like :mysql_plugin
  end
end
