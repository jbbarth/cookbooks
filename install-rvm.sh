#!/bin/bash

if [ "$(id -u)" != 0 ]; then
  echo "Vous devez lancer ce script avec l'utilisateur root!" >&2
  exit 1
fi

aptitude install -y build-essential bison openssl libreadline5 libreadline5-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libcurl4-openssl-dev
bash < <( curl -L http://bit.ly/rvm-install-system-wide )
echo -e "\n# RVM\nsource /usr/local/lib/rvm" >> /root/.bashrc
source /root/.bashrc
sed -i 's/^.*PS1.*return$/if [[ -n "$PS1" ]]; then/' /etc/skel/.bashrc
echo -e "\nfi #endof Interactive test\n# RVM\nsource /usr/local/lib/rvm" >> /etc/skel/.bashrc
