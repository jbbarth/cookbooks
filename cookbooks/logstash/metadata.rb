maintainer       "Joshua Timberman"
maintainer_email "cookbooks@housepub.org"
license          "Apache 2.0"
description      "Installs/Configures logstash"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          "0.0.1"

%w{ java runit }.each do |cb|
  depends cb
end
