# include ::dbus
# include ::avahi
#include 'nginx'


class{'nginx':
    manage_repo => true,
    package_source => 'nginx-stable'
}
nginx::resource::server { 'devops.local':
  proxy       => 'https://10.0.0.101',
  ssl                 => true,
  ssl_cert            => '/home/vagrant/nginx_conf/cert.crt',
  ssl_key             => '/home/vagrant/nginx_conf/cert.key',
}

nginx::resource::location { "/resource2":
  ensure          => present,
  ssl             => true,
  proxy           => 'https://20.20.20.20/',
  ssl_only        => true,
  server          => "devops.local",
  location_cfg_append => {
    fastcgi_connect_timeout => '3m',
    fastcgi_read_timeout    => '3m',
    fastcgi_send_timeout    => '3m'
  }
}
