class nova::scheduler( $enabled ) {

  Exec['post-nova_config'] ~> Service['nova-scheduler']
  Exec['nova-db-sync'] -> Service['nova-scheduler']

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  service { "nova-scheduler":
    name => 'openstack-nova-scheduler',
    ensure  => $service_ensure,
    enable  => $enabled,
    require => Package["openstack-nova"],
    #subscribe => File["/etc/nova/nova.conf"]
  }
}
