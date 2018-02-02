# Cookbook Name:: netdata
# Library:: matchers
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

if defined?(ChefSpec)
  ChefSpec.define_matcher :netdata_bind_rndc_conf
  ChefSpec.define_matcher :netdata_nginx_conf
  ChefSpec.define_matcher :netdata_install
  ChefSpec.define_matcher :netdata_config
  ChefSpec.define_matcher :netdata_python_plugin
  ChefSpec.define_matcher :netdata_statsd_plugin

  def configure_netdata_bind_rndc_module(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:netdata_bind_rndc_conf, :create, resource_name)
  end

  def configure_netdata_nginx_module(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:netdata_nginx_conf, :create, resource_name)
  end

  def install_netdata_install(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:netdata_install, :install, resource_name)
  end

  def create_netdata_config(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:netdata_config, :create, resource_name)
  end

  def create_netdata_stream(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:netdata_stream, :create, resource_name)
  end

  def create_netdata_python_plugin(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:netdata_python_plugin, :create, resource_name)
  end

  def create_netdata_statsd_plugin(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:netdata_statsd_plugin, :create, resource_name)
  end
end
