class cinder::scheduler(
$enabled=true
) inherits cinder {

  Exec['post-cinder_config'] ~> Service['cinder-scheduler']
  Exec['cinder-db-sync'] -> Service['cinder-scheduler']

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  service { "cinder-scheduler":
    name => 'openstack-cinder-scheduler',
    ensure  => $service_ensure,
    enable  => $enabled,
    require => Package["openstack-cinder"],
    #subscribe => File["/etc/cinder/cinder.conf"]
  }
}
