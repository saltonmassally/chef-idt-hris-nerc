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

include_recipe 'deploy'

node[:deploy].each do |application, deploy|
   if deploy[:application_type] != 'other'
     Chef::Log.debug("Skipping deploy::other application #{application} as it is not an other app")
     next
   end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  node[:openerp][:pip_packages].each do |pkg|
    python_pip pkg do
      action :install
    end
  end

  script 'execute_setup' do
    interpreter "bash"
    user "root"
    cwd deploy[:absolute_document_root]
    code "python setup.py install"
  end

# lets bring back sanity
  bash "fix_packages" do
    cwd '/tmp'
    code <<-EOH
    wget http://python-distribute.org/distribute_setup.py
    python distribute_setup.py
    EOH
  end

  template "#{deploy[:absolute_document_root]}openerp-wsgi.py" do
    source "openerp-wsgi.py.erb"
    owner deploy[:user]
    group deploy[:group]
    mode "0644"
    action :create
    variables(
      :deploy_path => deploy[:absolute_document_root],
      :log_file =>  "#{deploy[:absolute_document_root]}/shared/log/openerp.log",
      :pid_file =>  "#{deploy[:absolute_document_root]}/shared/pid/gunicorn.pid"
    )    
  end

  template "#{deploy[:absolute_document_root]}openerp/conf/openerp.conf" do
    source "openerp.conf.erb"
    owner deploy[:user]
    group deploy[:group]
    mode "0644"
    action :create
    variables(
      :deploy_path => deploy[:absolute_document_root],
      :log_file =>  "#{deploy[:absolute_document_root]}/shared/log/openerp.log",
      :pid_file =>  "#{deploy[:absolute_document_root]}/shared/pid/gunicorn.pid"
    ) 
  end

  supervisor_service "gunicorn" do
    command "gunicorn openerp:service.wsgi_server.application -c #{deploy[:absolute_document_root]}openerp-wsgi.py"
    directory deploy[:absolute_document_root]
    user deploy[:user]
    autostart true
    autorestart true
  end

  template "/etc/nginx/sites-enabled/ngnix-openerp" do
    source "ngnix-openerp.conf.erb"
    variables({
      :deploy_path => deploy[:absolute_document_root],
    })
    notifies :reload, 'service[nginx]'
  end

  nginx_site "ngnix-openerp" do
    enable true
  end

  cron "openerp_cron" do
    command "cd #{deploy[:absolute_document_root]}; python oe cron ----addons #{deploy[:absolute_document_root]}openerp/addons"
    minute "*/5"
  end

  

end


