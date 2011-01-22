#
# Cookbook Name:: base
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

node[:user] ||= "salvor"

#apt packages
list = %w(mplayer gstreamer0.10-ffmpeg gstreamer0.10-plugins-bad gstreamer0.10-plugins-ugly ibam cryptsetup
          ttf-mscorefonts-installer ttf-liberation ttf-dejavu libgsf-bin imagemagick mplayerthumbs irssi
          xul-ext-firebug xchm wicd w32codecs conky colordiff p7zip xsel xfce4-terminal)

execute "apt-get update" do
  only_if { Time.now - File.mtime("/var/cache/apt/pkgcache.bin") > 3600*6 }
end

list.each do |pkg|
  apt_package pkg
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
