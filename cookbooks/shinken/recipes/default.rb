#
# Cookbook Name:: shinken
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

package "python"
package "pyro"

version = "shinken-0.5.1"
tarball = "#{version}.tar.gz"

group "shinken"

user "shinken" do
  gid "shinken"
  home "/opt/#{version}"
  shell "/bin/false"
  comment "Shinken monitoring system"
end

bash "install-shinken" do
  user "root"
  cwd  "/tmp"
  code <<-EOH
    wget http://shinken-monitoring.org/pub/#{tarball}
    tar xvzf #{tarball} -C /opt
    chown -R shinken:shinken /opt/#{version}
    rm #{tarball}
  EOH
  not_if { File.directory?("/opt/#{version}") }
end

link "/usr/local/shinken" do
  to "/opt/#{version}"
end

template "/usr/local/shinken/etc/shinken-specific.cfg" do
  source "shinken-specific.cfg.erb"
  owner "shinken"
  group "shinken"
  mode "664"
end

execute "copy-shinken-init-script" do
  command "cp -a /usr/local/shinken/bin/init.d/shinken /etc/init.d/"
  not_if { File.exists?("/etc/init.d/shinken") }
end

service "shinken" do
  supports :status => true, :restart => true, :reload => false
  action [ :enable, :start ]
end

