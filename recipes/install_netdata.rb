# Cookbook Name:: netdata
# Recipe:: install_netdata
#
# Copyright 2016, Abiquo
# Copyright 2017, Nick Willever
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

Chef::Log.warn "Use of `recipe['netdata::install_netdata']` is now " \
  'deprecated and will be removed in a future release. ' \
  "`netdata_install` resource or recipe['netdata::default'] should be used."

python_mysql_package =  case node['platform_family']
                        when 'rhel', 'amazon', 'fedora'
                          'MySQL-python'
                        when 'debian'
                          'python-mysqldb'
                        else
                          raise 'Unsupported platform family'
                        end

package 'python_mysql' do
  package_name python_mysql_package
  only_if { node['netdata']['plugins']['python']['mysql']['enabled'] }
end

netdata_install 'default' do
  git_repository node['netdata']['source']['git_repository']
  git_revision node['netdata']['source']['git_revision']
  git_source_directory node['netdata']['source']['directory']
end
