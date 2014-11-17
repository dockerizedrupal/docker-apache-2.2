class httpd {
  require httpd::packages
  require httpd::supervisor

  exec { 'mkdir -p /httpd-2.2.22/data':
    path => ['/bin']
  }

  exec { 'usermod -d /httpd-2.2.22/data www-data':
    path => ['/usr/sbin'],
    require => Exec['mkdir -p /httpd-2.2.22/data']
  }

  exec { '/bin/bash -c "a2enmod actions"': }
  exec { '/bin/bash -c "a2enmod fastcgi"': }
  exec { '/bin/bash -c "a2enmod vhost_alias"': }
  exec { '/bin/bash -c "a2enmod rewrite"': }
  exec { '/bin/bash -c "a2enmod ssl"': }

  file { '/etc/apache2/sites-enabled/000-default':
    ensure => absent
  }
}
