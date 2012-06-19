#!/bin/bash
set -e

if [ "$(id -u)" != 0 ]; then
  echo "I don't think you're root kid!" >&2
  exit 1
fi

if [ -s "/usr/local/rvm" ]; then
  echo "RVM already installed, quiting..."
  exit
fi

if test -e /etc/debian_version; then
  # package dependencies
  apt-get install -y build-essential bison openssl libreadline5 libreadline5-dev \
                     curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev \
                     libsqlite3-0 libsqlite3-dev sqlite3 libxml2-dev libxslt-dev \
                     autoconf libcurl4-openssl-dev file

  # rvm group
  groupadd -f -g 2001 rvm
fi

# install RVM
curl -L https://get.rvm.io | bash -s stable --ruby


if test -e /root/.bashrc && !grep "# RVM" /root/.bashrc >/dev/null; then
  echo -e "\n# RVM\nsource /usr/local/rvm/scripts/rvm" >> /root/.bashrc
  source /root/.bashrc
fi

if test -e /etc/skel/.bashrc && !grep "# RVM" /etc/skel/.bashrc >/dev/null; then
  sed -i 's/^.*PS1.*return$/if [[ -n "$PS1" ]]; then/' /etc/skel/.bashrc
  echo -e "\nfi #endof Interactive test\n# RVM\nsource /usr/local/rvm/scripts/rvm" >> /etc/skel/.bashrc
fi
