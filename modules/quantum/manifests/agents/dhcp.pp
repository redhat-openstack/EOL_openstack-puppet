class quantum::agents::dhcp (
  $state_path         = "/var/lib/quantum",
  $interface_driver   = "quantum.agent.linux.interface.OVSInterfaceDriver",
  $dhcp_driver        = "quantum.agent.linux.dhcp.Dnsmasq",
  $use_namespaces     = "True",
  $resync_interval    = "30",
  $root_helper        = "sudo /usr/bin/quantum-rootwrap /etc/quantum/rootwrap.conf"
) inherits quantum {

  Package['quantum'] -> Quantum_dhcp_agent_config<||>
  Quantum_config<||> ~> Service["quantum-dhcp-service"]
  Quantum_dhcp_agent_config<||> ~> Service["quantum-dhcp-service"]

  if defined(Service['quantum-server']) {
    Service["quantum-server"] -> Service["quantum-dhcp-service"]
  }

  quantum_dhcp_agent_config {
    "DEFAULT/debug":              value => $log_debug;
    "DEFAULT/state_path":         value => $state_path;
    "DEFAULT/resync_interval":         value => $resync_interval;
    "DEFAULT/interface_driver":   value => $interface_driver;
    "DEFAULT/dhcp_driver":        value => $dhcp_driver;
    "DEFAULT/use_namespaces":     value => $use_namespaces;
    "DEFAULT/root_helper":        value => $root_helper;
  }

  if $enabled {
    $ensure = 'running'
  } else {
    $ensure = 'stopped'
  }

  service { 'quantum-dhcp-service':
    name    => $::quantum::params::dhcp_service,
    enable  => $enabled,
    ensure  => $ensure,
    require => Class['quantum'],
  }
}
