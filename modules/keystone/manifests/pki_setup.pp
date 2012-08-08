class keystone::pki_setup(
) {

  exec { "keystone-pki-setup":
    command  => "/usr/bin/keystone-manage pki_setup",
    user     => "keystone",
    creates  => "/etc/keystone/ssl/private/signing_key.pem",
    require  => Package["openstack-keystone"]
  }

  Exec['keystone-pki-setup'] ~> Service['openstack-keystone']

}
