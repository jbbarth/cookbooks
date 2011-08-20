#
# Cookbook Name:: app_pegasus
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


#TODO: move it in a general recipe
directory "/apps" do
  owner "www-data"
  group "admins"
  mode  "2755"
end

%w(. shared shared/config shared/log shared/pids shared/system).each do |dir|
  directory "/apps/pegasus.jbbarth.com/#{dir}" do
    owner "www-data"
    group "admins"
    mode  "2755"
  end
end

file "/apps/pegasus.jbbarth.com/shared/config/database.yml" do
  content ""
  not_if { File.exists?(path) }
end


#the deploy resource
deploy "/apps/pegasus.jbbarth.com" do
  repo              "/home/jbbarth/dev/cic.git"
  revision          "HEAD"
  user              "www-data"
  before_migrate do
    current_release = release_path
    bash "install the gemset" do
      cwd current_release
      code <<-EOF
        source '/usr/local/rvm/scripts/rvm'
        rvm 1.9.2@pegasus.jbbarth.com --create
        bundle check || bundle
      EOF
    end
  end
  migrate           false
  #migration_command %(bash -c "source '/usr/local/rvm/scripts/rvm'; rvm 1.9.2@pegasus.jbbarth.com; rake db:migrate")
  environment       "RAILS_ENV" => "production"
  shallow_clone     true
  action            :deploy
  restart_command   "/etc/init.d/app_pegasus.jbbarth.com restart"
end
