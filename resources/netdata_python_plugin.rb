# Cookbook Name:: netdata
# Resources:: netdata_python_plugin
#
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

resource_name :netdata_python_plugin

default_action :create

property :config_name, String, name_property: true
property :owner, kind_of: String, default: 'netdata'
property :group, kind_of: String, default: 'netdata'
property :global_configuration, Hash, default: {}
property :jobs, Hash, default: {}
property :base_directory, String, default: ''

action :create do
  template "#{new_resource.base_directory}/etc/netdata" \
    "/python.d/#{new_resource.config_name}.conf" do
    cookbook 'netdata'
    source 'python_plugin.conf.erb'
    owner new_resource.owner
    group new_resource.group
    variables(
      config_name: new_resource.config_name,
      global_configuration:
      (new_resource.global_configuration.empty? ? '' : new_resource.global_configuration.to_yaml),
      jobs: (new_resource.jobs.empty? ? '' : new_resource.jobs.to_yaml)
    )
    notifies :restart, 'service[netdata]', :delayed
  end

  service 'netdata' do
    action :nothing
    retries 5
    retry_delay 10
  end
end
