#
# Cookbook Name:: nginx
# Recipe:: default
#
# Copyright 2013, Feedient
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
execute "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10" do 
	user "root"
end

execute "echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/10gen.list" do 
	user "root"
end

execute "sudo apt-get update" do
	user "root"
end

package "mongodb-10gen" do
	:upgrade
end

directory "/var/lib/mongodb" do
	owner "mongodb"
	group "nogroup"
	mode 0755
	action :create
end

service  "mongodb" do
	enabled true
	running true
	supports :status => true, :restart => true
	action [ :enable, :start ]
end

cookbook_file "/etc/mongodb.conf" do
	source "mongodb.conf"
	mode 0640
	owner "mongodb"
	group "mongodb"
	notifies :restart, resources(:service => "mongodb")
end