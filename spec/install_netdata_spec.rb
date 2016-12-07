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
			log_packages: %w{gcc make git autoconf autogen automake pkgconfig},
			mysql_packages: %w{MySQL-python}
		},
		'ubuntu' => {
			versions: ['14.04'],
			install_packages: %w{zlib1g-dev uuid-dev libmnl-dev gcc make git autoconf autogen automake pkg-config},
			log_packages: %w{gcc make git autoconf autogen automake pkg-config},
			mysql_packages: %w{python-mysqldb}
		}
	}

	describe 'python modules' do

		let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'centos', version: '6.7') }

		describe 'nginx' do

			let(:file_path) { '/etc/netdata/python.d/nginx.conf' }

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

			it 'notifies the netdata service' do
				template = chef_run.converge(described_recipe).template file_path
				expect(template).to notify('service[netdata]')
			end
	end

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
