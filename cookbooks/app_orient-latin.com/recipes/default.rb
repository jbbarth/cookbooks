#
# Cookbook Name:: app_orient-latin.com
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

app_url  = "orient-latin.com"
app_dir  = "/apps/#{app_url}"
app_rvm  = "1.9.2@#{app_url}"
app_repo = "/home/mgoepp/orient-latin.git"
app_rev  = "HEAD"
app_user = "nobody"
app_port = 3005

#dependencies
include_recipe "apps"

#shared directories
["", "shared", "shared/config", "shared/db", "shared/log", "shared/pids", "shared/system"].each do |dir|
  directory "#{app_dir}/#{dir}" do
    owner app_user
    group "admins"
    mode  "2775"
  end
end

#shared files
%w(database sunspot).each do |file|
  template "#{app_dir}/shared/config/#{file}.yml" do
    source "#{file}.yml.erb"
    owner  app_user
    group  "admins"
    mode   "0664"
    not_if { File.exists?(path) }
  end
end

#log files permissions
bash "set log files permissions" do
  cwd "#{app_dir}/shared/log"
  code "chmod 664 #{app_dir}/shared/log/*"
  only_if "find #{app_dir}/shared/log -type f ! -perm -0664 |grep log"
end

#startup script for app
template "/etc/init.d/app_#{app_url}" do
  source "init_app.erb"
  owner "root"
  group "admins"
  mode  "0775"
  variables(:app_url => app_url, :app_dir => app_dir, :app_rvm => app_rvm, :app_port => app_port)
end

#startup script for solr
template "/etc/init.d/solr_#{app_url}" do
  source "init_solr.erb"
  owner "root"
  group "admins"
  mode  "0775"
  variables(:app_url => app_url, :app_dir => app_dir, :app_rvm => app_rvm)
end

#vhost
template "/etc/nginx/sites-available/#{app_url}" do
  source "nginx_vhost.erb"
  mode   "0644"
  variables(:app_url => app_url, :app_port => app_port)
end
#enables the vhost
nginx_site app_url

#TODO: add a cron to reindex solr database (???)

#the deploy resource
deploy_revision app_dir do
  repo              app_repo
  revision          app_rev
  user              app_user
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
  symlink_before_migrate "config/database.yml" => "config/database.yml",
                         "config/sunspot.yml"  => "config/sunspot.yml",
                         "db/forteresses.sqlite3" => "db/forteresses.sqlite3"
  migrate           true
  migration_command %(bash -c "source '/usr/local/rvm/scripts/rvm'; rvm #{app_rvm}; rake db:migrate db:seed")
  environment       "RAILS_ENV" => "production"
  shallow_clone     true
  action            :deploy
  restart_command   "/etc/init.d/app_#{app_url} restart"
  notifies :restart, "service[solr_#{app_url}]"
end

#start solr service if needed
service "solr_#{app_url}" do
  supports :status => true, :restart => true
  action [ :enable, :start ]
end
