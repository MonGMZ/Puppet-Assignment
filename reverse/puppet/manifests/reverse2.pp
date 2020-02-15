class{'nginx':
  package_source => 'nginx-stable'
}

nginx::resource::server { 'devops.local':
  ensure => 'present',
  server_name => ['devops.local'],
  ssl => true,
  ssl_port => 443,
  ssl_listen_option => true,
  ssl_cert    => '/etc/nginx/cert.crt',
  ssl_key     => '/etc/nginx/cert.key',
  index_files => [],
  location_custom_cfg => {},
  rewrite_rules => ['^/$ $scheme://10.0.0.100 permanent'],
  location_cfg_append  => {
      rewrite => '^(/resource2|/resource2/)$ $scheme://20.20.20.20 permanent',
  }
}
