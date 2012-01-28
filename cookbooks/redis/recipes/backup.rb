cron "Redis: rewrite append-only file" do
  action  :create
  minute  "0"
  hour    node[:redis][:compact_at]
  day     node[:redis][:compact_every_x_days]
  month   '*'
  weekday '*'
  command "#{node[:redis][:prefix]}/bin/redis-cli bgrewriteaof"
  user "root"
  path "/usr/bin:/usr/local/bin:/bin"
end

template "/usr/local/bin/redis_backup" do
  source "redis_backup.erb"
  mode "0755"
  owner "root"
  group "root"
end

template "/usr/local/bin/redis_clean_backups" do
  source "redis_clean_backups.erb"
  mode "0755"
  owner "root"
  group "root"
end

directory node[:redis][:backupdir] do
  mode "0755"
  owner "root"
  owner "root"
  recursive true
end

execute "set owner on couchdb backup directory" do
  command "chown -R #{node[:redis][:user]}:#{node[:redis][:user]} #{node[:redis][:backupdir]}"
end

cron "backup redis files" do
  hour node[:redis][:backup_hour]
  minute node[:redis][:backup_minute]
  command "/usr/local/bin/redis_backup"
  user node[:redis][:user]
  path "/usr/bin:/usr/local/bin:/bin:/sbin:/usr/sbin"
end