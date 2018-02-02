# Cookbook Name:: netdata
# Resources:: netdata_statsd_plugin
#
# Copyright 2018, Joao Madureira
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

resource_name :netdata_statsd_plugin

default_action :create

property :config_name, String, name_property: true
property :owner, kind_of: String, default: 'netdata'
property :group, kind_of: String, default: 'netdata'
property :app_configuration, Hash, default: {}
property :charts, Hash, default: {}
property :base_directory, String, default: ''

action :create do
  template "#{new_resource.base_directory}/etc/netdata/statsd.d/#{new_resource.config_name}.conf" do
    cookbook 'netdata'
    source 'statsd_plugin.conf.erb'
    owner new_resource.owner
    group new_resource.group
    variables(
      config_name: new_resource.config_name,
      app_configuration: new_resource.app_configuration,
      charts: {}
    )
    new_resource.charts.each do |name, value|
      variables[:charts][name] = value
    end
    notifies :restart, 'service[netdata]', :delayed
  end

  service 'netdata' do
    action :nothing
    retries 5
    retry_delay 10
  end
end
