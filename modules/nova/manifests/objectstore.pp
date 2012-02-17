class nova::objectstore( $enabled=false ) {

  Exec['post-nova_config'] ~> Service['nova-objectstore']
  Exec['nova-db-sync'] ~> Service['nova-objectstore']

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  service { "nova-objectstore":
    name => 'openstack-nova-objectstore',
    ensure  => $service_ensure,
    enable  => $enabled,
    require => Package["openstack-nova"],
    #subscribe => File["/etc/nova/nova.conf"]
  }
}
