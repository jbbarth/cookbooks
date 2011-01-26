#
# Cookbook Name:: rvm
# Recipe:: default
#
# Copyright 2011, Jean-Baptiste Barth
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
#

include_recipe "build-essential"

packages = %w(openssl libreadline5 libreadline5-dev curl git-core file sqlite3
              zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev 
              libxml2-dev libxslt1-dev libcurl4-openssl-dev)

packages.each do |package|
  apt_package package
end

group "rvm" do
  gid 2001
  append true
end

execute "install-rvm-system-wide" do
  command "bash < <( curl -L http://bit.ly/rvm-install-system-wide )"
  not_if "test -s /usr/local/lib/rvm"
end

file "/etc/profile.d/rvm.sh" do
  owner "root"
  group "root"
  mode  "644"
  content %(# Dropped off by Chef !\n# Loads RVM (Ruby Version Manager)\nsource /usr/local/lib/rvm\n)
end
