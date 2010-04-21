#
# Cookbook Name:: base
# Recipe:: default
#
# Copyright 2010, jbbarth's personal cookbooks
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

node[:user] ||= "salvor"

#apt packages
list = %w(zsh screen vim openssh-server git-core subversion make sysv-rc-conf nfs-common tree
          ruby1.8 ruby1.8-dev ri1.8 rake irb rubygems1.8 libopenssl-ruby libsqlite3-ruby1.8
          sqlite3 libsqlite3-dev sysv-rc-conf sysklogd libxslt1.1 libxslt1-dev gawk ncurses-term
          cryptsetup libmysqlclient-dev god)
list += %w(mplayer gstreamer0.10-ffmpeg gstreamer0.10-plugins-bad gstreamer0.10-plugins-ugly
          ttf-mscorefonts-installer ttf-liberation ttf-dejavu libgsf-bin imagemagick mplayerthumbs 
          xul-ext-firebug xchm wicd w32codecs irssi conky colordiff p7zip xsel xfce4-terminal) if node[:domain] == "home"

execute "apt-get update"

list.each do |pkg|
  apt_package pkg
end

#gem packages
gems = %w(rails rake ZenTest ruby-debug wirble hpricot nokogiri webrat rspec-rails rspec cucumber mysql
          sqlite3-ruby nifty-generators)
gems.each do |gem|
  gem_package gem
end

#links to ruby utils
%w(ruby ri rdoc gem).each do |bin|
  link "/usr/bin/#{bin}" do
    to "/usr/bin/#{bin}1.8"
    link_type :symbolic
  end
end

#configure gnome if present
if File.exists?(%x(which gconftool-2).chomp)
  %w(buttons menus).each do |item|
    execute "gconftool-2 --set /desktop/gnome/interface/#{item}_have_icons --type bool true" do
      user node[:user]
      not_if "gconftool-2 --get /desktop/gnome/interface/#{item}_have_icons|grep true", :user => node[:user]
    end
  end
end

#git config
cmd = "git config --global"
attrs = { "user.name"  => "jbbarth", "user.email" => "jeanbaptiste.barth@gmail.com" }
attrs.each do |k,v|
  execute "#{cmd} #{k} #{v}" do
    user node[:user]
    not_if "#{cmd} --get #{k} |grep #{v}", :user => node[:user]
  end
end

#disable touchpad when typing
#see: http://ghantoos.org/2009/04/07/disable-touchpad-while-typing-on-keyboard/
execute "echo '/usr/bin/syndaemon -i 1 -d -S' >> ~/.xsession" do
  user node[:user]
  not_if "grep syndaemon ~/.xsession", :user => node[:user]
  only_if "which syndaemon"
end

#xfce4-terminal config
execute "echo 'BindingBackspace=TERMINAL_ERASE_BINDING_ASCII_DELETE' >> ~/.config/Terminal/terminalrc" do
  user node[:user]
  not_if "grep 'BindingBackspace' ~/.config/Terminal/terminalrc", :user => node[:user]
  only_if do node[:domain] == "home" end
end
