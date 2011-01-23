#!/bin/bash
source "/usr/local/rvm/scripts/rvm" || exit 1
cd /var/chef; git pull origin master >/dev/null 2>&1
rvm 1.9.2@chef
chef-solo
