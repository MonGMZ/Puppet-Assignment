# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include monproxy

class monproxy {
  #include 'nginx'
  class{'nginx':
    manage_repo => true,
    package_source => 'nginx-stable',
    log_format => {
      custom  => '[$time_local] $scheme $remote_addr "$request_time" - "$request" $status "$http_user_agent"',
    },
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

  nginx::resource::server{'forward_proxy':
    ensure              => 'present',
    listen_port         => 8080,
    index_files         => [],
    proxy_set_header    => ['Host $http_host'],
    proxy               => '$scheme://$http_host$uri$is_args$args',
    resolver            => ['8.8.8.8'],
    format_log          => 'custom',
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

}
