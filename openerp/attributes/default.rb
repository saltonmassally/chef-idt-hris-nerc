default[:openerp][:apt_packages] = %w[
  libssl-dev
  libsasl2-dev
  libldap2-dev
  libxml2-dev 
  libxslt1-dev
  libjpeg-dev
  libjpeg8-dev
  graphviz
  libevent-dev
  ghostscript
  poppler-utils
]

  # git+https://github.com/tarzan0820/zkemapi.git@master
default[:openerp][:pip_packages] = %w[
  raven
  raven-sanitize-openerp
  phonenumbers
  wkhtmltopdf
  subprocess32
  boto  
  unidecode
  numpy
  dedupe
  datadiff
  https://launchpad.net/aeroolib/trunk/1.0.0/+download/aeroolib.tar.gz
  gevent
]
  
#default[:openerp][:database][:name] = node[:opsworks][:stack][:rds_instances][:db_name]
#default[:openerp][:database][:host] = node[:opsworks][:stack][:address]
#default[:openerp][:database][:password] = ''
#default[:openerp][:database][:port] = node[:opsworks][:stack][:port]
#default[:openerp][:database][:user] = node[:opsworks][:stack][:db_user]
default[:openerp][:database][:maxconn] = 300
default[:openerp][:servername] = 'nercpay.sl'


default[:openerp][:data_dir] = '/mnt/data'
default[:openerp][:db_filter] = '^nerc$'
default[:openerp][:debug_mode] = 'False'
default[:openerp][:email_from] = 'no-reply@nercpay.sl'

default[:openerp][:admin_pass] = 'supersecret'
default[:openerp][:addon_path] = 'openerp/addons/'
default[:openerp][:sentry_dsn] = 'secret'
default[:openerp][:aws_access_key] = 'secret'
default[:openerp][:aws_secret_key] = 'secret'
default[:openerp][:route53_zone_id] = ''
default[:openerp][:domain] = ''
default[:openerp][:workers] = 0
default[:openerp][:elastic_ip] = ''
default[:openerp][:static_http_document_root] = '/var/www/'
default[:openerp][:static_http_url_prefix]= '/static'

default[:openerp][:ssl_public] = '/etc/nginx/ssh/server.crt'
default[:openerp][:ssl_private] = '/etc/nginx/ssh/server.pem'

default[:openerp][:openoffice_deb_url]  = 'http://freefr.dl.sourceforge.net/project/openofficeorg.mirror/4.1.1/binaries/en-US/Apache_OpenOffice_4.1.1_Linux_x86-64_install-deb_en-US.tar.gz'
 
default[:openerp][:update_command] = ''

override['supervisor']['inet_port'] = '9001'

override['nginx']['worker_processes'] = 4
override['nginx']['default_site_enabled'] = false
override['nginx']['gzip'] = 'on'

override['postgresql']['enable_pgdg_apt'] = true 
override['postgresql']['version'] = '9.3'
override[:chef_ec2_ebs_snapshot][:description] = "data.nerc.sl data directory Backup $(date +'%Y-%m-%d %H:%M:%S')"

#set the ff in stack settings
# node['supervisor']['inet_username']
# node['supervisor']['inet_password']
#
#
#
#
#
#
#


