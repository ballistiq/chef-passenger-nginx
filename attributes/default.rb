# Ruby & RVM
default['passenger-nginx']['ruby_version'] = "2.3.3"
default['passenger-nginx']['rvm']['rvm_shell'] = '/etc/profile.d/rvm.sh'

# Nginx
default['passenger-nginx']['nginx']['extra_configure_flags'] = ""
default['passenger-nginx']['nginx']['worker_processes'] = 2
default['passenger-nginx']['nginx']['worker_connections'] = 1024
default['passenger-nginx']['nginx']['worker_rlimit_nofile'] = 4096
default['passenger-nginx']['nginx']['user'] = 'www-data'
default['passenger-nginx']['nginx']['access_log'] = 'logs/access.log'
default['passenger-nginx']['nginx']['error_log'] = 'logs/error.log'
default['passenger-nginx']['nginx']['http2'] = false

# Passenger
default['passenger-nginx']['passenger']['version'] = '4.1.1'
default['passenger-nginx']['passenger']['max_pool_size'] = 15
default['passenger-nginx']['passenger']['min_instances'] = 1
default['passenger-nginx']['passenger']['pool_idle_time'] = 300
default['passenger-nginx']['passenger']['max_instances_per_app'] = 0
default['passenger-nginx']['passenger']['rolling_restarts'] = nil

# Passenger Enterprise
default['passenger-nginx']['passenger']['enterprise_license'] = nil
default['passenger-nginx']['passenger']['enterprise_download_token'] = nil

# a list of URL's to pre-start.
default['passenger-nginx']['passenger']['pre_start'] = []

# Applications
default['passenger-nginx']['apps'] = []
