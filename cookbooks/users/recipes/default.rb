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
  @users = JSON.parse(File.read("/etc/chef/users.json"))
rescue
  log "Problem loading /etc/chef/users.json: #{$!}"
end

# Create the admins group
group "admins" do
  gid 2000
  #members ...
end

# Let's iterate over users
@users && @users.each do |u|
  home_dir = "/home/#{u['id']}"
  user_gid = 2000

  #libshadow is needed to run password command
  #and libshadow gem cannot be installed so easily
  apt_package "libshadow-ruby1.8" do
    action :install
  end

  user u['id'] do
    uid u['uid']
    gid user_gid
    shell u['shell']
    password u['password']
    comment u['comment']
    supports :manage_home => true
    home home_dir
  end

  directory "#{home_dir}/.ssh" do
    owner u['id']
    group user_gid
    mode "0700"
  end

  template "#{home_dir}/.ssh/authorized_keys" do
    source "authorized_keys.erb"
    owner u['id']
    group user_gid
    mode "0600"
    variables :ssh_keys => u['ssh_keys']
  end
end
