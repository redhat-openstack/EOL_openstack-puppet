class nova(
  # this is how to query all resources from our clutser
  $sql_connection = false,
  $image_service = 'nova.image.local.LocalImageService',
  # these glance params should be optional
  # this should probably just be configured as a glance client
  $glance_api_servers = 'localhost:9292',
  $glance_host = 'localhost',
  $glance_port = '9292',
  $allow_admin_api = false,

  $compute_driver = 'libvirt.LibvirtDriver',
  $xenapi_connection_url = 'http://localhost',
  $xenapi_connection_username = 'username',
  $xenapi_connection_password = 'password',
  $xenapi_inject_image = false,

  $rpc_backend = 'nova.rpc.impl_kombu',

  $rabbit_host = 'localhost',
  $rabbit_password='guest',
  $rabbit_port='5672',
  $rabbit_userid='guest',
  $rabbit_virtual_host='/',

  $qpid_hostname = 'localhost',
  $qpid_port = '5672',
  $qpid_username = 'guest',
  $qpid_password = 'guest',
  $qpid_reconnect = true,
  $qpid_reconnect_timeout = 0,
  $qpid_reconnect_limit = 0,
  $qpid_reconnect_interval_min = 0,
  $qpid_reconnect_interval_max = 0,
  $qpid_reconnect_interval = 0,
  $qpid_heartbeat = 5,
  $qpid_protocol = 'tcp',
  $qpid_tcp_nodelay = true,

  $network_manager = 'nova.network.manager.FlatDHCPManager',
  $network_api_class = 'nova.network.api.API',
  $force_dhcp_release = false,
  $flat_network_bridge = 'br100',
  $service_down_time = 60,
  $logdir = '/var/log/nova',
  $state_path = '/var/lib/nova',
  $lock_path = '/var/lib/nova/tmp',
  $verbose = false,
  $nodaemon = false,
  $periodic_interval = '60',
  $report_interval = '10',
  $libvirt_type = 'qemu',
  $auth_strategy = 'keystone',
  $scheduler_default_filters = 'AvailabilityZoneFilter,RamFilter,ComputeFilter',
  $allow_resize_to_same_host = false,
  $libvirt_wait_soft_reboot_seconds = 120,
  $disable_process_locking = false,
  $firewall_driver = 'nova.virt.libvirt.firewall.IptablesFirewallDriver',
  $s3_host = 'localhost',
  $s3_port = 3333,
  $enabled_apis = 'ec2,osapi_compute,metadata',
  $volume_api_class = 'nova.volume.cinder.API',
  $volumes_dir = '/var/lib/nova/volumes',
  $iscsi_helper = 'tgtadm',

  $quantum_use_dhcp = 'True',
  $quantum_connection_host = 'localhost',
  $quantum_auth_strategy = 'keystone',
  $quantum_admin_tenant_name = 'service',
  $quantum_admin_username = 'quantum',
  $quantum_admin_password = 'SERVICE_PASSWORD',
  $quantum_url = 'http://127.0.0.1:9696',
  $quantum_admin_auth_url = 'http://127.0.0.1:35357/v2.0',
  $libvirt_vif_driver = 'nova.virt.libvirt.vif.LibvirtBridgeDriver'
) {

  Package['openstack-nova-common'] -> Nova_config<| |> -> File['/etc/nova/nova.conf']
  Nova_config<| |> ~> Exec['post-nova_config']

  class { 'nova::utilities': }
  package { ['python-nova', 'openstack-nova-common']:
    ensure  => present
  }
  group { 'nova':
    ensure => present
  }
  user { 'nova':
    ensure => present,
    gid    => 'nova',
  }
  file { $logdir:
    ensure  => directory,
    mode    => '751',
    owner   => 'nova',
    group   => 'nova',
    require => Package['openstack-nova-common'],
  }
  file { '/etc/nova/nova.conf':
    owner => 'nova',
    group => 'nova',
    mode  => '0640'
  }
  exec { "nova-db-sync":
    command     => "/usr/bin/nova-manage db sync",
    refreshonly => "true",
  }

  # used by debian/ubuntu in nova::network_bridge to refresh
  # interfaces based on /etc/network/interfaces
  exec { "networking-refresh":
    command     => "/sbin/ifdown -a ; /sbin/ifup -a",
    refreshonly => "true",
  }


  # query out the config for our db connection
  if $sql_connection {
    nova_config { 'DEFAULT/sql_connection': value => $sql_connection }
  }

  nova_config {
    #'verbose': value => $verbose;
    'DEFAULT/nodaemon': value => $nodaemon;
    'DEFAULT/logdir': value => $logdir;
    'DEFAULT/image_service': value => $image_service;
    'DEFAULT/allow_admin_api': value => $allow_admin_api;
    'DEFAULT/rpc_backend': value => $rpc_backend;
    # Following may need to be broken out to different nova services
    'DEFAULT/state_path': value => $state_path;
    'DEFAULT/lock_path': value => $lock_path;
    'DEFAULT/service_down_time': value => $service_down_time;
    # These network entries wound up in the common
    # config b/c they have to be set by both compute
    # as well as controller.
    'DEFAULT/network_manager': value => $network_manager;
    'DEFAULT/force_dhcp_release': value => $force_dhcp_release;
    #'use_deprecated_auth': value => true;
    'DEFAULT/default_instance_type': value => 'm1.tiny';
    'DEFAULT/libvirt_type': value => $libvirt_type;
    'DEFAULT/iscsi_helper': value => $iscsi_helper;
    'DEFAULT/volumes_dir': value => $volumes_dir;
    'DEFAULT/rootwrap_config': value => '/etc/nova/rootwrap.conf';
    'DEFAULT/vpn_client_template': value => '/usr/share/nova/client.ovpn.template';
    'DEFAULT/public_interface': value => 'eth0';
    'DEFAULT/compute_driver': value => $compute_driver;
    'DEFAULT/auth_strategy': value => $auth_strategy;
    'DEFAULT/scheduler_default_filters': value => $scheduler_default_filters;
    'DEFAULT/allow_resize_to_same_host': value => $allow_resize_to_same_host;
    'DEFAULT/libvirt_wait_soft_reboot_seconds': value => $libvirt_wait_soft_reboot_seconds;
    'DEFAULT/firewall_driver': value => $firewall_driver;
    'DEFAULT/disable_process_locking': value => $disable_process_locking;
    'DEFAULT/s3_host': value => $s3_host;
    'DEFAULT/s3_port': value => $s3_port;
    'DEFAULT/enabled_apis': value => $enabled_apis;
    'DEFAULT/volume_api_class': value => $volume_api_class;
    'DEFAULT/network_api_class': value => $network_api_class;
    'DEFAULT/libvirt_vif_driver': value => $libvirt_vif_driver;
  }

  exec { 'post-nova_config':
    command => '/bin/echo "Nova config has changed"',
    refreshonly => true,
  }

  if $compute_driver == 'xenapi.XenAPIDriver' {
    nova_config {
      'DEFAULT/xenapi_connection_url': value => $xenapi_connection_url;
      'DEFAULT/xenapi_connection_username': value => $xenapi_connection_username;
      'DEFAULT/xenapi_connection_password': value => $xenapi_connection_password;
      'DEFAULT/xenapi_inject_image': value => $xenapi_inject_image;
    }
  }

  if $network_manager == 'nova.network.manager.FlatManager' {
    nova_config {
      'DEFAULT/flat_network_bridge': value => $flat_network_bridge
    }
  }

  if $network_manager == 'nova.network.manager.FlatDHCPManager' {
    nova_config {
      'DEFAULT/dhcpbridge': value => "/usr/bin/nova-dhcpbridge";
      'DEFAULT/dhcpbridge_flagfile': value => "/etc/nova/nova.conf";
      'DEFAULT/flat_network_bridge': value => $flat_network_bridge;
    }
  }

  if $network_api_class == 'nova.network.quantumv2.api.API' {
    nova_config {
      'DEFAULT/quantum_use_dhcp': value => $use_dhcp;
      'DEFAULT/quantum_auth_strategy': value => $quantum_auth_strategy;
      'DEFAULT/quantum_url': value => $quantum_url;
      'DEFAULT/quantum_admin_tenant_name': value => $quantum_admin_tenant_name;
      'DEFAULT/quantum_admin_username': value => $quantum_admin_username;
      'DEFAULT/quantum_admin_password': value => $quantum_admin_password;
      'DEFAULT/quantum_admin_auth_url': value => $quantum_admin_auth_url;
    }
  }

  if $image_service == 'nova.image.glance.GlanceImageService' {
    nova_config {
      'DEFAULT/glance_api_servers': value => $glance_api_servers;
      'DEFAULT/glance_host': value => $glance_host;
      'DEFAULT/glance_port': value => $glance_port;
    }
  }

  if $rpc_backend == 'nova.rpc.impl_kombu' {
    nova_config {
      'DEFAULT/rabbit_host': value => $rabbit_host;
      'DEFAULT/rabbit_password': value => $rabbit_password;
      'DEFAULT/rabbit_port': value => $rabbit_port;
      'DEFAULT/rabbit_userid': value => $rabbit_userid;
      'DEFAULT/rabbit_virtual_host': value => $rabbit_virtual_host;
    }
  }

  if $rpc_backend == 'nova.rpc.impl_qpid' {
    nova_config {
      'DEFAULT/qpid_hostname': value => $qpid_hostname;
      'DEFAULT/qpid_port': value => $qpid_port;
      'DEFAULT/qpid_username': value => $qpid_username;
      'DEFAULT/qpid_password': value => $qpid_password;
      'DEFAULT/qpid_reconnect': value => $qpid_reconnect;
      'DEFAULT/qpid_reconnect_timeout': value => $qpid_reconnect_timeout;
      'DEFAULT/qpid_reconnect_limit': value => $qpid_reconnect_limit;
      'DEFAULT/qpid_reconnect_interval_min': value => $qpid_reconnect_interval_min;
      'DEFAULT/qpid_reconnect_interval_max': value => $qpid_reconnect_interval_max;
      'DEFAULT/qpid_reconnect_interval': value => $qpid_reconnect_interval;
      'DEFAULT/qpid_heartbeat': value => $qpid_heartbeat;
      'DEFAULT/qpid_protocol': value => $qpid_protocol;
      'DEFAULT/qpid_tcp_nodelay': value => $qpid_tcp_nodelay;
    }
  }

}
