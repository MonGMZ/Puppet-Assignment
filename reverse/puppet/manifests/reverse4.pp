# include ::dbus
# include ::avahi
#include 'nginx'


class{'nginx':
    manage_repo => true,
    package_source => 'nginx-stable'
}
nginx::resource::upstream { 'nginx1_upstream':
  members => {
    'https://10.10.10.10' => {
      server        => '10.10.10.10',
      port          => 443,
      fail_timeout  => '5s',
      max_fails     => 3,
      weight        => 1,
    },
  }
}
nginx::resource::upstream { 'nginx2_upstream':
  members => {
    'https://20.20.20.20' => {
      server => '20.20.20.20',
      port   => 443,
      fail_timeout  => '5s',
      max_fails     => 3,
      weight => 1,
    },
  }
}
nginx::resource::server { 'devops.local':
  proxy               => 'https://nginx1_upstream',
  ssl                 => true,
  ssl_cert            => '/home/vagrant/nginx_conf/cert.crt',
  ssl_key             => '/home/vagrant/nginx_conf/cert.key',
  # location_cfg_append => {
  #   health_check        =>  'interval=10 passes=2 fails=3'
  # }
}

nginx::resource::location { "/resource2":
  ensure                    => present,
  ssl                       => true,
  proxy                     => 'https://20.20.20.20/',
  ssl_only                  => true,
  server                    => "devops.local",
  location_cfg_append       => {
    #health_check            => 'interval=10 passes=2 fails=3',
    fastcgi_connect_timeout => '3m',
    fastcgi_read_timeout    => '3m',
    fastcgi_send_timeout    => '3m'
  }
}
