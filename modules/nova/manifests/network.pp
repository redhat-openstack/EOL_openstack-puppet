class nova::network( $enabled=true ) {

  Exec['post-nova_config'] ~> Service['nova-network']
  Exec['nova-db-sync'] ~> Service['nova-network']

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  package {'openstack-nova-network':
    ensure  => present
  }

  service { "nova-network":
    name => 'openstack-nova-network',
    ensure  => $service_ensure,
    enable  => $enabled,
    require => Package["openstack-nova-network"],
    before  => Exec['networking-refresh']
  }
}
