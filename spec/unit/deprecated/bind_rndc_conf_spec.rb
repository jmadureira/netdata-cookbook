# Cookbook Name:: netdata
# Specs:: bind_rdnc_conf_spec
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

describe 'netdata_test::default' do
  context 'bind_rndc custom configuration' do
    cached(:chef_run) do
      runner = ChefSpec::SoloRunner.new(step_into: %w(netdata_bind_rndc_conf netdata_python_plugin))
      runner.converge(described_recipe)
    end

    it 'configures bind_rndc' do
      expect(chef_run).to \
        configure_netdata_bind_rndc_module('default_bind_rndc_config')
        .with(named_stats_path: '/custom/path')
    end

    it 'uses netdata_python_plugin as the backend for bind_rndc' do
      expect(chef_run).to create_netdata_python_plugin('bind_rndc')
    end

    it 'creates bind_rndc python.d plugin configuration file' do
      expect(chef_run).to create_template('/etc/netdata/python.d/bind_rndc.conf')
    end

    it 'creates bind_rndc configuration file with custom path' do
      expect(chef_run).to render_file('/etc/netdata/python.d/bind_rndc.conf')
        .with_content('/custom/path')
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
