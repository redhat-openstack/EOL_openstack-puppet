class keystone::pki_setup(
) {

  file { "/etc/keystone/ssl/":
    ensure  => directory,
    owner   => 'keystone',
    group   => 'root',
    mode    => 750,
    require => Package['openstack-keystone']
  }

  exec { "keystone-pki-setup":
    command  => "/usr/bin/keystone-manage pki_setup",
    user     => "keystone",
    creates  => "/etc/keystone/ssl/private/signing_key.pem",
    require  => [Package["openstack-keystone"], File["/etc/keystone/ssl/"]]
  }

  Exec['keystone-pki-setup'] ~> Service['openstack-keystone']

}
