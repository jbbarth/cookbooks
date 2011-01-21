maintainer       "Jean-Baptiste Barth"
maintainer_email "jeanbaptiste.barth@gmail.com"
license          "Apache 2.0"
description      "Zsh the awesome shell"
version          "0.1"

%w(ubuntu debian redhat).each do |os|
  supports os
end
