#
# Cookbook Name:: apt
# Recipe:: lenny-backports
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

if node[:platform] == "debian" && node[:platform_version].match(/^5.0/)
  execute "apt-get-update" do
    command "apt-get update"
    action :nothing
  end

  file "/etc/apt/sources.list.d/backports.list" do
    owner "root"
    group "root"
    mode "644"
    content "deb http://backports.debian.org/debian-backports lenny-backports main"
    notifies :run, "execute[apt-get-update]", :immediately
  end
end
