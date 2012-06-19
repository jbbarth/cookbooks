#!/bin/bash
set -e

#exit if Xcode Command Line Tools not installed
test -e /usr/bin/gcc || (echo "Install Xcode Command Line Tools first!" >&2 && exit 1)

#install homebrew if not installed
test -e /usr/local/bin/brew || /usr/bin/ruby -e "$(/usr/bin/curl -fsSL https://raw.github.com/mxcl/homebrew/master/Library/Contributions/install_homebrew.rb)"

#update
brew update

#install utilities
brew install coreutils autoconf automake
brew install https://raw.github.com/Homebrew/homebrew-dupes/master/apple-gcc4.2.rb
