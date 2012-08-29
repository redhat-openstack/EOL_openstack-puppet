class nova::volume( $enabled=false ) {

  Exec['post-nova_config'] ~> Service['nova-volume']
  Exec['nova-db-sync'] ~> Service['nova-volume']

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  exec {volumes:
    command => 'dd if=/dev/zero of=/tmp/nova-volumes.img bs=1M seek=20k count=0 && /sbin/vgcreate nova-volumes `/sbin/losetup --show -f /tmp/nova-volumes.img`',
    onlyif => 'test ! -e /tmp/nova-volumes.img',
    path => ["/usr/bin", "/bin", "/usr/local/bin"],
    before => Service['nova-volume'],
  }

  service { "nova-volume":
    name => 'openstack-nova-volume',
    ensure  => $service_ensure,
    enable  => $enabled,
    require => Package["openstack-nova"],
    #subscribe => File["/etc/nova/nova.conf"]
  }

  #NOTE: This works around a startup issue w/ existing tgtd daemon and
  # the Fedora systemd config
  $tgtd_service_file = '/usr/lib/systemd/system/tgtd.service'
  file { $tgtd_service_file:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    source  => 'puppet:///modules/nova/tgtd.service'
  }

  exec { "daemon-reload":
    command => "systemctl --system daemon-reload",
    refreshonly => true,
    path    => "/usr/bin",
    subscribe   => File[$tgtd_service_file],
  }

  service {'tgtd':
    ensure  => $service_ensure,
    enable  => $enabled,
    require => [Package["openstack-nova"], Exec['daemon-reload']],
  }

}
