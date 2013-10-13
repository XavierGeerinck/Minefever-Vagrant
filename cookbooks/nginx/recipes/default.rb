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
# http://usefulmix.com/install-upgrade-to-latest-nginx-without-compiling-from-source/
#
# Still need to check if this works 100%!
execute "sudo add-apt-repository ppa:nginx/stable" do 
	user "root"
end

execute "sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys C300EE8C" do
	user "root"
end

execute "sudo apt-get update" do
	user "root"
end

package "nginx" do
	:upgrade
end

service  "nginx" do
	enabled true
	running true
	supports :status => true, :restart => true, :reload => true
	action [:start, :enable]
end

template "nginx.conf" do
	path "/etc/nginx/nginx.conf"
	source "nginx.conf.erb"
	owner "root"
	group "root"
	mode "0644"
	notifies :restart, resources(:service => "nginx")
end

cookbook_file "/etc/nginx/mime.types" do
	source "mime.types"
	mode 0640
	owner "root"
	group "root"
	notifies :restart, resources(:service => "nginx")
end