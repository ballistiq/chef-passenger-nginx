# Chef passenger-nginx Cookbook

Chef cookbook for provisioning Ruby (RVM), Passenger (Open Source and Enterprise editions) and Nginx.

## Supported Platforms

* Ubuntu
* RHEL (Redhat, Oracle, Centos, Scientific)

## Quick Start Guide

For the impatient:

### 1. Install Knife Solo

```bash
gem install knife-solo
```

Note: Please read http://matschaffer.github.io/knife-solo/ for more info about Knife Solo.


### 2. Prepare a new chef/knife solo project

```bash
knife solo init <my-project-name>
```

chdir into your new folder

### 3. Add the passenger-nginx cookbook

Add the following line to the file `Berksfile`:


```ruby
cookbook "passenger-nginx", git: "https://github.com/ballistiq/chef-passenger-nginx.git"
```

Run `berks install`

Note: Please refer to http://berkshelf.com/ to read more about using Berkshelf to manage cookbooks.


### 4. Add and configure the node

In our example, we'll use vagrant running on `localhost`. The name of the json file should correspond to your hostname. E.g. if you are deploying to server1.ballistiq.com, it should be `server1.ballistiq.com.json`.

So we would create a file `/nodes/localhost.json`:


```json
{
  "run_list": [
    "recipe[passenger-nginx]"
  ],

  "passenger-nginx": {
    "ruby_version": "2.1.0",
    "passenger": {
      "version": "4.0.53"
    },
    "apps": [
      {
        "name": "my-application",
        "server_name": "example.com www.example.com",
        "listen": 80,
        "root": "/var/www/my-application",
        "ruby_gemset": "my-application",
        "app_env": "staging"
      }
    ]
  }
}
```

### 5. Prepare the server

We use `knife solo` to prepare and cook the server. Alter the following command to use your username, server host and port.

Preparation copies Chef to the server.

```
knife solo prepare vagrant@localhost -p 2222
```


### 6. Cook the server

Cooking actually runs your recipes on the server.

```
knife solo cook vagrant@localhost -p 2222
```

Once this is done, it should have installed RVM, Ruby, Passenger, Nginx and configured an application for you.

Now you can run your Capistrano scripts to deploy to the server and off you go.


## Need to make changes to the cookbook?

If you are configuring an application that has some funky requirements and need to change some stuff in this cookbook, clone the repository and copy it to `site-cookbooks`. Remove it from the Berksfile as you are now using the version in your project. Make any edits and enjoy.


## Important Attributes

<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['ruby_version']</tt></td>
    <td>String</td>
    <td>Numerical string of Ruby version</td>
    <td><tt>2.1.0</tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['version']</tt></td>
    <td>String</td>
    <td>Passenger Gem Version</td>
    <td><tt>4.0.53</tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['enterprise_download_token']</tt></td>
    <td>String</td>
    <td>If using Passenger Enterprise, log in to the customer area and get the download token. This will give the recipe access to download the Enterprise Gem from Phusion directly.</td>
    <td><tt>nil</tt></td>
  </tr>
</table>

