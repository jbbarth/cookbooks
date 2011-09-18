Description
===========

Installs and configures Logstash with the monolithic jar.

* http://logstash.net/

Requirements
============

Platform: Tested on Ubuntu 10.04

Cookbooks from http://community.opscode.com

* runit
* java

And their dependencies.

Attributes
==========

* `node['logstash']['version']` - version of Logstash. Default 1.0.14.
* `node['logstash']['checksum']` - sha256sum of the monolithic jar.
* `node['logstash']['install_path']` - location where Logstash is installed. Default `/srv/logstash`.

Usage
=====

Include the logstash recipe on a node to get logstash installed. The webui and agent will be started by default under Runit.

To learn more about runit, see:

* http://smarden.org/runit

Limitations
===========

To name a few.

* only sets up monolithic logstash
* config file is a simple example and needs to be attribute driven
* runit is the only process manager supported right now

Future versions of this cookbook may dramatically alter its functionality, but always for great good.

License and Author
==================

Author:: Joshua Timberman (<cookbooks@housepub.org>)

Copyright 2011, Joshua Timberman

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
