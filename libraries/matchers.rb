# Cookbook Name:: netdata
# Library:: matchers
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

if defined?(ChefSpec)
  ChefSpec.define_matcher :netdata_nginx_conf

  def configure_netdata_nginx_module(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:netdata_nginx_conf, :create, resource_name)
  end
end
