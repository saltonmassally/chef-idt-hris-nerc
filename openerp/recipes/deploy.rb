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

# lets ensure that pillow will
  bash "correct_for_pillow" do
    code <<-EOH
    ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib
    ln -s /usr/lib/x86_64-linux-gnu/libfreetype.so /usr/lib
    ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib
    EOH
  end

  # create data dir if for some reason its not there
  directory node[:openerp][:data_dir] do
    owner deploy[:user]
    group deploy[:group]
    mode 00755
    action :create
    not_if { ::File.exists?(node[:openerp][:data_dir]) }
  end

# lets ensure that the data dir is writable
  bash "correct_directory_permission" do
    command "chown {deploy[:user]}:{deploy[:group]} {node[:openerp][:data_dir]}; chmod 775 {node[:openerp][:data_dir]}"
    only_if { ::File.exists?(node[:openerp][:data_dir]) }
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
      :log_file =>  "#{deploy[:deploy_to]}/shared/log/openerp.log",
      :pid_file =>  "#{deploy[:deploy_to]}/shared/pids/openerp.pid",
      :database => deploy[:database]
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
      :log_file =>  "#{deploy[:deploy_to]}/shared/log/openerp.log",
      :pid_file =>  "#{deploy[:deploy_to]}/shared/pids/openerp.pid",
      :database => deploy[:database]
    ) 
  end

  supervisor_service "gunicorn" do
    command "gunicorn openerp:service.wsgi_server.application -c openerp-wsgi.py"
    directory deploy[:absolute_document_root]
    user deploy[:user]
    autostart true
    autorestart true
    environment {:PYTHON_EGG_CACHE => "/tmp/python-eggs",
                 :UNO_PATH => "/usr/lib/libreoffice/program/",
		 :PYTHONPATH => "/usr/local/lib/python2.7/dist-packages:/usr/local/lib/python2.7/site-packages"
		}
  end

  template "/etc/nginx/sites-enabled/sngnix-openerp" do
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
    command "cd #{deploy[:absolute_document_root]}; python oe cron --addons #{deploy[:absolute_document_root]}openerp/addons"
    minute "*/5"
  end

  

end


