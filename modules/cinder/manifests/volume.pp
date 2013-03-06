class cinder::volume(
  $enabled=true
) inherits cinder {

  Exec['post-cinder_config'] ~> Service['cinder-volume']
  Exec['cinder-db-sync'] ~> Service['cinder-volume']

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  exec {volumes:
    command => 'dd if=/dev/zero of=/tmp/cinder-volumes.img bs=1M seek=20k count=0 && /sbin/vgcreate cinder-volumes `/sbin/losetup --show -f /tmp/cinder-volumes.img`',
    onlyif => 'test ! -e /tmp/cinder-volumes.img',
    path => ["/usr/bin", "/bin", "/usr/local/bin"],
    before => Service['cinder-volume'],
  }

  service { "cinder-volume":
    name => 'openstack-cinder-volume',
    ensure  => $service_ensure,
    enable  => $enabled,
    require => Package["openstack-cinder"],
    #subscribe => File["/etc/cinder/cinder.conf"]
  }

  #NOTE: This works around a startup issue w/ existing tgtd daemon and
  # the Fedora systemd config
  $tgtd_service_file = '/etc/init.dtgtd'
  file { $tgtd_service_file:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 755,
    source  => 'puppet:///modules/cinder/tgtd.service',
    require => Package["openstack-cinder"]
  }

  #FIXME: Ideally we could use /etc/tgt/conf.d/cinder.conf but there
  # is an issue w/ it using wildcards. So we use targets.conf instead.
  file { '/etc/tgt/targets.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 600,
    content  => template('cinder/targets.conf.erb'),
    require => Package["openstack-cinder"]
  }

  exec { "daemon-reload":
    command => "service ${service_name} restart",
    refreshonly => true,
    path    => "/sbin",
    subscribe   => [File[$tgtd_service_file], File['/etc/tgt/targets.conf']]
  }

  service {'tgtd':
    ensure  => $service_ensure,
    enable  => $enabled,
    require => [Package["openstack-cinder"], Exec['daemon-reload']],
  }

}
