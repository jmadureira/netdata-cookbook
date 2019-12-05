# Cookbook:: netdata
# Specs:: install_netdata_spec
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

describe_resource 'netdata_install' do
  describe 'install' do
    shared_examples_for :source do
      let(:execute) { chef_run.execute('install') }
      it 'installs with default options' do
        expect(chef_run).to install_netdata_install('source').with(
          git_repository: 'https://github.com/firehol/netdata.git',
          git_revision: 'master',
          git_source_directory: '/tmp/netdata',
          install_path: '',
          autoupdate: false,
          update: false
        )
        package = chef_run.package('compile_packages')
        expect(package).to do_nothing
        # expect(chef_run).to nothing_package('compile_packages')
        expect(chef_run).to install_package('plugin_packages')
        expect(chef_run).to sync_git('/tmp/netdata')
        expect(chef_run).to run_execute('install')
        expect(execute).to notify('package[compile_packages]').to(:install).before
        expect(execute).to notify('service[netdata]').to(:restart).delayed
        expect(chef_run).to start_service('netdata')
        expect(chef_run).to enable_service('netdata')
        expect { chef_run }.to_not raise_error
      end
    end

    context 'source' do
      let(:run_list) { 'netdata_spec::source' }
      cached(:chef_run) do
        ChefSpec::SoloRunner.new(
          platform: 'ubuntu', version: 16.04,
          step_into: ['netdata_install']).converge(run_list)
      end

      it 'includes apt cookbook' do
        expect(chef_run).to include_recipe('apt')
      end

      it_behaves_like :source
    end

    context 'source' do
      let(:run_list) { 'netdata_spec::source' }
      let(:chef_run) do
        ChefSpec::SoloRunner.new(
          platform: 'centos', version: 6.9,
          step_into: ['netdata_install']).converge(run_list)
      end

      it 'includes yum-epel cookbook and sets yum attributes' do
        expect(chef_run).to include_recipe('yum-epel')
        expect(chef_run.node.default['yum']['epel-testing']['enabled']).to eq(true)
        expect(chef_run.node.default['yum']['epel-testing']['managed']).to eq(true)
      end

      it_behaves_like :source
    end

    context 'binary' do
      let(:run_list) { 'netdata_spec::binary' }
      let(:chef_run) do
        ChefSpec::SoloRunner.new(
          step_into: ['netdata_install']) do |node|
            node.automatic['kernel']['machine'] = 'x86'
          end.converge(run_list)
      end
      it 'raises an error if not 64bit' do
        expect { chef_run }.to raise_error(RuntimeError)
      end
    end

    context 'binary' do
      let(:run_list) { 'netdata_spec::binary' }
      let(:chef_run) do
        ChefSpec::SoloRunner.new(
          step_into: ['netdata_install']) do |node|
            node.automatic['kernel']['machine'] = 'x86_64'
            node.run_state['NETDATA_BINARY_PACKAGE'] = 'netdata-latest.gz.run'
          end.converge(run_list)
      end
      let(:bash) { chef_run.bash('install_netdata_binary_package') }
      it 'installs with default options' do
        expect(chef_run).to install_netdata_install('binary').with(
          binary_repository: 'https://raw.githubusercontent.com/firehol/binary-packages/master',
          binary_package: 'netdata-latest.gz.run',
          binary_install_options: ['--accept'],
          binary_post_install_options: []
        )
        expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/netdata_latest.txt")
        expect(chef_run).to run_ruby_block('set_netdata_binary_package')
        expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/netdata-package.gz.run")
        expect(chef_run).to delete_file("#{Chef::Config[:file_cache_path]}/netdata_latest.txt")
        expect(chef_run).to run_bash('install_netdata_binary_package')
        expect(bash).to notify('file[/opt/netdata/version.txt]').to(:create).immediately
        expect(bash).to notify('service[netdata]').to(:restart).delayed
        expect(chef_run).to delete_file("#{Chef::Config[:file_cache_path]}/netdata-package.gz.run")
        file = chef_run.file('/opt/netdata/version.txt')
        expect(file).to do_nothing
        # expect(chef_run).to nothing_file('/opt/netdata/version.txt')
        expect(chef_run).to start_service('netdata')
        expect(chef_run).to enable_service('netdata')
        expect { chef_run }.to_not raise_error
      end
    end

    context 'unsupported' do
      let(:run_list) { 'netdata_spec::unsupported' }
      let(:chef_run) do
        ChefSpec::SoloRunner.new(step_into: ['netdata_install']).converge(run_list)
      end
      let(:chef_run_only_recipe) { ChefSpec::SoloRunner.new().converge(run_list) }

      it 'raises an error' do
        # to cover netdata_install resource without stepping into it:
        expect(chef_run_only_recipe).to install_netdata_install('unsupported')
        # to catch raise exception when stepping into netdata_install resource:
        expect { chef_run }.to raise_error(RuntimeError)
      end
    end
  end
end
