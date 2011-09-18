#!/bin/bash
source "/usr/local/rvm/scripts/rvm" || exit 1
cd /var/chef
if ! git show $(git ls-remote origin master|awk '{print $1}') >/dev/null; then
  git pull origin master 2>&1 | sed 's/^/COOKBOOKS UPDATE: /'
fi
rvm 1.9.2@chef
chef-solo $* 2>&1|grep -v -e "INFO: Processing" -e "INFO: Run List" -e "INFO: Setting the run_list" \
                          -e "^Gem::SourceIndex" -e "^NOTE: Gem::SourceIndex" -e "Gem.source_index"
