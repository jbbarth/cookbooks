remote_file "/tmp/redis-#{node[:redis][:cli][:version]}.tar.gz" do
  source "http://redis.googlecode.com/files/redis-#{node[:redis][:cli][:version]}.tar.gz"
end

execute "tar xvfz /tmp/redis-#{node[:redis][:cli][:version]}.tar.gz" do
  cwd "/tmp"
end

execute "make" do
  cwd "/tmp/redis-#{node[:redis][:cli][:version]}"
end

_node = node

ruby_block do
  block do
    FileUtils.install "/tmp/redis-#{_node[:redis][:version]}/src/redis-cli",
                      "#{_node[:redis][:prefix]}/bin", :mode => 0755
    FileUtils.chown _node[:redis][:user], 'users', "#{_node[:redis][:prefix]}/bin/redis-cli"
  end
end
