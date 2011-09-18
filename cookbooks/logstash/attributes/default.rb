#
# Cookbook Name:: logstash
# Attributes:: default
#
# Copyright 2011, Joshua Timberman
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

default['logstash']['version'] = "1.0.17"
default['logstash']['checksum'] = "caba048cb1ab3cc608d4569246f8b7effbb8272865c7864a662566c30517316c"
default['logstash']['install_path'] = "/opt/logstash"
