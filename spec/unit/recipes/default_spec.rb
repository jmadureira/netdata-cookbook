# Cookbook:: netdata
# Specs:: default_spec
#
# Copyright:: 2016, Abiquo
# Copyright:: 2017, Nick Willever
# Copyright:: 2018, Serge A. Salamanka
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

describe 'netdata::default' do
  context 'When all attributes are default' do
    let(:chef_run) do
      ChefSpec::SoloRunner.new.converge(described_recipe)
    end

    before do
      allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).and_call_original
      allow_any_instance_of(Chef::Recipe).to receive(:include_recipe).with('netdata::install_netdata')
    end

    it 'includes install_netdata recipe' do
      expect_any_instance_of(Chef::Recipe).to receive(:include_recipe).with('netdata::install_netdata')
      chef_run
    end

    it 'converges successfully' do
      expect { chef_run }.to_not raise_error
    end
  end
end
