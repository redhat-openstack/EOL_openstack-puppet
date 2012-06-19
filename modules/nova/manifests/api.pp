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

  nova::paste_config { "api-paste.ini/filter:authtoken/auth_host":
    value => "$keystone_auth_host"
  }

  nova::paste_config { "api-paste.ini/filter:authtoken/auth_port":
    value => "$keystone_auth_port"
  }

  nova::paste_config { "api-paste.ini/filter:authtoken/auth_protocol":
    value => "$keystone_auth_protocol"
  }

  nova::paste_config { "api-paste.ini/filter:authtoken/auth_uri":
    value => "$keystone_auth_uri"
  }

  nova::paste_config { "api-paste.ini/filter:authtoken/admin_user":
    value => "$keystone_admin_user"
  }

  nova::paste_config { "api-paste.ini/filter:authtoken/admin_password":
    value => "$keystone_admin_password"
  }

  nova::paste_config { "api-paste.ini/filter:authtoken/admin_tenant_name":
    value => "$keystone_admin_tenant_name"
  }

  service { "nova-api":
    name => 'openstack-nova-api',
    ensure  => $service_ensure,
    enable  => $enabled,
    require => Package["openstack-nova"],
    subscribe => [Augeas['api-paste.ini/filter:authtoken/auth_host'],
                  Augeas['api-paste.ini/filter:authtoken/auth_port'],
                  Augeas['api-paste.ini/filter:authtoken/auth_protocol'],
                  Augeas['api-paste.ini/filter:authtoken/auth_uri'],
                  Augeas['api-paste.ini/filter:authtoken/admin_user'],
                  Augeas['api-paste.ini/filter:authtoken/admin_password'],
                  Augeas['api-paste.ini/filter:authtoken/admin_tenant_name']
    ]
  }

}
