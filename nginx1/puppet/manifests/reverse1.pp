# include ::dbus
# include ::avahi
#include 'nginx'


class{'nginx':
    manage_repo => true,
    package_source => 'nginx-stable'
}
nginx::resource::server { 'devops.local':
  listen_port => 80,
  proxy       => 'http://10.0.0.101',
}
# nginx::resource::server { 'https://domain.com/resource2':
#   listen_port => 443,
#   proxy       => 'https://20.20.20.20',
# }
