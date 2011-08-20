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

app_url  = "pegasus.jbbarth.com"
app_dir  = "/apps/#{app_url}"
app_rvm  = "1.9.2@#{app_url}"
app_repo = "/home/jbbarth/dev/cic.git"
app_rev  = "HEAD"

#TODO: move it in a general recipe
directory "/apps" do
  owner "www-data"
  group "admins"
  mode  "2755"
end

%w(. shared shared/config shared/log shared/pids shared/system).each do |dir|
  directory "#{app_dir}/#{dir}" do
    owner "www-data"
    group "admins"
    mode  "2755"
  end
end

file "#{app_dir}/shared/config/database.yml" do
  content ""
  not_if { File.exists?(path) }
end


#the deploy resource
deploy app_dir do
  repo              app_repo
  revision          app_rev
  user              "www-data"
  before_migrate do
    bash "install the gemset" do
      cwd release_path
      code <<-EOF
        source '/usr/local/rvm/scripts/rvm'
        rvm #{app_rvm} --create
        bundle check || bundle
      EOF
    end
  end
  migrate           false
  #migration_command %(bash -c "source '/usr/local/rvm/scripts/rvm'; rvm #{app_rvm}; rake db:migrate")
  environment       "RAILS_ENV" => "production"
  shallow_clone     true
  action            :deploy
  restart_command   "/etc/init.d/app_#{app_url} restart"
  before_restart do
    bash "copy status.dat file" do
      cwd release_path
      code <<-EOF
        cp /opt/shinken-0.5.1/var/status.dat #{app_dir}/current/data/system/status.dat
        chown #{user} #{app_dir}/current/data/system/status.dat
      EOF
    end
  end
end
