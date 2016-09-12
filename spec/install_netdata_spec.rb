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
			install_packages: %w{zlib-devel libuuid-devel libmnl-devel gcc make git autoconf autogen automake pkgconfig},
			log_packages: %w{gcc make git autoconf autogen automake pkgconfig}
		},
		'ubuntu' => {
			versions: ['14.04'],
			install_packages: %w{zlib1g-dev uuid-dev libmnl-dev gcc make git autoconf autogen automake pkg-config},
			log_packages: %w{gcc make git autoconf autogen automake pkg-config}
		}
	}

	describe 'git configuration' do

    let(:git_reference) { '1.3.0' }
		let(:git_repository) { 'https://github.com/random_dude/netdata.git' }
		let(:chef_run) {
			ChefSpec::SoloRunner.new(platform: 'centos', version: '6.7') do |node|
				node.normal['netdata']['source']['git_repository'] = git_repository
				node.normal['netdata']['source']['git_revision'] = git_reference
			end.converge(described_recipe)
		}

		it 'uses a configurable git reference' do
			expect(chef_run).to sync_git("/tmp/netdata").with(reference: git_reference)
		end

		it 'uses a configurable git repository' do
			expect(chef_run).to sync_git("/tmp/netdata").with(repository: git_repository)
		end

	end

  platform_check.each do |platform, options|

		describe platform do

			options[:versions].each do |version|

				describe version do

	        let(:chef_run) { ChefSpec::SoloRunner.new(platform: platform, version: version).converge(described_recipe) }

        	options[:install_packages].each do |pkg|
      	  	it "installs the #{pkg} package" do
      		  	expect(chef_run).to install_package(pkg)
        		end
	        end

        	it 'clones github repo on /tmp folder' do
            expect(chef_run).to sync_git("/tmp/netdata").with(reference: 'master')
        	end

        	it 'notifies the installer execution' do
	        	git_command = chef_run.git('/tmp/netdata')
	      	  expect(git_command).to notify('execute[install]')
	        end

        	it 'does not run installer by default' do
	        	expect(chef_run).to_not run_execute('install')
        	end

					options[:log_packages].each do |pkg|
	        	it 'logs do nothing' do
	      	  	log = chef_run.log(pkg)
		      	  expect(log).to do_nothing
        		end

	        	it 'notifies to remove pkgs delayed' do
		        	log = chef_run.log(pkg)
		      	  expect(log).to notify("package[#{pkg}]").to(:remove).delayed
        		end

        		it "subscribes to install #{pkg} packages" do
	        		log = chef_run.log(pkg)
	      	  	expect(log).to subscribe_to("package[#{pkg}]").on(:write)
        		end
					end
				end
		  end
		end
	end
end
