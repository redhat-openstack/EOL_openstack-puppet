class nova::api(
  $enabled=false,
  $keystone_enabled = false,
  $keystone_auth_host = '127.0.0.1',
  $keystone_auth_port = '35357',
  $keystone_auth_protocol = 'http',
  $keystone_auth_uri = 'http://127.0.0.1:5000/',
  $keystone_admin_user = 'nova',
  $keystone_admin_password = 'SERVICE_PASSWORD',
  $keystone_admin_tenant_name = 'service',
  $keystone_signing_dir = '/var/lib/nova/keystone-signing'
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

  nova::paste_config { "set_nova_auth_host":
    key => "api-paste.ini/filter:authtoken/auth_host",
    value => "$keystone_auth_host"
  }

  nova::paste_config { "set_nova_auth_port":
    key => "api-paste.ini/filter:authtoken/auth_port",
    value => "$keystone_auth_port"
  }

  nova::paste_config { "set_nova_auth_protocol":
    key => "api-paste.ini/filter:authtoken/auth_protocol",
    value => "$keystone_auth_protocol"
  }

  nova::paste_config { "set_nova_auth_uri":
    key => "api-paste.ini/filter:authtoken/auth_uri",
    value => "$keystone_auth_uri"
  }

  nova::paste_config { "set_nova_admin_user":
    key => "api-paste.ini/filter:authtoken/admin_user",
    value => "$keystone_admin_user"
  }

  nova::paste_config { "set_nova_admin_password":
    key => "api-paste.ini/filter:authtoken/admin_password",
    value => "$keystone_admin_password"
  }

  nova::paste_config { "set_nova_admin_tenant_name":
    key => "api-paste.ini/filter:authtoken/admin_tenant_name",
    value => "$keystone_admin_tenant_name"
  }

  nova::paste_config { "set_nova_signing_dir":
    key => "api-paste.ini/filter:authtoken/signing_dir",
    value => "$keystone_signing_dir"
  }

  file { $keystone_signing_dir:
    ensure  => directory,
    mode    => '750',
    owner   => 'nova',
    group   => 'nova',
    require => Package['openstack-nova'],
  }

  service { "nova-api":
    name => 'openstack-nova-api',
    ensure  => $service_ensure,
    enable  => $enabled,
    require => Package["openstack-nova"],
    subscribe => [Augeas['set_nova_auth_host'],
                  Augeas['set_nova_auth_port'],
                  Augeas['set_nova_auth_protocol'],
                  Augeas['set_nova_auth_uri'],
                  Augeas['set_nova_admin_user'],
                  Augeas['set_nova_admin_password'],
                  Augeas['set_nova_admin_tenant_name'],
                  Augeas['set_nova_signing_dir']
    ]
  }

}
