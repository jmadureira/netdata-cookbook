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
	let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'centos').converge(described_recipe) }

	%w{zlib-devel gcc make git autoconf autogen automake pkgconfig}.each do |pkg|
		it "installs the #{pkg} package" do
			expect(chef_run).to install_package(pkg)
		end
	end

	it 'clones github repo on /tmp folder' do
		expect(chef_run).to sync_git("/tmp/netdata")
	end

	it 'executes installer' do
		expect(chef_run).to run_execute('install')
	end

	%w{zlib-devel gcc make git autoconf autogen automake pkgconfig}.each do |pkg|
		it 'logs do nothing' do
			log = chef_run.log(pkg)
			expect(log).to do_nothing
		end

		it 'notifies to remove pkgs delayed' do
			log = chef_run.log(pkg)
			expect(log).to notify("package[#{pkg}]").to(:remove).delayed
		end

		it 'subscribes to install packages' do
			log = chef_run.log(pkg)
			expect(log).to subscribe_to("package[#{pkg}]").on(:write)
		end
	end
end