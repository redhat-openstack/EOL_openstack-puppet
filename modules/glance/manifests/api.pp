class glance::api(
  $log_verbose = 'True',
  $log_debug = 'False',
  $default_store = 'file',
  $bind_host = '0.0.0.0',
  $bind_port = '9292',
  $log_file = '/var/log/glance/api.log',
  $backlog = '4096',
  $tcp_keepidle = '600',
  $workers = '1',
  $admin_role = 'admin',
  $allow_anonymous_access = 'False',
  $use_syslog = 'False',
  $syslog_log_facility = 'LOG_LOCAL0',
  $cert_file = '',
  $key_file = '',
  $metadata_encryption_key = '1234567890ABCDEF',
  $registry_host = '0.0.0.0',
  $registry_port = '9191',
  $registry_client_protocol = 'http',
  $registry_client_key_file = '',
  $registry_client_cert_file = '',
  $registry_client_ca_file = '',
  $notifier_strategy = 'noop',

  $sql_connection = 'sqlite:///var/lib/glance/glance.sqlite',
  $sql_idle_timeout = '3600',

  $rabbit_host = 'localhost',
  $rabbit_port = '5672',
  $rabbit_use_ssl = 'False',
  $rabbit_userid = 'guest',
  $rabbit_password = 'guest',
  $rabbit_virtual_host = '/',
  $rabbit_notification_exchange = 'glance',
  $rabbit_notification_topic = 'glance_notifications',

  $qpid_notification_exchange = 'glance',
  $qpid_notification_topic = 'glance_notifications',
  $qpid_host = 'localhost',
  $qpid_port = '5672',
  $qpid_username ='',
  $qpid_password ='',
  $qpid_sasl_mechanisms ='',
  $qpid_reconnect_timeout = '0',
  $qpid_reconnect_limit = '0',
  $qpid_reconnect_interval_min = '0',
  $qpid_reconnect_interval_max = '0',
  $qpid_reconnect_interval = '0',
  $qpid_heartbeat = '60',
  $qpid_protocol = 'tcp',
  $qpid_tcp_nodelay = 'True',

  $filesystem_store_datadir = '/var/lib/glance/images/',

  $swift_store_auth_version = '1',
  $swift_store_auth_address = '127.0.0.1:8080/v1.0/',
  $swift_store_user = 'jdoe:jdoe',
  $swift_store_key = 'a86850deb2742ec3cb41518e26aa2d89',
  $swift_store_container = 'glance',
  $swift_store_create_container_on_put = 'False',
  $swift_store_large_object_size = '5120',
  $swift_store_large_object_chunk_size = '200',
  $swift_enable_snet = 'False',
  $swift_store_multi_tenant = 'False',
  $swift_store_admin_tenants = '[]',

  $s3_store_host = '127.0.0.1:8080/v1.0/',
  $s3_store_access_key = 'ABCD',
  $s3_store_secret_key = 'EFGH',
  $s3_store_bucket = 'abcdglance',
  $s3_store_create_bucket_on_put = 'False',
  $s3_store_object_buffer_dir = '',
  $rbd_store_ceph_conf = '/etc/ceph/ceph.conf',
  $rbd_store_user = 'glance',
  $rbd_store_pool = 'images',
  $rbd_store_chunk_size = '8',
  $delayed_delete = 'False',
  $scrub_time = '43200',
  $scrubber_datadir = '/var/lib/glance/scrubber',
  $image_cache_dir = '/var/lib/glance/image-cache/',
  $api_flavor = '',
) inherits glance {

  glance::paste_config { "set_glance_auth_version":
    key => "glance-api-paste.ini/filter:authtoken/auth_version",
    value => "$keystone_auth_version"
  }

  glance::paste_config { "set_glance_auth_host":
    key => "glance-api-paste.ini/filter:authtoken/auth_host",
    value => "$keystone_auth_host"
  }

  glance::paste_config { "set_glance_auth_port":
    key => "glance-api-paste.ini/filter:authtoken/auth_port",
    value => "$keystone_auth_port"
  }

  glance::paste_config { "set_glance_auth_protocol":
    key => "glance-api-paste.ini/filter:authtoken/auth_protocol",
    value => "$keystone_auth_protocol"
  }

  glance::paste_config { "set_glance_auth_uri":
    key => "glance-api-paste.ini/filter:authtoken/auth_uri",
    value => "$keystone_auth_uri"
  }

  glance::paste_config { "set_glance_admin_user":
    key => "glance-api-paste.ini/filter:authtoken/admin_user",
    value => "$keystone_admin_user"
  }

  glance::paste_config { "set_glance_admin_password":
    key => "glance-api-paste.ini/filter:authtoken/admin_password",
    value => "$keystone_admin_password"
  }

  glance::paste_config { "set_glance_admin_tenant_name":
    key => "glance-api-paste.ini/filter:authtoken/admin_tenant_name",
    value => "$keystone_admin_tenant_name"
  }

  glance::paste_config { "set_glance_signing_dir":
    key => "glance-api-paste.ini/filter:authtoken/signing_dir",
    value => "$keystone_signing_dir"
  }

  file { "/etc/glance/glance-api.conf":
    ensure  => present,
    owner   => 'glance',
    group   => 'root',
    mode    => 640,
    content => template('glance/glance-api.conf.erb'),
    require => Class["glance"]
  }

  service { "openstack-glance-api":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => [File["/etc/glance/glance-api.conf"],
                   Augeas['set_glance_auth_host'],
                   Augeas['set_glance_auth_port'],
                   Augeas['set_glance_auth_protocol'],
                   Augeas['set_glance_auth_uri'],
                   Augeas['set_glance_admin_user'],
                   Augeas['set_glance_admin_password'],
                   Augeas['set_glance_admin_tenant_name'],
                   Augeas['set_glance_signing_dir']
                  ],
    require    => Class["glance"]
  }

}
