name             'passenger-nginx'
maintainer       'Leonard Teo'
maintainer_email 'leonard@ballistiq.com'
license          'MIT'
description      'Installs/Configures Passenger with Nginx'
long_description 'Installs/Configures RVM, Ruby, Phusion Passenger (open source and Enterprise editions) with Nginx'
version          '0.9.0'

depends "user"
depends "ruby_build"

supports 'ubuntu'
supports 'centos'