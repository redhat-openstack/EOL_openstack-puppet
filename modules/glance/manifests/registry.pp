class glance::registry(
  $log_verbose = 'True',
  $log_debug = 'False',
  $bind_host = '0.0.0.0',
  $bind_port = '9191',
  $log_file = '/var/log/glance/registry.log',
  $backlog = '4096',
  $tcp_keepidle = '600',
  $sql_connection = 'sqlite:///var/lib/glance/glance.sqlite',
  $sql_idle_timeout = '3600',
  $use_syslog = 'False',
  $syslog_log_facility = 'LOG_LOCAL1',
  $api_limit_max = '1000',
  $limit_param_default = '25',
  $admin_role = 'admin',
  $cert_file = '',
  $key_file = '',
  $registry_flavor = ''
) inherits glance {

  glance::paste_config { "set_glance_registry_auth_version":
    key => "glance-registry-paste.ini/filter:authtoken/auth_version",
    value => "$keystone_auth_version"
  }

  glance::paste_config { "set_glance_registry_auth_host":
    key => "glance-registry-paste.ini/filter:authtoken/auth_host",
    value => "$keystone_auth_host"
  }

  glance::paste_config { "set_glance_registry_auth_port":
    key => "glance-registry-paste.ini/filter:authtoken/auth_port",
    value => "$keystone_auth_port"
  }

  glance::paste_config { "set_glance_registry_auth_protocol":
    key => "glance-registry-paste.ini/filter:authtoken/auth_protocol",
    value => "$keystone_auth_protocol"
  }

  glance::paste_config { "set_glance_registry_auth_uri":
    key => "glance-registry-paste.ini/filter:authtoken/auth_uri",
    value => "$keystone_auth_uri"
  }

  glance::paste_config { "set_glance_registry_admin_user":
    key => "glance-registry-paste.ini/filter:authtoken/admin_user",
    value => "$keystone_admin_user"
  }

  glance::paste_config { "set_glance_registry_admin_password":
    key => "glance-registry-paste.ini/filter:authtoken/admin_password",
    value => "$keystone_admin_password"
  }

  glance::paste_config { "set_glance_registry_admin_tenant_name":
    key => "glance-registry-paste.ini/filter:authtoken/admin_tenant_name",
    value => "$keystone_admin_tenant_name"
  }

  glance::paste_config { "set_glance_registry_signing_dir":
    key => "glance-registry-paste.ini/filter:authtoken/signing_dir",
    value => "$keystone_signing_dir"
  }

  exec { "glance-db-sync":
    command     => "/usr/bin/glance-manage db_sync",
    refreshonly => true,
    user     => 'glance',
    require     => Package["openstack-glance"]
  }

  file { "/etc/glance/glance-registry.conf":
    ensure  => present,
    owner   => 'glance',
    group   => 'root',
    mode    => 640,
    content => template('glance/glance-registry.conf.erb'),
    require => Class["glance"],
    notify   => Exec['glance-db-sync'],
  }

  service { "openstack-glance-registry":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => [File["/etc/glance/glance-registry.conf"], 
                   Augeas['set_glance_registry_auth_version'],
                   Augeas['set_glance_registry_auth_host'],
                   Augeas['set_glance_registry_auth_port'],
                   Augeas['set_glance_registry_auth_protocol'],
                   Augeas['set_glance_registry_auth_uri'],
                   Augeas['set_glance_registry_admin_user'],
                   Augeas['set_glance_registry_admin_password'],
                   Augeas['set_glance_registry_admin_tenant_name'],
                   Augeas['set_glance_registry_signing_dir']
                  ],
    require    => [Class["glance"], Exec['glance-db-sync']]
  }

}
