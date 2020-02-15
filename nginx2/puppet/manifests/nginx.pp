class{'nginx':
  package_source => 'nginx-stable'
}

nginx::resource::server { 'nginx2.local':
  ensure              => 'present',
  server_name         => ['nginx2.local'],
  ssl                 => true,
  ssl_port            => 443,
  #ssl_listen_option   => true,
  ssl_cert            => '/home/vagrant/nginx_conf/cert.crt',
  ssl_key             => '/home/vagrant/nginx_conf/cert.key',
  www_root            => "/vagrant/html/",
}
