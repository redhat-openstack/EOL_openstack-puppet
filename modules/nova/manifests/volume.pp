class nova::volume(
$volumes_dir = '/var/lib/nova/volumes',
$enabled = true
) {

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

  package {'openstack-nova-volume':
    ensure  => present
  }

  service { "nova-volume":
    name => 'openstack-nova-volume',
    ensure  => $service_ensure,
    enable  => $enabled,
    require => Package["openstack-nova-volume"]
  }

  #NOTE: This works around a startup issue w/ existing tgtd daemon and
  # the Fedora systemd config
  $tgtd_service_file = '/usr/lib/systemd/system/tgtd.service'
  file { $tgtd_service_file:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    source  => 'puppet:///modules/nova/tgtd.service',
    require => Package["openstack-nova-volume"]
  }

  #FIXME: Ideally we could use /etc/tgt/conf.d/nova.conf but there
  # is an issue w/ it using wildcards. So we use targets.conf instead.
  file { '/etc/tgt/targets.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 600,
    content  => template('nova/targets.conf.erb'),
    require => Package["openstack-nova-volume"]
  }

  exec { "daemon-reload":
    command => "systemctl --system daemon-reload",
    refreshonly => true,
    path    => "/usr/bin",
    subscribe   => [File[$tgtd_service_file], File['/etc/tgt/targets.conf']]
  }

  service {'tgtd':
    ensure  => $service_ensure,
    enable  => $enabled,
    require => [Package["openstack-nova-volume"], Exec['daemon-reload']],
  }

}
