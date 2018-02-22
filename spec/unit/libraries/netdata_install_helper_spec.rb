# Cookbook Name:: netdata
# Specs:: netdata_install_helper_spec
#
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

require 'spec_helper'
require './libraries/netdata_install_helper'

describe_helpers 'NetdataInstall::Helper' do
  include NetdataInstall::Helper
  describe '#enable_autoupdate' do
    cached(:autoupdate) { false }
    it 'should return empty string' do
      expect(enable_autoupdate).to eq('')
    end
  end

  describe '#enable_autoupdate' do
    cached(:autoupdate) { true }
    it 'should return --auto-update string' do
      expect(enable_autoupdate).to eq('--auto-update')
    end
  end

  describe '#custom_install_path' do
    cached(:install_path) { '' }
    it 'should return empty string' do
      expect(custom_install_path).to eq('')
    end
  end

  describe '#custom_install_path' do
    cached(:install_path) { '/usr/local' }
    it 'should return --install path' do
      expect(custom_install_path).to eq('--install /usr/local')
    end
  end

  describe '#autoupdate_enabled_on_system?' do
    it 'should return true' do
      allow(File).to receive(:exist?).with('/etc/cron.daily/netdata-updater').and_return true
      expect(autoupdate_enabled_on_system?).to eq(true)
    end
  end

  describe '#autoupdate_enabled_on_system?' do
    it 'should return false' do
      allow(File).to receive(:exist?).with('/etc/cron.daily/netdata-updater').and_return false
      expect(autoupdate_enabled_on_system?).to eq(false)
    end
  end

  describe '#netdata_installed?' do
    cached(:install_path) { '/usr/local' }
    it 'should return true' do
      allow(File).to receive(:exist?).with('/usr/local/netdata/usr/sbin/netdata').and_return true
      expect(netdata_installed?).to eq(true)
    end
  end

  describe '#netdata_installed?' do
    cached(:install_path) { '' }
    it 'should return false' do
      allow(File).to receive(:exist?).with('/usr/sbin/netdata').and_return false
      expect(netdata_installed?).to eq(false)
    end
  end

  describe '#compile_packages' do
    context 'RHEL' do
      cached(:node) { { 'platform_family' => 'rhel' } }
      it 'should return list' do
        expect(compile_packages).to eq(%w(zlib-devel libuuid-devel libmnl-devel
                                          nc pkgconfig) + common_compile_packages)
      end
    end
    context 'Amazon' do
      cached(:node) { { 'platform_family' => 'amazon' } }
      it 'should return list' do
        expect(compile_packages).to eq(%w(zlib-devel libuuid-devel libmnl-devel
                                          nc pkgconfig) + common_compile_packages)
      end
    end
    context 'Debian' do
      cached(:node) { { 'platform_family' => 'debian' } }
      it 'should return list' do
        expect(compile_packages).to eq(%w(zlib1g-dev uuid-dev libmnl-dev netcat
                                          pkg-config) + common_compile_packages)
      end
    end
    context 'Fedora' do
      cached(:node) { { 'platform_family' => 'fedora' } }
      it 'should return list' do
        expect(compile_packages).to eq(%w(zlib-devel libuuid-devel libmnl-devel
                                          autoconf-archive pkgconfig nc
                                          findutils) + common_compile_packages)
      end
    end
    context 'Unsupported' do
      cached(:node) { { 'platform_family' => 'unsupported' } }
      it 'should return error' do
        expect { compile_packages }.to raise_error(RuntimeError)
      end
    end
  end

  describe '#common_compile_packages' do
    it 'should return list' do
      expect(common_compile_packages).to eq(%w(autoconf autogen automake gcc make))
    end
  end

  describe '#netdata_binary_package_installed?' do
    cached(:node) { Chef::Node }
    it 'should return true' do
      allow(node).to receive(:run_state).and_return('NETDATA_BINARY_PACKAGE' => 'netdata-latest.gz.run')
      allow(File).to receive(:exist?).with('/opt/netdata/bin/netdata').and_return true
      allow(File).to receive(:exist?).with('/opt/netdata/version.txt').and_return true
      allow(File).to receive(:read).with('/opt/netdata/version.txt').and_return 'netdata-latest.gz.run'
      expect(netdata_binary_package_installed?).to eq(true)
    end
  end

  describe '#netdata_binary_package_installed?' do
    # cached(:node) { Chef::Node }
    it 'should return false' do
      # allow(node).to receive(:run_state).and_return({'NETDATA_BINARY_PACKAGE' => 'netdata-latest.gz.run'})
      allow(File).to receive(:exist?).with('/opt/netdata/bin/netdata').and_return false
      allow(File).to receive(:exist?).with('/opt/netdata/version.txt').and_return false
      # allow(File).to receive(:read).with('/opt/netdata/version.txt').and_return 'netdata-latest.gz.run'
      expect(netdata_binary_package_installed?).to eq(false)
    end
  end

  describe '#netdata_binary_package_installed?' do
    cached(:node) { Chef::Node }
    it 'should return false' do
      allow(node).to receive(:run_state).and_return('NETDATA_BINARY_PACKAGE' => 'netdata-latest.gz.run')
      allow(File).to receive(:exist?).with('/opt/netdata/bin/netdata').and_return true
      allow(File).to receive(:exist?).with('/opt/netdata/version.txt').and_return true
      allow(File).to receive(:read).with('/opt/netdata/version.txt').and_return 'netdata-some-version.gz.run'
      expect(netdata_binary_package_installed?).to eq(false)
    end
  end
end
