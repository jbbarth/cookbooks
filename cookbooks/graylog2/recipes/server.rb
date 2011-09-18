#
# Cookbook Name:: graylog2
# Recipe:: server
#
# Copyright 2010, Medidata Solutions Inc.
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

# Add APT public key for the 10gen MongoDB repo
execute "apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10" do
  not_if 'apt-key list | grep "7F0CEB10"'
end

# Add the 10gen MongoDB repository to APT
apt_repository "mongodb" do
  uri "http://downloads-distro.mongodb.org/repo/#{node[:platform] == "debian" ? "debian-sysvinit" : "ubuntu-upstart"}"
  distribution "dist"
  components ["10gen"]
  action :add
end

# Install required APT packages
package "openjdk-6-jre"
package "mongodb-10gen"

# Create the release directory
directory "#{node.graylog2.basedir}/rel" do
  mode 0755
  recursive true
end

# Download the desired version of Graylog2 server from GitHub
remote_file "download_server" do
  path "#{node.graylog2.basedir}/rel/graylog2-server-#{node.graylog2.server.version}.tar.gz"
  source "https://github.com/downloads/Graylog2/graylog2-server/graylog2-server-#{node.graylog2.server.version}.tar.gz"
  action :create_if_missing
end

# Unpack the desired version of Graylog2 server
execute "tar zxf graylog2-server-#{node.graylog2.server.version}.tar.gz" do
  cwd "#{node.graylog2.basedir}/rel"
  creates "#{node.graylog2.basedir}/rel/graylog2-server-#{node.graylog2.server.version}/build_date"
  #doesn't work...
  #action :nothing
  #subscribes :run, resources(:remote_file => "download_server"), :immediately
  not_if { File.exists?("#{node.graylog2.basedir}/rel/graylog2-server-#{node.graylog2.server.version}/build_date") }
end

# Link to the desired Graylog2 server version
link "#{node.graylog2.basedir}/server" do
  to "#{node.graylog2.basedir}/rel/graylog2-server-#{node.graylog2.server.version}"
end

# Create graylog2.conf
template "/etc/graylog2.conf" do
  mode 0644
end

# Create init.d script
template "/etc/init.d/graylog2" do
  source "graylog2.init.erb"
  mode 0755
end

# Update the rc.d system
execute "update-rc.d graylog2 defaults" do
  creates "/etc/rc0.d/K20graylog2"
  action :nothing
  subscribes :run, resources(:template => "/etc/init.d/graylog2"), :immediately
end

# Service resource
service "graylog2" do
  supports :restart => true
  action [:enable, :start]
end
