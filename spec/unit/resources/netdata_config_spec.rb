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

describe_resource 'netdata_spec::config' do
  describe 'create' do
    cached(:run_list) { 'netdata_spec::config' }
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['netdata_config']).converge(run_list)
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

    cached(:template) { chef_run.template('/etc/netdata/netdata.conf') }

    it 'creates file /etc/netdata/netdata.conf' do
      expect(chef_run).to create_template('/etc/netdata/netdata.conf')
    end

    it 'restarts netdata service' do
      expect(template).to notify('service[netdata]').to(:restart).delayed
      service = chef_run.service('netdata')
      expect(service).to do_nothing
      # expect(chef_run).to nothing_service('netdata')
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
