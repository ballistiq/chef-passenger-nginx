
# Ruby & RVM
default['passenger-nginx']['ruby_version'] = "2.1.0"
default['passenger-nginx']['rvm']['rvm_shell'] = '/etc/profile.d/rvm.sh'

# Nginx
default['passenger-nginx']['nginx']['worker_processes'] = 2

# Passenger
default['passenger-nginx']['passenger']['version'] = '4.0.53'
default['passenger-nginx']['passenger']['max_pool_size'] = 15
default['passenger-nginx']['passenger']['min_instances'] = 2
default['passenger-nginx']['passenger']['pool_idle_time'] = 300
default['passenger-nginx']['passenger']['max_instances_per_app'] = 0
# a list of URL's to pre-start.
default['passenger-nginx']['passenger']['pre_start'] = []

# Applications
default['passenger-nginx']['apps'] = []