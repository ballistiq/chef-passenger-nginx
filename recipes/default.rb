#
# Cookbook Name:: passenger-nginx
# Recipe:: default
#
# Copyright (C) 2014 Ballistiq Digital, Inc.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

node['passenger-nginx']['ruby_version'].prepend('ruby-') if node['passenger-nginx']['ruby_version'] =~ /^\d/

if platform_family?('debian')
  execute "apt-get update" do
    command "apt-get update"
    user "root"
  end

  # Install basic packages
  apt_package %w(git build-essential curl libcurl4-openssl-dev libpcre3 libpcre3-dev)
elsif platform_family?('rhel')
  # RHEL prereqs
   yum_package %w(git curl libcurl libcurl-devel pcre pcre-devel)
end

execute "Installing GPG keys so that RVM won't barf on installation" do
  command "gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3"
  user "root"
  not_if { File.exists? "/usr/local/rvm/bin/rvm" }
end

# Install RVM
execute "Installing RVM and Ruby" do
  command "curl -L https://get.rvm.io | bash -s stable"
  user "root"
  not_if { File.exists? "/usr/local/rvm/bin/rvm" }
end

# Add deploy user to rvm
user node['passenger-nginx']['nginx']['user'] do
  supports :manage_home => false
  shell "/sbin/nologin"
end

# Add nginx user to rvm group
group "rvm" do
  append true
  members node['passenger-nginx']['nginx']['user']
end

# Install RVM requirements
bash "Install RVM requirements" do
  code "source #{node['passenger-nginx']['rvm']['rvm_shell']} && rvm requirements"
  user "root"
end

# Install Ruby
bash "Install Ruby" do
  code "source #{node['passenger-nginx']['rvm']['rvm_shell']} && rvm install #{node['passenger-nginx']['ruby_version']}"
  user "root"
  not_if { Dir.exists? "/usr/local/rvm/rubies/#{node['passenger-nginx']['ruby_version']}" }
end

# Set default Ruby
bash "Set default Ruby" do
  code "source #{node['passenger-nginx']['rvm']['rvm_shell']} && rvm --default use #{node['passenger-nginx']['ruby_version']}"
  not_if { `bash -c "rvm list default string 2>/dev/null"`.strip.eql?(node['passenger-nginx']['ruby_version']) }
end

# Check for if we are installing Passenger Enterprise
passenger_enterprise = !!node['passenger-nginx']['passenger']['enterprise_download_token']

if passenger_enterprise
  bash "Installing Passenger Enterprise Edition" do
   code "rvm #{node['passenger-nginx']['ruby_version']} do gem install --source https://download:#{node['passenger-nginx']['passenger']['enterprise_download_token']}@www.phusionpassenger.com/enterprise_gems/ passenger-enterprise-server -v #{node['passenger-nginx']['passenger']['version']}"
    user "root"

    not_if { `bash -c "rvm-exec #{node['passenger-nginx']['ruby_version']} gem list -i passenger-enterprise-server -v #{node['passenger-nginx']['passenger']['version']} 2>/dev/null"` }
  end
else
  # Install Passenger open source
  bash "Installing Passenger Open Source Edition" do
    code "rvm #{node['passenger-nginx']['ruby_version']} do gem install passenger -v #{node['passenger-nginx']['passenger']['version']} --source https://rubygems.org"
    user "root"

    not_if { `bash -c "rvm-exec #{node['passenger-nginx']['ruby_version']} gem list -i passenger -v #{node['passenger-nginx']['passenger']['version']} 2>/dev/null"` }
  end
end

bash "Installing passenger nginx module and nginx from source" do
  code <<-EOF
  source #{node['passenger-nginx']['rvm']['rvm_shell']}
  passenger-install-nginx-module --auto --prefix=/opt/nginx --auto-download --extra-configure-flags="\"--with-http_gzip_static_module #{node['passenger-nginx']['nginx']['extra_configure_flags']}\""
  EOF
  user "root"
  not_if { File.exists? "/opt/nginx/sbin/nginx" }
end

# Create the config
if passenger_enterprise
  passenger_root = "/usr/local/rvm/gems/#{node['passenger-nginx']['ruby_version']}/gems/passenger-enterprise-server-#{node['passenger-nginx']['passenger']['version']}"
else
  passenger_root = "/usr/local/rvm/gems/#{node['passenger-nginx']['ruby_version']}/gems/passenger-#{node['passenger-nginx']['passenger']['version']}"
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
if platform_family?('debian')
  cookbook_file "/etc/init.d/nginx" do
    source "nginx.initd.debian"
    action :create
    mode 0755
  end
elsif platform_family?('rhel')
  cookbook_file "/etc/init.d/nginx" do
    source "nginx.initd.rhel"
    action :create
    mode 0755
  end
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

# Add any applications that we need
node['passenger-nginx']['apps'].each do |app|

  template "/opt/nginx/conf/sites-available/#{app[:name]}" do
    mode 0744
    action :create

    # Create the conf
    if app[:config_source]
      source app[:config_source]
    else
      source "nginx_app.conf.erb"
    end

    # If we are completely overriding the cookbook, use this:
    if app[:config_cookbook]
      cookbook app[:config_cookbook]
    end

    # Read custom config
    custom_config = if app['custom_config'] && app['custom_config'].kind_of?(Array)
      app['custom_config'].join "\n"
    else
      app['custom_config']
    end

    variables(
      listen: app['listen'] || 80,
      server_name: app['server_name'] || nil,
      root: app['root'] || "/opt/nginx/html",
      ssl_certificate: app['ssl_certificate'] || nil,
      ssl_certificate_key: app['ssl_certificate_key'] || nil,
      redirect_http_https: app['redirect_http_https'] || false,
      ruby_version: node['passenger-nginx']['ruby_version'] || nil,
      ruby_gemset: app['ruby_gemset'] || nil,
      app_env: app['app_env'] || nil,
      passenger_min_instances: app['passenger_min_instances'] || nil,
      passenger_max_instances: app['passenger_max_instances'] || nil,
      passenger_concurrency_model: app['passenger_concurrency_model'] || nil,
      passenger_thread_count: app['passenger_thread_count'] || nil,
      access_log: app['access_log'] || nil,
      error_log: app['error_log'] || nil,
      custom_config: custom_config || nil,
      client_max_body_size: app['client_max_body_size'] || nil,
      client_body_buffer_size: app['client_body_buffer_size'] || nil
    )
  end

  # Symlink the conf
  link "/opt/nginx/conf/sites-enabled/#{app[:name]}" do
    to "/opt/nginx/conf/sites-available/#{app[:name]}"
  end

  # Create the ruby gemset
  if node['passenger-nginx']['ruby_version'] && app['ruby_gemset']
    bash "Create Ruby Gemset" do
      code <<-EOF
      source #{node['passenger-nginx']['rvm']['rvm_shell']}
      rvm #{node['passenger-nginx']['ruby_version']} do rvm gemset create #{app['ruby_gemset']}
      EOF
      user "root"
      not_if { File.directory? "/usr/local/rvm/gems/#{node['passenger-nginx']['ruby_version']}@#{app['ruby_gemset']}" }
    end
  end
end

# Set up service to run by default
service 'nginx' do
  supports :status => true, :restart => true, :reload => true
  action [ :enable ]
end

# Restart(start) nginx
service "nginx" do
  action :restart 
end

