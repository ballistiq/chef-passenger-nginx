#
# Cookbook Name:: passenger-nginx
# Recipe:: default
#
# Copyright (C) 2014 Ballistiq Digital, Inc.
#
# All rights reserved - Do Not Redistribute
#

execute "apt-get update" do
  command "apt-get update"
  user "root"
end

# Install every conceivable thing we need for this to compile
%w(git build-essential zlib1g-dev libssl-dev libreadline-dev libyaml-dev libcurl4-openssl-dev curl git-core python-software-properties libsqlite3-dev libmysql++-dev).each do |pkg|
  apt_package pkg  
end

# Install Ruby - system wide RVM
execute "Installing RVM and Ruby" do
  command "curl -L https://get.rvm.io | bash -s stable --rails --autolibs=enabled --ruby=ruby-#{node['passenger-nginx']['ruby_version']}"
  user "root"
  not_if { File.directory? "/usr/local/rvm" }
end

# Check for if we are installing Passenger Enterprise
passenger_enterprise = !!node['passenger-nginx']['passenger']['enterprise_download_token']

if passenger_enterprise
  bash "Installing Passenger Enterprise Edition" do
    code <<-EOF
    source #{node['passenger-nginx']['rvm']['rvm_shell']}
    gem install --source https://download:#{node['passenger-nginx']['passenger']['enterprise_download_token']}@www.phusionpassenger.com/enterprise_gems/ passenger-enterprise-server -v #{node['passenger-nginx']['passenger']['version']}
    EOF
    user "root"

    regex = Regexp.escape("passenger-enterprise-server (#{node['passenger-nginx']['passenger']['version']})")
    not_if { `bash -c "source #{node['passenger-nginx']['rvm']['rvm_shell']} && gem list"`.lines.grep(/^#{regex}/).count > 0 }
  end
else
  # Install Passenger open source
  bash "Installing Passenger Open Source Edition" do
    code <<-EOF
    source #{node['passenger-nginx']['rvm']['rvm_shell']}
    gem install passenger -v #{node['passenger-nginx']['passenger']['version']}
    EOF
    user "root"

    regex = Regexp.escape("passenger (#{node['passenger-nginx']['passenger']['version']})")
    not_if { `bash -c "source #{node['passenger-nginx']['rvm']['rvm_shell']} && gem list"`.lines.grep(/^#{regex}/).count > 0 }
  end
end

bash "Installing passenger nginx module and nginx from source" do
  code <<-EOF
  source #{node['passenger-nginx']['rvm']['rvm_shell']}
  passenger-install-nginx-module --auto --prefix=/opt/nginx --auto-download
  EOF
  user "root"
  not_if { File.directory? "/opt/nginx" }
end

# Create the config
if passenger_enterprise
  passenger_root = "/usr/local/rvm/gems/ruby-#{node['passenger-nginx']['ruby_version']}/gems/passenger-enterprise-server-#{node['passenger-nginx']['passenger']['version']}"
else
  passenger_root = "/usr/local/rvm/gems/ruby-#{node['passenger-nginx']['ruby_version']}/gems/passenger-#{node['passenger-nginx']['passenger']['version']}"
end

template "/opt/nginx/conf/nginx.conf" do
  source "nginx.conf.erb"
  variables({
    :ruby_version => node['passenger-nginx']['ruby_version'],
    :rvm => node['rvm'],
    :passenger_root => passenger_root,
    :passenger => node['passenger-nginx']['passenger'],
    :nginx => node['passenger-nginx']['nginx']
  })
end

# Install the nginx control script
cookbook_file "/etc/init.d/nginx" do
  source "nginx.initd"
  action :create
  mode 0755
end

# Add log rotation
cookbook_file "/etc/logrotate.d/nginx" do
  source "nginx.logrotate"
  action :create
end

directory "/opt/nginx/conf/sites-enabled" do
  mode 0755
  action :create
  not_if { File.directory? "/opt/nginx/conf/sites-enabled" }
end

directory "/opt/nginx/conf/sites-available" do
  mode 0755
  action :create
  not_if { File.directory? "/opt/nginx/conf/sites-available" }
end

# Set up service to run by default
service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable ]
end

# Add any applications that we need
node['passenger-nginx']['apps'].each do |app|
  # Create the conf
  template "/opt/nginx/conf/sites-available/#{app[:name]}" do
    source "nginx_app.conf.erb"
    mode 0744
    action :create
    variables(
      listen: app['listen'] || 80,
      server_name: app['server_name'] || "localhost",
      root: app['root'] || "/opt/nginx/html",
      ssl_certificate: app['ssl_certificate'] || nil,
      ssl_certificate_key: app['ssl_certificate_key'] || nil,
      redirect_http_https: app['redirect_http_https'] || false
    )
  end

  # Symlink the conf
  link "/opt/nginx/conf/sites-enabled/#{app[:name]}" do
    to "/opt/nginx/conf/sites-available/#{app[:name]}"
  end
end

# Restart/start nginx
service "nginx" do
  action :restart
  only_if { File.exists? "/opt/nginx/logs/nginx.pid" }
end

service "nginx" do
  action :start
  not_if { File.exists? "/opt/nginx/logs/nginx.pid" }
end
