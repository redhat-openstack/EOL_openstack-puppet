class nova::network( $enabled=false ) {

  Exec['post-nova_config'] ~> Service['nova-network']
  Exec['nova-db-sync'] ~> Service['nova-network']

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  service { "nova-network":
    name => 'openstack-nova-network',
    ensure  => $service_ensure,
    enable  => $enabled,
    require => Package["openstack-nova"],
    before  => Exec['networking-refresh'],
    #subscribe => File["/etc/nova/nova.conf"]
  }
}
