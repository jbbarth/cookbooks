#
# Cookbook Name:: virtualbox
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
package "lsb-release"

codename = node[:lsb][:codename]
vbox_apt_file = "/etc/apt/sources.list.d/virtualbox.list"

bash "add-virtualbox-repository" do
  code <<-EOH
    wget -q http://download.virtualbox.org/virtualbox/debian/oracle_vbox.asc -O- | sudo apt-key add -
    echo "deb http://download.virtualbox.org/virtualbox/debian #{codename} contrib" > #{vbox_apt_file}
    aptitude update
  EOH
  only_if { !File.exists?(vbox_apt_file) && codename }
end

package "virtualbox-4.0"
