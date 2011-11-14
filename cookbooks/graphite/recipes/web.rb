include_recipe "apache2::mod_python"

package "python-cairo-dev"
package "python-django"
package "python-django-tagging"
package "python-simplejson"
package "python-memcache"
package "python-rrdtool"

remote_file "/usr/src/graphite-web-#{node.graphite.graphite_web.version}.tar.gz" do
  source node.graphite.graphite_web.uri
  checksum node.graphite.graphite_web.checksum
end

execute "untar graphite-web" do
  command "tar xzf graphite-web-#{node.graphite.graphite_web.version}.tar.gz"
  creates "/usr/src/graphite-web-#{node.graphite.graphite_web.version}"
  cwd "/usr/src"
end

###remote_file "/usr/src/graphite-web-#{node.graphite.graphite_web.version}/webapp/graphite/storage.py.patch" do
###  source "http://launchpadlibrarian.net/65094495/storage.py.patch"
###  checksum "8bf57821"
###end

###execute "patch graphite-web" do
###  command "patch storage.py storage.py.patch"
###  creates "/opt/graphite/webapp/graphite_web-#{node.graphite.graphite_web.version}-py2.6.egg-info"
###  cwd "/usr/src/graphite-web-#{node.graphite.graphite_web.version}/webapp/graphite"
###end

execute "install graphite-web" do
  command "python setup.py install"
  creates "/opt/graphite/webapp/graphite_web-#{node.graphite.graphite_web.version}-py2.6.egg-info"
  cwd "/usr/src/graphite-web-#{node.graphite.graphite_web.version}"
end

template "/etc/apache2/sites-available/graphite" do
  source "graphite-vhost.conf.erb"
end

apache_site "000-default" do
  enable false
end
apache_site "graphite"

app_url = node.graphite.graphite_web.public_url
template "/etc/nginx/sites-available/#{app_url}" do
  source "nginx_vhost.erb"
  mode   "0644"
  variables(:app_url => app_url, :app_port => 81)
end
nginx_site app_url

directory "/opt/graphite/storage/log/webapp" do
  owner "www-data"
  group "www-data"
end

directory "/opt/graphite/storage" do
  owner "www-data"
  group "www-data"
end

cookbook_file "/opt/graphite/storage/graphite.db" do
  owner "www-data"
  group "www-data"
  action :create_if_missing
end
