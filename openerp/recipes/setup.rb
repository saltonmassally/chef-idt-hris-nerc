#
# Cookbook Name:: openerp
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "supervisor"
include_recipe "gunicorn"
include_recipe "nginx::repo"
include_recipe "nginx"
include_recipe "nginx::http_stub_status_module"
include_recipe "python"
include_recipe "openoffice::headless"
include_recipe "openoffice::apps"

include_recipe 'postgresql::client'

# lets set the python egg cache
directory "/tmp/python-eggs" do
  owner "root"
  group "root"
  mode 00777
  action :create
end

ENV['PYTHON_EGG_CACHE'] = '/tmp/python-eggs'

node[:openerp][:apt_packages].each do |pkg|
  package pkg do
    action :install
  end
end

# lets setup unoconv
git "#{Chef::Config[:file_cache_path]}/unoconv" do
  repository "https://github.com/dagwieers/unoconv.git"
  reference "master"
  action :sync
end

bash "install_unoconv_build" do
  cwd "#{Chef::Config[:file_cache_path]}/unoconv"
  code <<-EOH
    make install
  EOH
end

#ENV['UNO_PATH'] = '../program'

supervisor_service "start_unoconv" do
  command "unoconv --listener"
  user 'nobody'
  autostart true
  autorestart true
end


# lets copy the file the openoffice files over t init.d and add to run levels
