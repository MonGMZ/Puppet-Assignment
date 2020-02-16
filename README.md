# Technical test - Puppet
The module is called monproxy (in reverse/puppet/modules path) and can be tested with the vagrant files included in the project. Instead of using https://domain.com  I'll use https://devops.local which is easier to test using avahi on the vagrant machines.

Do a 'vagrant up' on each of the folders 'nginx1', 'nginx2 and 'reverse' to run each of the machines to test. Open in a browser https://devops.local and https://devops.local/resource2 to prove that redirects to different nginx machines.

The vagrant file nginx1 is the nginx that will be hosted on https://10.10.10.10 (https://nginx1.local) and will receive all the calls to https://devops.local/. This reverse proxy uses an upstream which will have configured passive health checks (https://docs.nginx.com/nginx/admin-guide/load-balancer/http-health-check/) because active health checks are only implemented on comercial nginx version.
```
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
```

The vagrant file nginx2 is the nginx that will be hosted on https://20.20.20.20 (https://nginx2.local) and will receive all the calls to https://devops.local/resource2 (https://github.com/voxpupuli/puppet-nginx/blob/master/docs/quickstart.md)
```
  nginx::resource::location { "/resource2":
    ensure                    => present,
    ssl                       => true,
    proxy                     => 'https://20.20.20.20/',
    ssl_only                  => true,
    server                    => "devops.local",
    location_cfg_append       => {
      #health_check            => 'interval=10 passes=2 fails=3'
    }
  }
  ```
  
  For the forward proxy I found some info here: https://rayanfam.com/topics/useful-configs-for-nginx/
  ```
    nginx::resource::server{'forward_proxy':
    ensure              => 'present',
    listen_port         => 8080,
    index_files         => [],
    proxy_set_header    => ['Host $http_host'],
    proxy               => '$scheme://$http_host$uri$is_args$args',
    resolver            => ['8.8.8.8'],
    format_log          => 'custom',
  }
  ```
  
  To put together the puppet code in a module I followed this instructions: https://puppet.com/docs/pdk/1.x/pdk_creating_modules.html
