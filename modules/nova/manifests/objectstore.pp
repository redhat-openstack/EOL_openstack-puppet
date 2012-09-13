class nova::objectstore( $enabled=true ) {

  Exec['post-nova_config'] ~> Service['nova-objectstore']
  Exec['nova-db-sync'] ~> Service['nova-objectstore']

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  package {'openstack-nova-objectstore':
    ensure  => present
  }

  service { "nova-objectstore":
    name => 'openstack-nova-objectstore',
    ensure  => $service_ensure,
    enable  => $enabled,
    require => Package["openstack-nova-objectstore"]
  }

}
