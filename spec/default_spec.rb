# Cookbook Name:: netdata
# Specs:: default_spec
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

describe 'netdata::default' do
  yum_repo_platforms = {
    'centos' => ['6.7']
  }

  yum_repo_platforms.each do |platform, versions|
    describe platform do
      versions.each do |version|
        describe version do
          let(:chef_run) { ChefSpec::SoloRunner.new(platform: platform, version: version).converge(described_recipe) }

          it 'includes the yum-epel recipe' do
            expect(chef_run).to include_recipe('yum-epel')
          end
        end
      end
    end
  end

  no_yum_repo_platforms = {
    'centos' => ['7.2.1511'],
    'ubuntu' => ['14.04']
  }

  no_yum_repo_platforms.each do |platform, versions|
    describe platform do
      versions.each do |version|
        describe version do
          let(:chef_run) { ChefSpec::SoloRunner.new(platform: platform, version: version).converge(described_recipe) }

          it 'does not include the yum-epel recipe' do
            expect(chef_run).to_not include_recipe('yum-epel')
          end
        end
      end
    end
  end
end
