# Cookbook Name:: netdata
# Specs:: nginx_conf_spec
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
  context 'nginx_conf custom configuration' do
    cached(:chef_run) do
      runner = ChefSpec::SoloRunner.new(step_into: %w(netdata_nginx_conf netdata_python_plugin))
      runner.converge(described_recipe)
    end

    it 'configures nginx_conf' do
      expect(chef_run).to \
        configure_netdata_nginx_module('default_config')
        .with(jobs: {
                'localhost' => {
                  'name' => 'local',
                  'url' => 'http://localhost/stub_status',
                },
                'localipv4' => {
                  'name' => 'local',
                  'url' => 'http://127.0.0.1/stub_status',
                },
                'localipv6' => {
                  'name' => 'local',
                  'url' => 'http://::1/stub_status',
                },
              })
    end

    it 'uses netdata_python_plugin as the backend for nginx' do
      expect(chef_run).to create_netdata_python_plugin('nginx')
    end

    it 'creates nginx python.d plugin configuration file' do
      expect(chef_run).to create_template('/etc/netdata/python.d/nginx.conf')
    end

    it 'creates nginx configuration file with custom path' do
      expect(chef_run).to render_file('/etc/netdata/python.d/nginx.conf')
        .with_content { |content|
                            expect(content).to include('http://localhost/stub_status')
                            expect(content).to include('http://127.0.0.1/stub_status')
                            expect(content).to include('http://::1/stub_status')
                          }
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
