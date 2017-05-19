# Cookbook Name:: netdata
# Specs:: nginx_conf_spec
#
# Copyright 2016, Abiquo
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
  let(:platform) { 'centos' }
  let(:version) { '6.7' }
  let(:file_path) { '/etc/netdata/python.d/nginx.conf' }
  let(:default_config) {
    {
      'localhost' => {
        'name' => 'local',
        'url' => 'http://localhost/stub_status'
      },
      'localipv4' => {
        'name' => 'local',
        'url' => 'http://127.0.0.1/stub_status'
      },
      'localipv6' => {
        'name' => 'local',
        'url' => 'http://::1/stub_status'
      }
    }
  }

  describe 'python nginx provider matcher' do
    let(:chef_run) {
      ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
        node.normal['netdata']['plugins']['python']['nginx']['config'] = default_config
      end
    }

    it 'configures nginx' do
      expect(chef_run.converge(described_recipe)).to configure_netdata_nginx_module('default_config')
    end
  end

  describe 'python nginx module' do
    let(:chef_run) {
      ChefSpec::SoloRunner.new(platform: platform, version: version, step_into: ['netdata_nginx_conf']) do |node|
        node.normal['netdata']['plugins']['python']['nginx']['config'] = default_config
      end
    }

    it 'updates the configuration' do
      expect(chef_run.converge(described_recipe)).to render_file(file_path)
    end

    it 'uses default configuration' do
      expect(chef_run.converge(described_recipe)).to render_file(file_path).with_content { |content|
        expect(content).to include('http://localhost/stub_status')
        expect(content).to include('http://127.0.0.1/stub_status')
        expect(content).to include('http://::1/stub_status')
      }
    end

    it 'uses custom configuration' do
      chef_run.node.normal['netdata']['plugins']['python']['nginx']['config'] = {
        'localhost' => {
          'name' => 'test',
          'url' => 'http://127.0.0.1:8080/stub_status'
        }
      }
      chef_run.converge(described_recipe)

      expect(chef_run).to render_file(file_path).with_content { |content|
        expect(content).to include('localhost')
        expect(content).to include('http://127.0.0.1:8080/stub_status')
        expect(content).to_not include('http://localhost/stub_status')
      }
    end
  end
end
