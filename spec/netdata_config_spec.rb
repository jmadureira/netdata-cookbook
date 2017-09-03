# Cookbook Name:: netdata
# Specs:: netdata_config
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

require 'spec_helper'

describe 'netdata_test::default' do
  context 'netdata_config custom configuration' do
    cached(:chef_run) do
      runner = ChefSpec::SoloRunner.new
      runner.converge(described_recipe)
    end

    it 'configures netdata_config subsection: global' do
      expect(chef_run).to create_netdata_config('global')
        .with(configurations: { 'log directory' => '/var/log/netdata', 'history' => 3996 })
    end

    it 'configures netdata_config subsection: web' do
      expect(chef_run).to create_netdata_config('web')
        .with(configurations: { 'bind to' => 'localhost' })
    end

    it 'configures netdata_config subsection: plugin:proc:/proc/meminfo' do
      expect(chef_run).to create_netdata_config('plugin:proc:/proc/meminfo')
        .with(configurations: { 'committed memory' => 'yes', 'writeback memory' => 'yes' })
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
