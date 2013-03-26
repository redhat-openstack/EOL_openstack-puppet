class quantum::server (
  $enabled = true,
  $log_file = "/var/log/quantum/server.log",
  $root_helper        = "sudo /usr/bin/quantum-rootwrap /etc/quantum/rootwrap.conf"
) inherits quantum {

  Package["quantum"] -> Quantum_api_config<||>
  Quantum_config<||> ~> Service["quantum-server"]
  Quantum_api_config<||> ~> Service["quantum-server"]

  if ($sql_connection =~ /mysql:\/\/\S+:\S+@\S+\/\S+/) {
    Package['python-mysqldb'] -> Service['quantum-server']
  } elsif ($sql_connection =~ /postgresql:\/\/\S+:\S+@\S+\/\S+/) {
    Package['python-psycopg2'] -> Service['quantum-server']
  } elsif($sql_connection =~ /sqlite:\/\//) {
    Package['python-pysqlite2'] -> Service['quantum-server']
  } else {
    fail("Invalid db connection ${sql_connection}")
  }

  quantum_config {
    "AGENT/root_helper":    value => $root_helper;
  }

  quantum_api_config {
    "filter:authtoken/auth_host": value => $auth_host;
    "filter:authtoken/auth_port": value => $auth_port;
    "filter:authtoken/auth_uri": value => $auth_uri;
    "filter:authtoken/admin_tenant_name": value => $keystone_tenant;
    "filter:authtoken/admin_user": value => $keystone_user;
    "filter:authtoken/admin_password": value => $keystone_password;
  }

  if $enabled {
    $service_ensure = "running"
  } else {
    $service_ensure = "stopped"
  }

  service {"quantum-server":
    name       => $::quantum::params::server_service,
    ensure     => $service_ensure,
    enable     => $enabled,
    hasstatus  => true,
    hasrestart => true,
    require => Package["quantum"]
  }

}
