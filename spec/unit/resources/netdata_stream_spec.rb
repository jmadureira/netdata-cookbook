# Cookbook:: netdata
# Specs:: netdata_config
#
# Copyright:: 2017, Nick Willever
# Copyright:: 2017,2018, Serge A. Salamanka
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

describe_resource 'netdata_spec::stream' do
  describe 'create' do
    cached(:run_list) { 'netdata_spec::stream' }
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(step_into: ['netdata_stream']).converge(run_list)
    end

    it 'configures netdata_stream subsection: stream' do
      expect(chef_run).to create_netdata_stream('stream')
        .with(configurations: { 'enabled' => 'yes', 'destination' => 'netdata_master:19999', 'api key' => '11111111-2222-3333-4444-555555555555' })
    end

    it 'configures netdata_stream subsection: api_key' do
      expect(chef_run).to create_netdata_stream('11111111-2222-3333-4444-555555555555')
        .with(configurations: { 'enabled' => 'yes' })
    end

    cached(:template) { chef_run.template('/etc/netdata/stream.conf') }

    it 'creates file /etc/netdata/stream.conf' do
      expect(chef_run).to create_template('/etc/netdata/stream.conf')
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
