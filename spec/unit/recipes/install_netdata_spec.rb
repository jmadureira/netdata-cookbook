# Cookbook Name:: netdata
# Specs:: install_netdata_spec
#
# Copyright 2016, Abiquo
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

require 'spec_helper'

describe 'netdata::install_netdata' do
  context 'Ubuntu' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'ubuntu', version: 16.04) do |node|
        node.override['netdata']['plugins']['python']['mysql']['enabled'] = true
      end.converge(described_recipe)
    end
    it 'installs the python mysql package for NetData mysql plugin' do
      expect(chef_run).to install_package('python_mysql').with(package_name: 'python-mysqldb')
    end
    it 'installs NetData from source with default options' do
      expect(chef_run).to install_netdata_install('default')
    end
    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end

describe 'netdata::install_netdata' do
  context 'CentOS' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'centos', version: 6.7) do |node|
        node.override['netdata']['plugins']['python']['mysql']['enabled'] = true
      end.converge(described_recipe)
    end
    it 'installs the python mysql package for NetData mysql plugin' do
      expect(chef_run).to install_package('python_mysql').with(package_name: 'MySQL-python')
    end
    it 'installs NetData from source with default options' do
      expect(chef_run).to install_netdata_install('default')
    end
    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end

describe 'netdata::install_netdata' do
  context 'Unsupported' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'windows', version: 10) do |node|
        node.override['netdata']['plugins']['python']['mysql']['enabled'] = true
      end.converge(described_recipe)
    end
    cached(:chef_run_only_recipe) { ChefSpec::SoloRunner.new().converge(described_recipe) }
    it 'raises an error' do
      # to cover netdata_install resource without stepping into it:
      expect(chef_run_only_recipe).to install_netdata_install('default')
      # to catch raise exception:
      expect { chef_run }.to raise_error(RuntimeError)
    end
  end
end
