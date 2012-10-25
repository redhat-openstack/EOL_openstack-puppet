class keystone::api(
  $package_ensure = 'present',
  $log_file = '/var/log/keystone/keystone.log',
  $log_verbose = 'True',
  $log_debug = 'False',
  $bind_host = '0.0.0.0',
  $public_port = '5000',
  $admin_port = '35357',
  $admin_token = 'ADMIN',
  $compute_port = '8774',
  $use_syslog = 'False',
  $syslog_facility = 'LOG_LOCAL0',
  $sql_connection = 'sqlite:////var/lib/keystone/keystone.sqlite',
  $sql_idle_timeout = '200',
  $identity_driver = 'keystone.identity.backends.sql.Identity',
  $catalog_driver = 'keystone.catalog.backends.templated.TemplatedCatalog',
  $catalog_template_file = '/etc/keystone/default_catalog.templates',
  $token_driver = 'keystone.token.backends.kvs.Token',
  $expiration = '86400',
  $policy_driver = 'keystone.policy.backends.rules.Policy',
  $ec2_driver = 'keystone.contrib.ec2.backends.sql.Ec2',
  $ec2_host = 'localhost',
  $s3_host = 'localhost',
  $volume_host = 'localhost',
  $image_host = 'localhost',
  $storage_host = 'localhost',
  $compute_host = 'localhost',
  $network_host = 'localhost',
  $ssl_enable = undef,
  $ssl_certfile = '/etc/keystone/ssl/certs/keystone.pem',
  $ssl_keyfile = '/etc/keystone/ssl/private/keystonekey.pem',
  $ssl_ca_certs = '/etc/keystone/ssl/certs/ca.pem',
  $ssl_cert_required = True,
  $token_format = 'UUID',
  $signing_certfile = '/etc/keystone/ssl/certs/signing_cert.pem',
  $signing_keyfile = '/etc/keystone/ssl/private/signing_key.pem',
  $signing_ca_certs = '/etc/keystone/ssl/certs/ca.pem',
  $signing_key_size = '2048',
  $signing_valid_days = '3650',
  $signing_ca_password = undef
) {

  package { 'openstack-keystone': ensure => $package_ensure }
  package { 'python-keystoneclient': ensure => $package_ensure }

  exec { "keystone-db-sync":
    command     => "/usr/bin/keystone-manage db_sync",
    user     => "keystone",
    refreshonly => true,
    require     => Package["openstack-keystone"]
  }

  file { "/etc/keystone/keystone.conf":
    ensure  => present,
    owner   => 'keystone',
    group   => 'root',
    mode    => 640,
    content => template('keystone/keystone.conf.erb'),
    require => Package['openstack-keystone'],
    notify        => Exec["keystone-db-sync"]
  }

  file { $catalog_template_file:
    ensure  => present,
    owner   => 'keystone',
    group   => 'root',
    mode    => 640,
    content => template('keystone/default_catalog.templates.erb'),
    require => Package['openstack-keystone'],
    notify        => Exec["keystone-db-sync"]
  }

  file { '/etc/keystone/':
    ensure  => directory,
    owner   => 'keystone',
    group   => 'root',
    mode    => 770,
    require => Package['openstack-keystone']
  }

  service { "openstack-keystone":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => File["/etc/keystone/keystone.conf"],
    require => Package['openstack-keystone']
  }

  Exec['keystone-db-sync'] ~> Service['openstack-keystone']

}
