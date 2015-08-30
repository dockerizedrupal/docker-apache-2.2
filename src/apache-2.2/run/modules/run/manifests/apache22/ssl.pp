class run::apache22::ssl {
  bash_exec { 'mkdir -p /apache-2.2/ssl': }

  bash_exec { 'mkdir -p /apache-2.2/ssl/private':
    require => Bash_exec['mkdir -p /apache-2.2/ssl']
  }

  bash_exec { 'mkdir -p /apache-2.2/ssl/certs':
    require => Bash_exec['mkdir -p /apache-2.2/ssl/private']
  }

  file { '/root/opensslCA.cnf':
    ensure => present,
    content => template('run/opensslCA.cnf.erb'),
    require => Bash_exec['mkdir -p /apache-2.2/ssl/certs']
  }

  bash_exec { 'openssl genrsa -out /apache-2.2/ssl/private/apache-2.2CA.key 4096':
    timeout => 0,
    require => File['/root/opensslCA.cnf']
  }

  bash_exec { "openssl req -sha256 -x509 -new -days 3650 -extensions v3_ca -config /root/opensslCA.cnf -key /apache-2.2/ssl/private/apache-2.2CA.key -out /apache-2.2/ssl/certs/apache-2.2CA.crt":
    timeout => 0,
    require => Bash_exec['openssl genrsa -out /apache-2.2/ssl/private/apache-2.2CA.key 4096']
  }

  bash_exec { 'openssl genrsa -out /apache-2.2/ssl/private/apache-2.2.key 4096':
    timeout => 0,
    require => Bash_exec["openssl req -sha256 -x509 -new -days 3650 -extensions v3_ca -config /root/opensslCA.cnf -key /apache-2.2/ssl/private/apache-2.2CA.key -out /apache-2.2/ssl/certs/apache-2.2CA.crt"]
  }

  file { '/root/openssl.cnf':
    ensure => present,
    content => template('run/openssl.cnf.erb'),
    require => Bash_exec['openssl genrsa -out /apache-2.2/ssl/private/apache-2.2.key 4096']
  }

  bash_exec { "openssl req -sha256 -new -config /root/openssl.cnf -key /apache-2.2/ssl/private/apache-2.2.key -out /apache-2.2/ssl/certs/apache-2.2.csr":
    timeout => 0,
    require => File['/root/openssl.cnf']
  }

  bash_exec { "openssl x509 -req -sha256 -CAcreateserial -days 3650 -extensions v3_req -extfile /root/opensslCA.cnf -in /apache-2.2/ssl/certs/apache-2.2.csr -CA /apache-2.2/ssl/certs/apache-2.2CA.crt -CAkey /apache-2.2/ssl/private/apache-2.2CA.key -out /apache-2.2/ssl/certs/apache-2.2.crt":
    timeout => 0,
    require => Bash_exec["openssl req -sha256 -new -config /root/openssl.cnf -key /apache-2.2/ssl/private/apache-2.2.key -out /apache-2.2/ssl/certs/apache-2.2.csr"]
  }
}
