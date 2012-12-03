class quantum::agents::l3 (
  $enabled = true,
  $interface_driver         = "quantum.agent.linux.interface.OVSInterfaceDriver",
  $use_namespaces           = "True",
  $router_id                = "",
  $metadata_port            = "9697",
  $state_path               = "/var/lib/quantum",
  $external_network_bridge  = "br-ex",
  $handle_internal_only_routers  = "True",
  $root_helper              = "sudo /usr/bin/quantum-rootwrap /etc/quantum/rootwrap.conf"
) inherits quantum {
  Package['quantum'] -> Quantum_l3_agent_config<||>
  Quantum_config<||> ~> Service["quantum-l3-service"]
  Quantum_l3_agent_config<||> ~> Service["quantum-l3-service"]

  Sysctl<||> -> Service["quantum-l3-service"]

  exec { 'reload_sysctl':
    command => "/sbin/sysctl -p /etc/sysctl.conf",
    refreshonly => true
  }

  sysctl {"net.ipv4.ip_forward":
    val => "1",
    notify => Exec['reload_sysctl']
  }

  if defined(Service['quantum-server']) {
    Service["quantum-server"] -> Service["quantum-l3-service"]
  }

  if $gateway_external_network_id {
    quantum_l3_agent_config {
      "DEFAULT/gateway_external_network_id":  value => $gateway_external_network_id;
    }
  }

  quantum_l3_agent_config {
    "DEFAULT/debug":                    value => $log_debug;
    "DEFAULT/interface_driver":         value => $interface_driver;
    "DEFAULT/auth_host":                value => $auth_host;
    "DEFAULT/auth_port":                value => $auth_port;
    "DEFAULT/auth_uri":                 value => $auth_uri;
    "DEFAULT/admin_tenant_name":        value => $keystone_tenant;
    "DEFAULT/admin_user":               value => $keystone_user;
    "DEFAULT/admin_password":           value => $keystone_password;
    "DEFAULT/use_namespaces":           value => $use_namespaces;
    "DEFAULT/router_id":                value => $router_id;
    "DEFAULT/metadata_port":            value => $metadata_port;
    "DEFAULT/state_path":               value => $state_path;
    "DEFAULT/external_network_bridge":  value => $external_network_bridge;
    "DEFAULT/handle_internal_only_routers":  value => $handle_internal_only_routers;
    "DEFAULT/root_helper":              value => $root_helper;
  }

  if defined(Class["quantum::agents::ovs"]) {
    vs_bridge {$external_network_bridge:
      external_ids => "bridge-id=$external_network_bridge",
      ensure       => present,
      before       => Service['quantum-l3-service']
    }
  }

  if defined(Class["quantum::agents::linuxbridge"]) {
    bridge{$external_network_bridge:
      name => $external_network_bridge,
      provider => 'brctl',
      ensure => present,
      before       => Service['quantum-l3-service']
    }
  }

  if $enabled {
    $ensure = 'running'
  } else {
    $ensure = 'stopped'
  }

  service { 'quantum-l3-service':
    name    => $::quantum::params::l3_service,
    enable  => $enabled,
    ensure  => $ensure,
    require => Class['quantum'],
  }

}
