# Cookbook Name:: netdata
# Specs:: install_netdata_spec
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

describe 'netdata::install_netdata' do
  platform_check = {
    'centos' => {
      versions: ['6.7'],
      install_packages: %w(zlib-devel libuuid-devel libmnl-devel gcc make git autoconf autogen automake pkgconfig),
      log_packages: %w(gcc make git autoconf autogen automake pkgconfig),
      mysql_packages: %w(MySQL-python)
    },
    'ubuntu' => {
      versions: ['14.04'],
      install_packages: %w(zlib1g-dev uuid-dev libmnl-dev gcc make git autoconf autogen automake pkg-config),
      log_packages: %w(gcc make git autoconf autogen automake pkg-config),
      mysql_packages: %w(python-mysqldb)
    }
  }

  platform_check.each do |platform, options|
    describe platform do
      options[:versions].each do |version|
        describe version do
          describe 'git configuration' do
            let(:git_reference) { '1.3.0' }
            let(:git_repository) { 'https://github.com/random_dude/netdata.git' }
            let(:git_directory) { '/var/tmp/new_directory' }
            let(:chef_run) {
              ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
                node.normal['netdata']['source']['git_repository'] = git_repository
                node.normal['netdata']['source']['git_revision'] = git_reference
                node.normal['netdata']['source']['directory'] = git_directory
              end.converge(described_recipe)
            }

            it 'uses a configurable git reference' do
              expect(chef_run).to sync_git(git_directory).with(reference: git_reference)
            end

            it 'uses a configurable git repository' do
              expect(chef_run).to sync_git(git_directory).with(repository: git_repository)
            end
          end
        end

        describe version do
          let(:chef_run) { ChefSpec::SoloRunner.new(platform: platform, version: version).converge(described_recipe) }

          options[:install_packages].each do |pkg|
            it "installs the #{pkg} package" do
              expect(chef_run).to install_package(pkg)
            end
          end

          it 'clones github repo on default folder' do
            expect(chef_run).to sync_git(chef_run.node['netdata']['source']['directory']).with(reference: 'master')
          end

          it 'notifies the installer execution' do
            git_command = chef_run.git(chef_run.node['netdata']['source']['directory'])
            expect(git_command).to notify('execute[install]')
          end

          it 'does not run installer by default' do
            expect(chef_run).to_not run_execute('install')
          end

          it 'does not restart service netdata' do
            expect(chef_run).to_not restart_service('netdata')
          end

        end

        describe version do
          describe 'netdata.conf' do

            it 'does not update the conf file if there are no configuration changes' do
              chef_run = ChefSpec::SoloRunner.new(platform: platform, version: version).converge(described_recipe)
              expect(chef_run).to_not render_file('/etc/netdata/netdata.conf')
            end

            it 'updates the conf file if there are configuration changes' do
              chef_run = ChefSpec::SoloRunner.new(platform: platform, version: version) do |node|
                node.normal['netdata']['conf']['global'] = { history: 3996 }
              end.converge(described_recipe)
              expect(chef_run).to render_file('/etc/netdata/netdata.conf')
            end

          end
        end

        describe version do
          describe 'python plugin' do
            describe 'mysql module' do
              let(:chef_run) { ChefSpec::SoloRunner.new(platform: platform, version: version) }

              options[:mysql_packages].each do |pkg|
                it "does not install #{pkg} package dependency by default" do
                  chef_run.converge(described_recipe)
                  expect(chef_run).to_not install_package(pkg)
                end

                it "installs the #{pkg} package dependency" do
                  chef_run.node.normal['netdata']['plugins']['python']['mysql']['enabled'] = true
                  chef_run.converge(described_recipe)
                  expect(chef_run).to install_package(pkg)
                end
              end
            end
          end
        end
      end
    end
  end
end
