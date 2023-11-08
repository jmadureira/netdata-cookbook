# Cookbook:: netdata
# Resources:: netdata_config
#
# Copyright:: 2017, Nick Willever
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

resource_name :netdata_config
provides :netdata_config

default_action :create

property :config_name, String, name_property: true
property :owner, String, default: 'netdata'
property :group, String, default: 'netdata'
property :configurations, Hash, default: {}
property :base_directory, String, default: ''

action :create do
  # As we're using the accumulator pattern we need to shove everything
  # into the root run context so each of the sections can find the parent
  with_run_context :root do
    edit_resource(
      :template,
      "#{new_resource.base_directory}/etc/netdata/netdata.conf"
    ) do |new_resource|
      cookbook 'netdata'
      source 'netdata.conf.erb'
      owner new_resource.owner
      group new_resource.group
      variables['configurations'] ||= {}
      variables['configurations'][new_resource.config_name] ||= {}

      new_resource.configurations.each do |name, value|
        variables['configurations'][new_resource.config_name][name] = value
      end

      action :nothing
      delayed_action :create
      notifies :restart, 'service[netdata]', :delayed
    end

    service 'netdata' do
      action :nothing
      retries 5
      retry_delay 10
    end
  end
end
