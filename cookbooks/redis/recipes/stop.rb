include_recipe "redis::service"

service "redis-server" do
  action :stop
end