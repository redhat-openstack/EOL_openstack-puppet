class cinder::api(
  $enabled=true,
  $keystone_enabled = false,
  $keystone_auth_host = '127.0.0.1',
  $keystone_auth_port = '35357',
  $keystone_auth_protocol = 'http',
  $keystone_auth_uri = 'http://127.0.0.1:5000/',
  $keystone_admin_user = 'cinder',
  $keystone_admin_password = 'SERVICE_PASSWORD',
  $keystone_admin_tenant_name = 'service',
  $keystone_signing_dir = '/var/lib/cinder/keystone-signing'
) inherits cinder {

  Exec['post-cinder_config'] ~> Service['cinder-api']
  Exec['cinder-db-sync'] ~> Service['cinder-api']

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  cinder::paste_config { "set_cinder_auth_host":
    key => "api-paste.ini/filter:authtoken/auth_host",
    value => "$keystone_auth_host"
  }

  cinder::paste_config { "set_cinder_auth_port":
    key => "api-paste.ini/filter:authtoken/auth_port",
    value => "$keystone_auth_port"
  }

  cinder::paste_config { "set_cinder_auth_protocol":
    key => "api-paste.ini/filter:authtoken/auth_protocol",
    value => "$keystone_auth_protocol"
  }

  cinder::paste_config { "set_cinder_auth_uri":
    key => "api-paste.ini/filter:authtoken/auth_uri",
    value => "$keystone_auth_uri"
  }

  cinder::paste_config { "set_cinder_admin_user":
    key => "api-paste.ini/filter:authtoken/admin_user",
    value => "$keystone_admin_user"
  }

  cinder::paste_config { "set_cinder_admin_password":
    key => "api-paste.ini/filter:authtoken/admin_password",
    value => "$keystone_admin_password"
  }

  cinder::paste_config { "set_cinder_admin_tenant_name":
    key => "api-paste.ini/filter:authtoken/admin_tenant_name",
    value => "$keystone_admin_tenant_name"
  }

  cinder::paste_config { "set_cinder_signing_dir":
    key => "api-paste.ini/filter:authtoken/signing_dir",
    value => "$keystone_signing_dir"
  }

  file { $keystone_signing_dir:
    ensure  => directory,
    mode    => '750',
    owner   => 'cinder',
    group   => 'cinder',
    require => Package['openstack-cinder'],
  }

  service { "cinder-api":
    name => 'openstack-cinder-api',
    ensure  => $service_ensure,
    enable  => $enabled,
    require => Package["openstack-cinder"],
    subscribe => [Augeas['set_cinder_auth_host'],
                  Augeas['set_cinder_auth_port'],
                  Augeas['set_cinder_auth_protocol'],
                  Augeas['set_cinder_auth_uri'],
                  Augeas['set_cinder_admin_user'],
                  Augeas['set_cinder_admin_password'],
                  Augeas['set_cinder_admin_tenant_name'],
                  Augeas['set_cinder_signing_dir']
    ]
  }

}