## Attributes for Configuring Applications in Nginx
<table>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['apps']</tt></td>
    <td>Array</td>
    <td>Array of applications to configure</td>
    <td><tt>[]</tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['apps'][n]['config_source']</tt></td>
    <td>String</td>
    <td>Override the source of the config file. Used for completely custom configs. E.g. app1.conf.erb</td>
    <td><tt>nginx_app.conf.erb</tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['apps'][n]['config_cookbook']</tt></td>
    <td>String</td>
    <td>Override the cookbook of your custom config.</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['apps'][n]['name']</tt></td>
    <td>String</td>
    <td>name-of-your-application-like-this</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['apps'][n]['server_name']</tt></td>
    <td>String</td>
    <td>Name-based virtual hosting: "example.com www.example.com"</td>
    <td><tt>nil</tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['apps'][n]['listen']</tt></td>
    <td>Integer</td>
    <td>What port to listen to: e.g. 80</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['apps'][n]['root']</tt></td>
    <td>String</td>
    <td>Path to application: e.g. "/var/www/my-application"</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['apps'][n]['ruby_gemset']</tt></td>
    <td>String</td>
    <td>Use a specific gemset for the application.</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['apps'][n]['app_env']</tt></td>
    <td>String</td>
    <td>Environment to run your app. E.g. 'staging'</td>
    <td><tt>production</tt></td>
  </tr>

  <tr>
    <td><tt>['passenger-nginx']['passenger']['apps'][n]['passenger_min_instances']</tt></td>
    <td>Integer</td>
    <td>[https://www.phusionpassenger.com/documentation/Users%20guide%20Nginx.html#PassengerMinInstances](https://www.phusionpassenger.com/documentation/Users%20guide%20Nginx.html#PassengerMinInstances)</td>
    <td><tt>1</tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['apps'][n]['passenger_max_instances']</tt></td>
    <td>Integer</td>
    <td>[https://www.phusionpassenger.com/documentation/Users%20guide%20Nginx.html#PassengerMaxInstances](https://www.phusionpassenger.com/documentation/Users%20guide%20Nginx.html#PassengerMaxInstances)</td>
    <td><tt>0</tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['apps'][n]['passenger_concurrency_model']</tt></td>
    <td>String</td>
    <td>[https://www.phusionpassenger.com/documentation/Users%20guide%20Nginx.html#PassengerConcurrencyModel](https://www.phusionpassenger.com/documentation/Users%20guide%20Nginx.html#PassengerConcurrencyModel)</td>
    <td><tt>process</tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['apps'][n]['passenger_thread_count']</tt></td>
    <td>Integer</td>
    <td>[https://www.phusionpassenger.com/documentation/Users%20guide%20Nginx.html#PassengerThreadCount](https://www.phusionpassenger.com/documentation/Users%20guide%20Nginx.html#PassengerThreadCount)</td>
    <td><tt>1</tt></td>
  </tr>

  <tr>
    <td><tt>['passenger-nginx']['passenger']['apps'][n]['ssl_certificate']</tt></td>
    <td>String</td>
    <td>Path to SSL certificate: e.g. "/opt/nginx/keys/app.bundle.crt"</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['apps'][n]['ssl_certificate_key']</tt></td>
    <td>String</td>
    <td>Path to SSL certificate key: e.g. "/opt/nginx/keys/app.key"</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['apps'][n]['redirect_http_https']</tt></td>
    <td>Boolean</td>
    <td>If you want to redirect requests on port 80 to https:// (443) then set this to true.</td>
    <td><tt>false</tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['apps'][n]['client_body_buffer_size']</tt></td>
    <td>String</td>
    <td>See: http://nginx.org/en/docs/http/ngx_http_core_module.html#client_body_buffer_size</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['apps'][n]['client_max_body_size']</tt></td>
    <td>String</td>
    <td>See: http://nginx.org/en/docs/http/ngx_http_core_module.html#client_max_body_size</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['apps'][n]['custom_config']</tt></td>
    <td>String or Array</td>
    <td>Any additional Nginx configuration that you want for the app.</td>
    <td><tt>
E.g.

```
"custom_config": [
  "expires max;",
  "location ~* \\.(eot|ttf|woff)$ {",
  "  add_header Access-Control-Allow-Origin *;",
  "}"
```
    </tt></td>
  </tr>

  <tr>
    <td><tt>['passenger-nginx']['passenger']['apps'][n]['access_log']</tt></td>
    <td>String</td>
    <td>Location for access log</td>
    <td><tt>nil - defaults to global access log</tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['apps'][n]['error_log']</tt></td>
    <td>String</td>
    <td>Location for error log</td>
    <td><tt>nil - defaults to global error log</tt></td>
  </tr>
</table>

## Attributes for Tuning
<table>
  <tr>
    <td><tt>['passenger-nginx']['nginx']['user']</tt></td>
    <td>String</td>
    <td>User to run Nginx as</td>
    <td><tt>www-data</tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['nginx']['extra_configure_flags']</tt></td>
    <td>String</td>
    <td>Compile additional modules. E.g. "--with-http_gzip_static_module"</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['nginx']['worker_processes']</tt></td>
    <td>Integer</td>
    <td>Number of Nginx worker processes to run</td>
    <td><tt>2</tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['nginx']['access_log']</tt></td>
    <td>String</td>
    <td>Location for access log. "off" to not use this.</td>
    <td><tt>logs/access.log</tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['nginx']['error_log']</tt></td>
    <td>String</td>
    <td>Location for error log. "off" to not use this.</td>
    <td><tt>logs/error.log</tt></td>
  </tr>


  <tr>
    <td><tt>['passenger-nginx']['passenger']['rolling_restarts']</tt></td>
    <td>String</td>
    <td>If using Passenger Enterprise, this enables rolling restarts. Can be 'on' or 'off'.</td>
    <td><tt>off</tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['max_pool_size']</tt></td>
    <td>Integer</td>
    <td>Max Passenger pool size</td>
    <td><tt>15</tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['min_instances']</tt></td>
    <td>Integer</td>
    <td>Minimum number of instances of Passenger to run</td>
    <td><tt>2</tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['pool_idle_time']</tt></td>
    <td>Integer</td>
    <td>Pool idle time</td>
    <td><tt>300</tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['max_instances_per_app']</tt></td>
    <td>Integer</td>
    <td>Max instances per app</td>
    <td><tt>0</tt></td>
  </tr>
</table>

## Usage

### Basic Usage

Include `passenger-nginx` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[passenger-nginx]"
  ],

  "passenger-nginx": {
    "ruby_version": "2.1.0",
    "passenger": {
      "version": "4.0.53"
    },
    "apps": [
      {
        "name": "my-application",
        "server_name": "example.com www.example.com",
        "listen": 80,
        "root": "/var/www/my-application",
        "ruby_gemset": "my-application",
        "app_env": "staging"
      }
    ]
  }
}
```

### Passenger Enterprise

1. You must install the license key yourself as `/etc/passenger-enterprise-license`. This cookbook will not install the license key for you.

2. Get the download token from Phusion's customer area and add it as an attribute as seen below.


```json
{
  "run_list": [
    "recipe[passenger-nginx]"
  ],

  "passenger-nginx": {
    "ruby_version": "2.1.0",
    "passenger": {
      "version": "4.0.53",
      "enterprise_download_token": "xxxxxxxxxxxxxxxxxx"
    },
    "apps": [
      {
        "name": "my-application",
        "server_name": "example.com www.example.com",
        "listen": 80,
        "root": "/var/www/my-application",
        "ruby_gemset": "my-application"
      }
    ]
  }
}
```


### SSL Certificates and Keys

1. You must install the certificate and key yourself. This cookbook will not install them for you.

2. Add the absolute paths as attributes as seen below.


```json
{
  "run_list": [
    "recipe[passenger-nginx]"
  ],

  "passenger-nginx": {
    "ruby_version": "2.1.0",
    "passenger": {
      "version": "4.0.53",
      "enterprise_download_token": "xxxxxxxxxxxxxxxxxx"
    },
    "apps": [
      {
        "name": "my-secure-application",
        "server_name": "example.com www.example.com",
        "listen": 443,
        "root": "/var/www/my-application",
        "ruby_gemset": "my-application",
        "ssl_certificate": "/opt/nginx/keys/app.bundle.crt",
        "ssl_certificate_key": "/opt/nginx/keys/app.key",
        "redirect_http_https": true
      }
    ]
  }
}
```

## Changelog

**21 April 2015 - 0.9.15** - Enabled totally custom config files.

**16 February 2015 - 0.9.14** - Made server_name var optional.

**15 January 2015 - 0.9.13** - Added internal monitoring.

**4 December 2014 - 0.9.12** - Added PCRE packages to installation to ensure that Nginx installation has a clean run.

**25 November 2014 - 0.9.11** - Custom configs can now be passed in an array, for longer custom configurations.

**17 November 2014 - 0.9.10** - Added options for `client_max_body_size` and `client_body_buffer_size`

**17 November 2014 - 0.9.9** - Made Gzip static default

**17 November 2014 - 0.9.8** - Fixed bug with no extra configure flags causing script to barf.

**14 November 2014 - 0.9.7** - Added Nginx extra configure flags to attributes.

**11 November 2014 - 0.9.6** - Added libcurl4-openssl-dev to apt packages. Required by Passenger...

**11 November 2014 - 0.9.5** - Fixed issue with apt eager installing packages. RVM will automatically install required packages.

**8 November 2014 - 0.9.4** - Fixed bug with rolling restarts directive barfing on open source edition of Passenger (even if it says 'off').

**5 November 2014 - 0.9.3** - Added rolling restarts to Passenger. Recipe now creates gemsets if they are defined.

**4 November 2014 - 0.9.2** - Fixed issue with Passenger not starting because Ruby is not running via a wrapper. Added app variables `app_env` to set environment, `ruby_gemset` to set a specific gemset for the application and `custom_config` to allow any additional custom configuration that you want passed into Nginx.

**3 November 2014 - 0.9.1** - Install GPG keys before attempting to install RVM. New RVM appears to have changed keys which was causing failure on run. Default Ruby is now 2.1.4.



## License and Authors

Author:: Leonard Teo (<leonard@ballistiq.com>)

This is licensed under the MIT license. Enjoy!

Copyright (C) 2014 Ballistiq Digital, Inc.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
