class quantum::plugins::linuxbridge (
  $sql_connection       = 'sqlite:////var/lib/quantum/linuxbridge.sqlite',
  $tenant_network_type  = "local",
  $network_vlan_ranges  = "",
  $polling_interval     = "2",
  $reconnect_interval   = "2"

) inherits quantum {

  Package["quantum-plugin-linuxbridge"] -> Quantum_plugin_linuxbridge<||>

  if defined(Service['quantum-server']) {
    File['/etc/quantum/plugin.ini'] -> Service['quantum-server']
    Quantum_config<||> ~> Service["quantum-server"]
    Quantum_plugin_linuxbridge<||> ~> Service["quantum-server"]
  }

  package { "quantum-plugin-linuxbridge":
    name    => $::quantum::params::linuxbridge_package,
    ensure  => $package_ensure,
    require => [Class['quantum']]
  }

  quantum_plugin_linuxbridge {
    'DATABASE/sql_connection': value => $sql_connection;
    'DATABASE/reconnect_interval': value => $reconnect_interval;
    'AGENT/polling_interval': value => $polling_interval;
    "VLANS/network_vlan_ranges":  value => $network_vlan_ranges;
    "VLANS/tenant_network_type":  value => $tenant_network_type;
  }

  if $physical_interface_mappings {
    quantum_plugin_linuxbridge {
      "LINUX_BRIDGE/physical_interface_mappings":      value => $physical_interface_mappings;
    }
  }

  file {"/etc/quantum/plugin.ini":
    ensure => link,
    target => "/etc/quantum/plugins/linuxbridge/linuxbridge_conf.ini",
    require => Package['quantum-plugin-linuxbridge']
  }

}
