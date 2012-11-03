class quantum::agents::linuxbridge (
  $enabled = true,
  $controller = false
) inherits quantum::plugins::linuxbridge {

  Package['quantum'] ->  Package['quantum-plugin-linuxbridge']
  Package["quantum-plugin-linuxbridge"] -> Quantum_plugin_linuxbridge<||>
  Quantum_config<||> ~> Service["quantum-plugin-linuxbridge-service"]

  if defined(Service['quantum-server']) {
    Service["quantum-server"] -> Service["quantum-plugin-linuxbridge-service"]
  }

  if $enabled {
    $service_ensure = "running"
  } else {
    $service_ensure = "stopped"
  }

  service { 'quantum-plugin-linuxbridge-service':
    name    => $::quantum::params::linuxbridge_agent_service,
    enable  => $enable,
    ensure  => $service_ensure,
    require => Package["quantum-plugin-linuxbridge"],
  }

}
