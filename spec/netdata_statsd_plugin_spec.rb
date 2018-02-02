# Cookbook Name:: netdata
# Specs:: netdata_statsd_plugin_spec
#
# Copyright 2018, Joao Madureira
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
  context 'netdata_statds_plugin custom app configuration' do
    cached(:chef_run) do
      runner = ChefSpec::SoloRunner.new(step_into: ['netdata_statsd_plugin'])
      runner.converge(described_recipe)
    end

    it 'configures netdata_statds_plugin' do
      expect(chef_run).to create_netdata_statsd_plugin('test_app')
        .with(app_configuration: { 'metrics' => 'app.*' },
              charts: { 'mem' => { 'name' => 'heap', 'title' => 'Heap Memory', 'dimension' => 'app.memory.heap.used used last 1 1000000' } })
    end

    it 'creates test_app statsd.d plugin configuration file' do
      expect(chef_run).to create_template('/etc/netdata/statsd.d/test_app.conf')
    end

    it 'creates test_app statsd.d plugin file with custom charts' do
      expect(chef_run).to render_file('/etc/netdata/statsd.d/test_app.conf')
        .with_content(/\[mem\].*name\s=\sheap.*title\s=\sHeap Memory.*dimension = app.memory.heap.used used last 1 1000000.*/m)
    end

    it 'creates test_app statsd.d plugin with custom app configuration' do
      expect(chef_run).to render_file('/etc/netdata/statsd.d/test_app.conf')
        .with_content(/\[app\].*metrics\s=\sapp\.\*.*dimension = app.memory.heap.used used last 1 1000000.*/m)
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
