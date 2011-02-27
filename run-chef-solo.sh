#!/bin/bash
source "/usr/local/rvm/scripts/rvm" || exit 1
cd /var/chef; git pull origin master 2>&1 | sed 's/^/COOKBOOKS UPDATE: /'
rvm 1.9.2@chef
chef-solo $*
