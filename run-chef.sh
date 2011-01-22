#!/bin/bash
source "/usr/local/rvm/scripts/rvm" || exit 1
rvm 1.9.2@chef
chef-solo
