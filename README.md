# passenger-nginx-cookbook

Chef recipe for provisioning Ruby (RVM), Passenger, Nginx and Ruby applications to serve. 

## Supported Platforms

* Ubuntu

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
    <td><tt>['passenger-nginx']['passenger']['apps'][n]['name']</tt></td>
    <td>String</td>
    <td>name-of-your-application-like-this</td>
    <td><tt></tt></td>
  </tr>
  <tr>
    <td><tt>['passenger-nginx']['passenger']['apps'][n]['server_name']</tt></td>
    <td>String</td>
    <td>Name-based virtual hosting: "example.com www.example.com"</td>
    <td><tt></tt></td>
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
    <td><tt>['passenger-nginx']['nginx']['worker_processes']</tt></td>
    <td>Integer</td>
    <td>Number of Nginx worker processes to run</td>
    <td><tt>2</tt></td>
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
        "root": "/var/www/my-application"
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
        "root": "/var/www/my-application"
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
        "ssl_certificate": "/opt/nginx/keys/app.bundle.crt",
        "ssl_certificate_key": "/opt/nginx/keys/app.key",
        "redirect_http_https": true
      }
    ]
  }
}
```



## License and Authors

Author:: Leonard Teo (<leonard@ballistiq.com>)
