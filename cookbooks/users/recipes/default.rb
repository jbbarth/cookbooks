#
# Cookbook Name:: users
# Recipe:: default
#
# Copyright 2011, Jean-Baptiste BARTH
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

# Typical content of a users.json file:
# [
#   {"id": "jsmith", "uid": 1001, "shell": "/bin/zsh",
#    "comment": "John Smith,room 2.5,12345677,12345678,comment",
#    "ssh_keys": "ssh-rsa bla bla bla" },
#   ...
# ]
begin
  users = JSON.parse(File.read("/etc/chef/users.json"))
rescue
  users = []
  log "Problem loading /etc/chef/users.json: #{$!}"
end

# Create the admins group
group "admins" do
  gid 2000
end

# Let's iterate over users
users.each do |u|
  home_dir = "/home/#{u['id']}"

  user u['id'] do
    uid u['uid']
    gid "admins"
    shell u['shell']
    comment u['comment']
    supports :manage_home => true
    home home_dir
    #doesn't work: seems notifies cannot find a dynamically named resource
    # notifies :run, "execute[change-passwd-#{u['id']}]"
  end

  #manage password manually...
  execute "change-passwd-#{u['id']}" do
    command "usermod -p '#{u['password']}' #{u['id']}"
    not_if "getent shadow #{u['id']}|grep -F '$'"
    only_if { u['password'] && u['password'].include?("$") }
  end

  directory "#{home_dir}/.ssh" do
    owner u['id']
    group "admins"
    mode "0700"
  end

  template "#{home_dir}/.ssh/authorized_keys" do
    source "authorized_keys.erb"
    owner u['id']
    group "admins"
    mode "0600"
    variables :ssh_keys => u['ssh_keys']
  end

  #dotfiles
  bash "install-dotfiles-#{u['id']}" do
    user u['id']
    cwd home_dir
    code <<-EOH
      git init
      git remote add origin #{u['dotfiles']}
    EOH
    only_if { u['dotfiles'] && !File.exists?(File.join(home_dir,".git")) }
  end

  #keep dotfiles synchronized
  git home_dir do
    repository u['dotfiles']
    reference "master"
    user u['id']
    only_if { u['dotfiles'] }
    action :sync
  end

  #ensure .ssh/config has the correct modes
  #even after a git sync
  file "#{home_dir}/.ssh/config" do
    owner u['id']
    group "admins"
    mode "0600"
  end
end

#if RVM is installed, add admins to RVM group
group "rvm" do
  members users.map{|u| u['id']} << "root"
  append true
  only_if "getent group rvm"
end

