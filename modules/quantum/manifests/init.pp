class quantum (
  $package_ensure       = true,
  $log_verbose          = "False",
  $log_debug            = "False",

  $bind_host            = "0.0.0.0",
  $bind_port            = "9696",
  $sql_connection       = "sqlite:///var/lib/quantum/quantum.sqlite",

  $auth_type            = "keystone",
  $auth_host            = "localhost",
  $auth_port            = "35357",
  $auth_uri             = "http://localhost:5000",
  $auth_strategy        = "keystone",
  $keystone_tenant      = "service",
  $keystone_user        = "quantum",
  $keystone_password    = "ChangeMe",

  $rabbit_host          = "localhost",
  $rabbit_port          = "5672",
  $rabbit_userid          = "guest",
  $rabbit_password      = "guest",
  $rabbit_virtual_host  = "/",

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

  $rpc_backend          = 'quantum.openstack.common.rpc.impl_kombu',

  $control_exchange     = "quantum",

  $core_plugin            = "quantum.plugins.openvswitch.ovs_quantum_plugin.OVSQuantumPluginV2",
  $mac_generation_retries = 16,
  $dhcp_lease_duration    = 120
) {
  include quantum::params

  validate_re($sql_connection, '(sqlite|mysql|postgresql):\/\/(\S+:\S+@\S+\/\S+)?')

  Package['quantum'] -> Quantum_config<||>

  if ($sql_connection =~ /mysql:\/\/\S+:\S+@\S+\/\S+/) {
    ensure_resource( 'package', 'python-mysqldb', {'ensure' => 'present'})
  } elsif ($sql_connection =~ /postgresql:\/\/\S+:\S+@\S+\/\S+/) {
    ensure_resource( 'package', 'python-psycopg2', {'ensure' => 'present'})
  } elsif($sql_connection =~ /sqlite:\/\//) {
    ensure_resource( 'package', 'python-pysqlite2', {'ensure' => 'present'})
  } else {
    fail("Invalid db connection ${sql_connection}")
  }

  file {"/etc/quantum":
    ensure  => directory,
    owner   => "quantum",
    group   => "root",
    mode    => 770,
    require => Package["quantum"]
  }

  package {"quantum":
    name   => $::quantum::params::package_name,
    ensure => $package_ensure
  }

  quantum_config {
    "DEFAULT/verbose":    value => $log_verbose;
    "DEFAULT/debug":      value => $log_debug;

    "DEFAULT/bind_host":  value => $bind_host;
    "DEFAULT/bind_port":  value => $bind_port;

    "DEFAULT/sql_connection":       value => $sql_connection;

    "DEFAULT/rpc_backend":          value => $rpc_backend;

    "DEFAULT/auth_strategy":        value => $auth_strategy;

    "DEFAULT/control_exchange":     value => $control_exchange;

    "DEFAULT/core_plugin":            value => $core_plugin;
    "DEFAULT/mac_generation_retries": value => $mac_generation_retries;
    "DEFAULT/dhcp_lease_duration":    value => $dhcp_lease_duration;
  }

  if $rpc_backend == 'quantum.openstack.common.rpc.impl_kombu' {
    quantum_config {
      'DEFAULT/rabbit_host': value => $rabbit_host;
      'DEFAULT/rabbit_password': value => $rabbit_password;
      'DEFAULT/rabbit_port': value => $rabbit_port;
      'DEFAULT/rabbit_userid': value => $rabbit_userid;
      'DEFAULT/rabbit_virtual_host': value => $rabbit_virtual_host;
    }
  }

  if $rpc_backend == 'quantum.openstack.common.rpc.impl_qpid' {
    quantum_config {
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
