class quantum::agents::ovs (
  $controller = false
) inherits quantum::plugins::ovs {

  Package['quantum'] ->  Package['quantum-plugin-ovs']
  Package["quantum-plugin-ovs"] -> Quantum_plugin_ovs<||>
  Quantum_config<||> ~> Service["quantum-plugin-ovs-service"]

  if defined(Service['quantum-server']) {
    Service["quantum-server"] -> Service["quantum-plugin-ovs-service"]
  }

  class {
    "vswitch":
      provider => ovs
  }

  vs_bridge {$integration_bridge:
    external_ids => "bridge-id=$integration_bridge",
    ensure       => present
  }
  
  if $enable_tunneling {
    vs_bridge {$tunnel_bridge:
      external_ids => "bridge-id=$tunnel_bridge",
      ensure       => present
    }
  }

  if $bridge_mapping {
    quantum::plugins::ovs::bridge{$bridge_mappings:}
  }
  if $bridge_uplinks {
    quantum::plugins::ovs::port{$bridge_uplinks:}
  }

  if $enabled {
    $service_ensure = "running"
  } else {
    $service_ensure = "stopped"
  }

  service { 'quantum-plugin-ovs-service':
    name    => $::quantum::params::ovs_agent_service,
    enable  => $enable,
    ensure  => $service_ensure,
    require => Package["quantum-plugin-ovs"],
  }

}
