name             'passenger-nginx'
maintainer       'Leonard Teo'
maintainer_email 'leonard@ballistiq.com'
license          'MIT'
description      'Installs/Configures Passenger with Nginx'
long_description 'Installs/Configures RVM, Ruby, Phusion Passenger (open source and Enterprise editions) with Nginx'
version          '0.9.15'

supports 'ubuntu'

%w{ redhat centos scientific oracle }.each do |rhel|
  supports rhel, ">= 6.0"
end