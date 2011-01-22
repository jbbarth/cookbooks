maintainer       "Jean-Baptiste Barth"
maintainer_email "jeanbaptiste.barth@gmail.com"
license          "Apache 2.0"
description      "Installs/Configures sudo"
long_description IO.read(File.join(File.dirname(__FILE__), 'README.rdoc'))
version          "0.1"

%w(debian ubuntu).each do |os|
  supports os
end
