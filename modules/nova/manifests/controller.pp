class nova::controller(
  $db_password,
  $db_driver = 'mysql',
  $db_name = 'nova',
  $db_user = 'nova',
  $db_host = 'localhost',

  $rpc_backend = 'nova.rpc.impl_kombu',

  $rabbit_port = undef,
  $rabbit_userid = undef,
  $rabbit_password = undef,
  $rabbit_virtual_host = undef,
  $rabbit_host = undef,

  $qpid_hostname = undef,
  $qpid_port = undef,
  $qpid_username = undef,
  $qpid_password = undef,
  $qpid_reconnect = undef,
  $qpid_reconnect_timeout = undef,
  $qpid_reconnect_limit = undef,
  $qpid_reconnect_interval_min = undef,
  $qpid_reconnect_interval_max = undef,
  $qpid_reconnect_interval = undef,
  $qpid_heartbeat = undef,
  $qpid_protocol = undef,
  $qpid_tcp_nodelay = undef,

  $libvirt_type = 'qemu',

  $flat_network_bridge  = 'br100',
  $flat_network_bridge_ip  = '11.0.0.1',
  $flat_network_bridge_netmask  = '255.255.255.0',

  $nova_network = '11.0.0.0/24',
  $floating_network = '10.128.0.0/24',
  $available_ips = '256',

  $image_service = 'nova.image.glance.GlanceImageService',
  $glance_api_servers = 'localhost:9292',
  $glance_host   = undef,
  $glance_port   = undef,

  $admin_user = 'novaadmin',
  $project_name = 'nova',

  $verbose = undef,
  $allow_resize_to_same_host = false,
  $libvirt_wait_soft_reboot_seconds = 120,
  $scheduler_default_filters = 'AvailabilityZoneFilter,RamFilter,ComputeFilter',
  $keystone_enabled = false
) {


  class { "nova":
    verbose             => $verbose,
    sql_connection      => "${db_driver}://${db_user}:${db_password}@${db_host}/${db_name}",
    image_service       => $image_service,
    glance_api_servers  => $glance_api_servers,
    glance_host         => $glance_host,
    glance_port         => $glance_port,
    rpc_backend         => $rpc_backend,
    rabbit_host         => $rabbit_host,
    rabbit_port         => $rabbit_port,
    rabbit_userid       => $rabbit_userid,
    rabbit_password     => $rabbit_password,
    rabbit_virtual_host => $rabbit_virtual_host,
    qpid_hostname => $qpid_hostname,
    qpid_port => $qpid_port,
    qpid_username => $qpid_username,
    qpid_password => $qpid_password,
    qpid_reconnect => $qpid_reconnect,
    qpid_reconnect_timeout => $qpid_reconnect_timeout,
    qpid_reconnect_limit => $qpid_reconnect_limit,
    qpid_reconnect_interval_min => $qpid_reconnect_interval_min,
    qpid_reconnect_interval_max => $qpid_reconnect_interval_max,
    qpid_reconnect_interval => $qpid_reconnect_interval,
    qpid_heartbeat => $qpid_heartbeat,
    qpid_protocol => $qpid_protocol,
    qpid_tcp_nodelay => $qpid_tcp_nodelay,
    lock_path => '/var/lib/nova/tmp',
    network_manager => 'nova.network.manager.FlatDHCPManager',
    libvirt_type => $libvirt_type,
    scheduler_default_filters => $scheduler_default_filters,
    allow_resize_to_same_host => $allow_resize_to_same_host,
    libvirt_wait_soft_reboot_seconds => $libvirt_wait_soft_reboot_seconds

  }

  class { "nova::api": enabled => true, keystone_enabled => $keystone_enabled }

  class { "nova::network::flat":
    enabled                     => true,
    flat_network_bridge         => $flat_network_bridge,
    flat_network_bridge_ip      => $flat_network_bridge_ip,
    flat_network_bridge_netmask => $flat_network_bridge_netmask,
    
  }

  class { "nova::objectstore": 
    enabled => true,
  }

  class { "nova::cert": 
    enabled => true,
  }

  class { "nova::volume": 
    enabled => true,
  }

  class { "nova::scheduler": enabled => true }

  nova::manage::admin { $admin_user: }
  nova::manage::project { $project_name:
    owner => $admin_user,
  }

  nova::manage::network { "${project_name}-net-${nova_network}":
    network       => $nova_network,
    available_ips => $available_ips,
    require       => Nova::Manage::Project[$project_name],
  }

  nova::manage::floating { "${project_name}-floating-${floating_network}":
    network       => $floating_network,
    require       => Nova::Manage::Project[$project_name],
  }

}
