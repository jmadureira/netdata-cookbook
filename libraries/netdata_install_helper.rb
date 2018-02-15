# Cookbook Name:: netdata
# Libraries:: netdata_install_helper
#
# Copyright 2017, Nick Willever
# Copyright 2018, Serge A. Salamanka
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

module NetdataInstall
  module Helper
    def enable_autoupdate
      autoupdate ? '--auto-update' : ''
    end

    def custom_install_path
      install_path.empty? ? '' : "--install #{install_path}"
    end

    def autoupdate_enabled_on_system?
      ::File.exist?('/etc/cron.daily/netdata-updater')
    end

    def netdata_installed?
      path = install_path.empty? ? '' : "#{install_path}/netdata"
      ::File.exist?("#{path}/usr/sbin/netdata")
    end

    def compile_packages
      packages = case node['platform_family']
                 when 'rhel', 'amazon'
                   %w(zlib-devel libuuid-devel libmnl-devel nc pkgconfig)
                 when 'debian'
                   %w(zlib1g-dev uuid-dev libmnl-dev netcat pkg-config)
                 when 'fedora'
                   %w(zlib-devel libuuid-devel libmnl-devel autoconf-archive
                      pkgconfig nc findutils)
                 else
                   raise 'Unsupported platform family'
                 end
      packages + common_compile_packages
    end

    def common_compile_packages
      %w(autoconf autogen automake gcc make)
    end

    def netdata_binary_package_installed?
      return false unless ::File.exist?('/opt/netdata/bin/netdata') && ::File.exist?('/opt/netdata/version.txt')
      node.run_state['NETDATA_BINARY_PACKAGE'] == ::File.read('/opt/netdata/version.txt')
    end
  end
end
