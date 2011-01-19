#!/bin/bash

if [ "$(id -u)" != 0 ]; then
  echo "Vous devez lancer ce script avec l'utilisateur root!" >&2
  exit 1
fi

if [ -s "/usr/local/lib/rvm" ]; then
  echo "RVM already installed, quiting..."
  exit
fi

aptitude install -y build-essential bison openssl libreadline5 libreadline5-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libcurl4-openssl-dev file
bash < <( curl -L http://bit.ly/rvm-install-system-wide )

if ! grep "# RVM" /root/.bashrc >/dev/null; then
  echo -e "\n# RVM\nsource /usr/local/lib/rvm" >> /root/.bashrc
  source /root/.bashrc
fi

if ! grep "# RVM" /etc/skel/.bashrc >/dev/null; then
  sed -i 's/^.*PS1.*return$/if [[ -n "$PS1" ]]; then/' /etc/skel/.bashrc
  echo -e "\nfi #endof Interactive test\n# RVM\nsource /usr/local/lib/rvm" >> /etc/skel/.bashrc
fi
