#!/bin/bash

# This script install chef with rubygems

# You have to install RVM first
if [ -s "$HOME/.rvm/scripts/rvm" ]; then
  source "$HOME/.rvm/scripts/rvm"
elif [ -s "/usr/local/rvm/scripts/rvm" ]; then
  source "/usr/local/rvm/scripts/rvm"
else
  echo "Install RVM first !" >&2
  exit 1
fi

# We work with ruby 1.9.2!
if ! rvm list|grep 1.9.2 >/dev/null 2>/dev/null; then
  echo "Install ruby 1.9.2: rvm install 1.9.2" >&2
  exit 1
fi

# Credentials
user="root"
group=$(id -g)

# Create a gemset
rvm 1.9.2@chef --create

# Install latest chef from rubygems.org
gem install chef

# Create chef cookbooks directory (/var/chef/cookbooks)
sudo mkdir -p /var/chef
sudo chown -R $user:$group /var/chef
sudo find /var/chef -type d -exec chmod 2775 {} \;
sudo find /var/chef -type f -exec chmod og+rw {} \;

# Populate it!
cd /var/chef
[ -d .git ] || git init
git remote|grep origin >/dev/null || git remote add origin git://github.com/jbbarth/cookbooks.git
git pull origin master

# Define chef configuration (/etc/chef)
sudo mkdir -p /etc/chef
sudo chown -R $user:$group /etc/chef
sudo find /etc/chef -type d -exec chmod 2775 {} \;
sudo find /etc/chef -type f -exec chmod og+rw {} \;
echo 'json_attribs "/etc/chef/dna.json"' > /etc/chef/solo.rb
echo -e '{\n  "recipes": ["base"]\n}' > /etc/chef/dna.json
