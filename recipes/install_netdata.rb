# Cookbook Name:: netdata
# Recipe:: install_netdata
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

case node['platform_family']
when 'rhel', 'redhat', 'centos'

	%w{zlib-devel libuuid-devel libmnl-devel gcc make git autoconf autogen automake pkgconfig}.each do |pkg|
		package pkg do
			action :install
		end
	end

	git "/tmp/netdata" do
		repository "https://github.com/firehol/netdata.git"
		reference "master"
		action :sync
	end

	execute 'install' do
		cwd '/tmp/netdata'
		command '/tmp/netdata/netdata-installer.sh --zlib-is-really-here --dont-wait'
	end

	%w{zlib-devel gcc make git autoconf autogen automake pkgconfig}.each do |logger|
		log logger do
			action :nothing
			subscribes :write, "package[#{logger}]"
			notifies :remove, "package[#{logger}]", :delayed
		end
	end
when 'ubuntu','debian'
	%w{zlib1g-dev uuid-dev libmnl-dev gcc make git autoconf autogen automake pkg-config}.each do |pkg|
		package pkg do
			action :install
		end
	end

	git "/tmp/netdata" do
		repository "https://github.com/firehol/netdata.git"
		reference "master"
		action :sync
	end

	execute 'install' do
		cwd '/tmp/netdata'
		command '/tmp/netdata/netdata-installer.sh --zlib-is-really-here --dont-wait'
	end

	%w{zlib1g-dev gcc make git autoconf autogen automake pkg-config}.each do |logger|
		log logger do
			action :nothing
			subscribes :write, "package[#{logger}]"
			notifies :remove, "package[#{logger}]", :delayed
		end
	end
else
	raise("Unsupported platform family")
end

