class glance(
  package_ensure = 'present'
) {
  file { '/etc/glance/':
    ensure  => directory,
    owner   => 'glance',
    group   => 'root',
    mode    => 770,
    require => Package['openstack-glance']
  }

  package { 'openstack-glance': ensure => $package_ensure }
  package { 'python-migrate': ensure => 'present' }
}
