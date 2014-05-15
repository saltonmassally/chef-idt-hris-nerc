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

cookbook_file "/etc/init.d/openoffice.sh" do
  source "openoffice.sh"
  action :create_if_missing
  mode 0755
end

supervisor_service "openoffice" do
  command "soffice '--accept=socket,host=127.0.0.1,port=8100,tcpNoDelay=1;urp;' --headless --nodefault --nofirststartwizard --nolockcheck --nologo --norestore"
  user 'nobody'
  autostart true
  autorestart true
end


# lets copy the file the openoffice files over t init.d and add to run levels
