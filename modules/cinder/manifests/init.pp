class cinder(
  $db_password,
  $db_driver = 'mysql',
  $db_name = 'cinder',
  $db_user = 'cinder',
  $db_host = 'localhost',

  $auth_strategy = 'keystone',
  $scheduler_driver = 'cinder.scheduler.simple.SimpleScheduler',

  $rpc_backend = 'cinder.openstack.common.rpc.impl_kombu',
  $control_exchange = 'cinder',

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

  $logdir = '/var/log/cinder',
  $state_path = '/var/lib/cinder',
  $lock_path = '/var/lock/cinder',
  $verbose = false

) {

  Cinder_config<| |> {
    require +> Package["openstack-cinder"],
    before +> File['/etc/cinder/cinder.conf'],
    notify +> Exec['post-cinder_config']
  }

  package { ["python-cinder", "openstack-cinder"]:
    ensure  => present
  }

  group { 'cinder':
    ensure => present
  }

  user { 'cinder':
    ensure => present,
    gid    => 'cinder',
  }

  file { $logdir:
    ensure  => directory,
    mode    => '751',
    owner   => 'cinder',
    group   => 'cinder',
    require => Package['openstack-cinder'],
  }

  file { '/etc/cinder/cinder.conf':
    owner => 'cinder',
    group => 'cinder',
    mode  => '0640',
  }

  exec { "cinder-db-sync":
    command     => "/usr/bin/cinder-manage db sync",
    refreshonly => "true",
    require     => [Package["openstack-cinder"], Cinder_config['sql_connection']],
  }

  cinder_config { 'sql_connection': value => "${db_driver}://${db_user}:${db_password}@${db_host}/${db_name}" }

  cinder_config {
    'verbose': value => $verbose;
    'logdir': value => $logdir;
    'rpc_backend': value => $rpc_backend;
    'auth_strategy': value => $auth_strategy;
    'scheduler_driver': value => $scheduler_driver;
    'control_exchange': value => $control_exchange;
    'state_path': value => $state_path;
    'lock_path': value => $lock_path;
    'iscsi_helper': value => 'tgtadm';
    'rootwrap_config': value => '/etc/cinder/rootwrap.conf';
  }

  exec { 'post-cinder_config':
    command => '/bin/echo "Cinder config has changed"',
    refreshonly => true,
  }

  if $rpc_backend == 'cinder.openstack.common.rpc.impl_kombu' {
    cinder_config {
      'rabbit_host': value => $rabbit_host;
      'rabbit_password': value => $rabbit_password;
      'rabbit_port': value => $rabbit_port;
      'rabbit_userid': value => $rabbit_userid;
      'rabbit_virtual_host': value => $rabbit_virtual_host;
    }
  }

  if $rpc_backend == 'cinder.openstack.common.rpc.impl_qpid' {
    cinder_config {
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
