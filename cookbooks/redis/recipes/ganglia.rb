template "/etc/ganglia/conf.d/redis.pyconf" do
  source "redis.pyconf.erb"
  owner "root"
  group "root"
  mode '0644'
end

template "/etc/ganglia/python_modules/redis.py" do
  source "redis.py.erb"
  mode "0755"
end
