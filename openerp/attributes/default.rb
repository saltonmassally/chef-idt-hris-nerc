default[:openerp][:apt_packages] = %w[
  libssl-dev
  libsasl2-dev
  libldap2-dev
  libxml2-dev 
  libxslt1-dev
  graphviz
  ghostscript
  poppler-utils
  openoffice.org-base
  openoffice.org-writer
  openoffice.org-calc
]

default[:openerp][:pip_packages] = %w[
  raven
  raven-sanitize-openerp
  wkhtmltopdf
  boto
  git+https://github.com/tarzan0820/zkemapi.git@master
  https://launchpad.net/aeroolib/trunk/1.0.0/+download/aeroolib.tar.gz
]
  
default[:openerp][:database][:name] = ''
default[:openerp][:database][:host] = 'False'
default[:openerp][:database][:password] = ''
default[:openerp][:database][:user] = ''
default[:openerp][:database][:maxconn] = 300
default[:openerp][:servername] = 'hris.sl'


default[:openerp][:data_dir] = '/mount/data'
default[:openerp][:db_filter] = '.*'
default[:openerp][:debug_mode] = 'False'
default[:openerp][:email_from] = 'no-reply@hris.sl'

default[:openerp][:admin_pass] = 'supersecret'
default[:openerp][:addon_path] = 'openerp/addons/'
default[:openerp][:sentry_dsn] = 'secret'
default[:openerp][:aws_access_key] = 'secret'
default[:openerp][:aws_secret_key] = 'secret'
default[:openerp][:aws_s3_bucket] = ''
default[:openerp][:static_http_document_root] = '/var/www/'
default[:openerp][:static_http_url_prefix]= '/static'


default[:openerp][:update_command] = 

override['supervisor']['inet_port'] = '9001'

override['nginx']['worker_processes'] = 4
override['nginx']['default_site_enabled'] = false
override['nginx']['gzip'] = 'on'

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


