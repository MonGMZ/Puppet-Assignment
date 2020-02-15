# Update repo package
exec { "apt-get update":
    command => "/usr/bin/apt-get update"
}
 
# nginx install
package { "nginx":
    ensure => present,
    require => Exec["apt-get update"]
}
 
# nginx start
service { "nginx":
    ensure => running,
    require => Package["nginx"]
}
 