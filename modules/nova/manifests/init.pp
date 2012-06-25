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

  $network_manager = 'nova.network.manager.FlatManager',
  $flat_network_bridge = 'br100',
  $service_down_time = 60,
  $logdir = '/var/log/nova',
  $state_path = '/var/lib/nova',
  $lock_path = '/var/lock/nova',
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
  $s3_host = 'localhost',
  $s3_port = 3333

) {

  Nova_config<| |> {
    require +> Package["openstack-nova"],
    before +> File['/etc/nova/nova.conf'],
    notify +> Exec['post-nova_config']
  }
  # TODO - why is this required?
  package { 'python':
    ensure => present,
  }
  package { 'python-greenlet':
    ensure => present,
    require => Package['python'],
  }

  class { 'nova::utilities': }
  package { ["python-nova", "openstack-nova"]:
    ensure  => present,
    require => Package["python-greenlet"]
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
    require => Package['openstack-nova'],
  }
  file { '/etc/nova/nova.conf':
    owner => 'nova',
    group => 'nova',
    mode  => '0640',
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
    nova_config { 'sql_connection': value => $sql_connection }
  }

  nova_config {
    #'verbose': value => $verbose;
    'nodaemon': value => $nodaemon;
    'logdir': value => $logdir;
    'image_service': value => $image_service;
    'allow_admin_api': value => $allow_admin_api;
    'rpc_backend': value => $rpc_backend;
    # Following may need to be broken out to different nova services
    'state_path': value => $state_path;
    'lock_path': value => $lock_path;
    'service_down_time': value => $service_down_time;
    # These network entries wound up in the common
    # config b/c they have to be set by both compute
    # as well as controller.
    'network_manager': value => $network_manager;
    #'use_deprecated_auth': value => true;
    'default_instance_type': value => 'm1.tiny';
    'libvirt_type': value => $libvirt_type;
    'iscsi_helper': value => 'tgtadm';
    'root_helper': value => 'sudo nova-rootwrap /etc/nova/rootwrap.conf';
    'vpn_client_template': value => '/usr/share/nova/client.ovpn.template';
    'public_interface': value => 'eth0';
    'connection_type': value => 'libvirt';
    'auth_strategy': value => $auth_strategy;
    'scheduler_default_filters': value => $scheduler_default_filters;
    'allow_resize_to_same_host': value => $allow_resize_to_same_host;
    'libvirt_wait_soft_reboot_seconds': value => $libvirt_wait_soft_reboot_seconds;
    'disable_process_locking': value => $disable_process_locking;
    's3_host': value => $s3_host;
    's3_port': value => $s3_port;
  }

  exec { 'post-nova_config':
    command => '/bin/echo "Nova config has changed"',
    refreshonly => true,
  }

  if $network_manager == 'nova.network.manager.FlatManager' {
    nova_config {
      'flat_network_bridge': value => $flat_network_bridge
    }
  }

  if $network_manager == 'nova.network.manager.FlatDHCPManager' {
    nova_config {
      'dhcpbridge': value => "/usr/bin/nova-dhcpbridge";
      'dhcpbridge_flagfile': value => "/etc/nova/nova.conf";
    }
  }

  if $image_service == 'nova.image.glance.GlanceImageService' {
    nova_config {
      'glance_api_servers': value => $glance_api_servers;
      'glance_host': value => $glance_host;
      'glance_port': value => $glance_port;
    }
  }

  if $rpc_backend == 'nova.rpc.impl_kombu' {
    nova_config {
      'rabbit_host': value => $rabbit_host;
      'rabbit_password': value => $rabbit_password;
      'rabbit_port': value => $rabbit_port;
      'rabbit_userid': value => $rabbit_userid;
      'rabbit_virtual_host': value => $rabbit_virtual_host;
    }
  }

  if $rpc_backend == 'nova.rpc.impl_qpid' {
    nova_config {
      'qpid_hostname': value => $qpid_hostname;
      'qpid_port': value => $qpid_port;
      'qpid_username': value => $qpid_username;
      'qpid_password': value => $qpid_password;
      'qpid_reconnect': value => $qpid_reconnect;
      'qpid_reconnect_timeout': value => $qpid_reconnect_timeout;
      'qpid_reconnect_limit': value => $qpid_reconnect_limit;
      'qpid_reconnect_interval_min': value => $qpid_reconnect_interval_min;
      'qpid_reconnect_interval_max': value => $qpid_reconnect_interval_max;
      'qpid_reconnect_interval': value => $qpid_reconnect_interval;
      'qpid_heartbeat': value => $qpid_heartbeat;
      'qpid_protocol': value => $qpid_protocol;
      'qpid_tcp_nodelay': value => $qpid_tcp_nodelay;
    }
  }

}
