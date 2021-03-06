maintainer       "Jean-Baptiste Barth"
maintainer_email "jeanbaptiste.barth@gmail.com"
license          "Apache 2.0"
description      "Creates users defined locally with chef-solo"
long_description "Creates users defined in /etc/chef/users.json file ; recipe adapted from Opscode standard users recipe, available at http://github.com/opscode/cookbooks"
version          "0.0.1"

%w(debian ubuntu).each do |os|
  supports os
end
