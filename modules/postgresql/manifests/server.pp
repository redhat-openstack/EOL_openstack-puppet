# Class: postgresql::server
#
# This module manages the installation and config of the postgresql server.
class postgresql::server(
  $data_dir = '/var/lib/pgsql/data',
  $package_name = 'postgresql-server',
  $service_name = 'postgresql',
  $hba_records = ['host    all         all         0.0.0.0/0             md5']
) {

  package { $package_name:
    ensure => present
  }

  exec { "initdb":
    command     => "/bin/postgresql-setup initdb",
    creates => "${data_dir}/PG_VERSION",
    require => Package[$package_name]
  }

  file { "${data_dir}/postgresql.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    content => template('postgresql/postgresql.conf.erb'),
    subscribe => Package[$package_name],
    require => Exec['initdb']
  }
 
  file { "${data_dir}/pg_hba.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    content => template('postgresql/pg_hba.conf.erb'),
    subscribe => Package[$package_name],
    require => Exec['initdb']
  }

  service { $service_name:
    ensure => running,
    subscribe => [Package[$package_name], File["${data_dir}/postgresql.conf"], File["${data_dir}/pg_hba.conf"]]
  }

}
