#
# Cookbook Name:: gitolite
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

include_recipe "git"

bash "install-gitolite" do
  cwd "/tmp"
  user "root"
  code <<-EOH
    git clone git://github.com/sitaramc/gitolite gitolite-source
    cd gitolite-source
    #git checkout -t origin/pu
    git checkout master
    mkdir -p /usr/local/share/gitolite/conf /usr/local/share/gitolite/hooks
    src/gl-system-install /usr/local/bin /usr/local/share/gitolite/conf /usr/local/share/gitolite/hooks
    rm -rf gitolite-source
  EOH
  not_if { File.directory?("/usr/local/share/gitolite") }
end

user "git" do
  home  "/var/git"
  shell "/bin/bash"
end

group "git" do
  members "www-data"
  append  true
end

directory "/var/git" do
  owner "git"
  group "git"
  mode "0755"
end

template "/var/git/.gitolite.rc" do
  source "gitolite.rc.erb"
  owner  "git"
  group  "root"
  mode   "0664"
end

user = node[:users].detect{|u| u['id'] == node[:gitolite][:admin]}
admin, sshkey = user[:id], user[:ssh_keys]

file "/tmp/#{admin}.pub" do
  content sshkey
  owner   "git"
  mode    "0600"
  not_if "test -d /var/git/.gitolite"
end

bash "setup-gitolite" do
  user "git"
  code <<-EOH
    gl-setup /tmp/#{admin}.pub
    rm /tmp/#{admin}.pub
  EOH
  vars = {"HOME" => "/var/git"}
  environment vars
  not_if "test -d /var/git/.gitolite"
end

fcmd = "find /var/git/repositories"
bash "adapt repositories owners and permissions" do
  code <<-EOH
    chown -R git:git /var/git/repositories
    #{fcmd} -type d -exec chmod ug+rx {} \\;
    #{fcmd} -type f -exec chmod ug+r  {} \\;
  EOH
  only_if "#{fcmd} ! -user git -o ! -group git -o \\( -type d ! -perm -ug+rx \\) -o \\( -type f ! -perm -ug+r \\) |grep g"
end
