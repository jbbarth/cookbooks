#!/bin/bash
set -e

# This script installs chef with rubygems

# RVM VERSION
if [ -s "/usr/local/rvm/scripts/rvm" ]; then
  source "/usr/local/rvm/scripts/rvm"
  # We work with ruby 1.9.3!
  if ! rvm list|grep 1.9.3 >/dev/null 2>/dev/null; then
    echo "Install ruby 1.9.3: rvm install 1.9.3" >&2
    exit 1
  fi
  # Create a gemset
  rvm 1.9.3@chef --create

# RBENV VERSION
elif which rbenv >/dev/null 2>&1; then
  # We work with ruby 1.9.3!
  if ! rbenv version-name|grep 1.9.3 >/dev/null 2>/dev/null; then
    echo "Install ruby 1.9.3: rbenv install 1.9.3-p194" >&2
    exit 1
  fi
  # Create a gemset
  rbenv gemset list | grep chef>/dev/null || rbenv gemset create $(rbenv version-name) chef
else
  echo "Install RVM or Rbenv first !" >&2
  exit 1
fi

# Credentials
user="jbbarth"
group="staff"

# Install latest chef from rubygems.org
gem install chef --version 10.32.2 --no-ri --no-rdoc

# Create chef cookbooks directory (/var/chef/cookbooks)
sudo mkdir -p /var/chef
sudo chown -R $user:$group /var/chef
sudo find /var/chef -type d -exec chmod 2775 {} \;
sudo find /var/chef -type f -exec chmod ug+rw,o-rwx {} \;

# Populate it!
cd /var/chef
[ -d .git ] || git init
git remote|grep origin >/dev/null || git remote add origin https://github.com/jbbarth/cookbooks.git
git pull origin master

# Define chef configuration (/etc/chef)
sudo mkdir -p /etc/chef
sudo chown -R $user:$group /etc/chef
sudo find /etc/chef -type d -exec chmod 2775 {} \;
sudo find /etc/chef -type f -exec chmod ug+rw,o-rwx {} \;
[ -s "/etc/chef/solo.rb" ] || echo 'json_attribs "/etc/chef/dna.json"' > /etc/chef/solo.rb
[ -s "/etc/chef/dna.json" ] || echo -e '{\n  "recipes": ["base"]\n}' > /etc/chef/dna.json
