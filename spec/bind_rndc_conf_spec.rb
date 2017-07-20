# Cookbook Name:: netdata
# Specs:: bind_rdnc_conf_spec
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

describe 'netdata_test::bind_rndc' do
  let(:platform) { 'centos' }
  let(:version) { '6.7' }
  let(:file_path) { '/etc/netdata/python.d/bind_rndc.conf' }
  let(:default_bind_rndc_config) {
    {
      :named_stats_path => '/custom/path'
    }
  }

  describe 'python bind_rndc provider matcher' do
    let(:chef_run) {
      ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
        node.normal['netdata']['plugins']['python']['bind_rndc']['config'] = default_bind_rndc_config
      end
    }

    it 'configures bind_rndc' do
      expect(chef_run.converge(described_recipe)).to configure_netdata_bind_rndc_module('default_bind_rndc_config').with(
        :named_stats_path => '/custom/path'
      )
    end
  end

  describe 'python bind_rndc module' do
    let(:chef_run) {
      ChefSpec::SoloRunner.new(platform: platform, version: version, step_into: ['netdata_bind_rndc_conf']) do |node|
        node.normal['netdata']['plugins']['python']['bind_rndc']['config'] = default_bind_rndc_config
      end
    }

    it 'updates the configuration' do
      expect(chef_run.converge(described_recipe)).to render_file(file_path)
    end

    it 'uses default configuration' do
      expect(chef_run.converge(described_recipe)).to render_file(file_path).with_content { |content|
        expect(content).to include('/custom/path')
      }
    end

    it 'uses custom configuration' do
      chef_run.node.normal['netdata']['plugins']['python']['bind_rndc']['config'] = {
        :named_stats_path => '/etc/custom/path'
      }
      chef_run.converge(described_recipe)

      expect(chef_run).to render_file(file_path).with_content { |content|
        expect(content).to include('/etc/custom/path')
      }
    end
  end
end
