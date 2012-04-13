class nova::api(
  $enabled=false,
  $keystone_enabled = false,
  $keystone_service_protocol = 'http',
  $keystone_service_host = '127.0.0.1',
  $keystone_service_port = '5000',
  $keystone_auth_host = '127.0.0.1',
  $keystone_auth_port = '35357',
  $keystone_auth_protocol = 'http',
  $keystone_auth_uri = 'http://127.0.0.1:5000/',
  $keystone_admin_user = 'nova',
  $keystone_admin_password = 'SERVICE_PASSWORD',
  $keystone_admin_tenant_name = 'service'
) {

  Exec['post-nova_config'] ~> Service['nova-api']
  Exec['nova-db-sync'] ~> Service['nova-api']

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  exec { "initial-db-sync":
    command     => "/usr/bin/nova-manage db sync",
    refreshonly => true,
    require     => [Package["openstack-nova"], Nova_config['sql_connection']],
  }

  file { "/etc/nova/api-paste.ini":
    ensure  => present,
    owner   => 'nova',
    group   => 'root',
    mode    => 640,
    content => template('nova/api-paste.ini.erb'),
    require => Package["openstack-nova"]
  }

  service { "nova-api":
    name => 'openstack-nova-api',
    ensure  => $service_ensure,
    enable  => $enabled,
    require => Package["openstack-nova"],
    subscribe => File["/etc/nova/api-paste.ini"]
  }
}
