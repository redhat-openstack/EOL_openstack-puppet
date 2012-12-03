class quantum::agents::metadata (
  $enabled = true,
  $nova_metadata_ip              = $ipaddress,
  $nova_metadata_port            = 8775,
  $metadata_proxy_shared_secret  = '',
  $state_path                    = '/var/lib/quantum',
  $root_helper              = "sudo /usr/bin/quantum-rootwrap /etc/quantum/rootwrap.conf"
) inherits quantum {
  Package['quantum'] -> Quantum_metadata_agent_config<||>
  Quantum_config<||> ~> Service["quantum-metadata-service"]
  Quantum_metadata_agent_config<||> ~> Service["quantum-metadata-service"]

  quantum_metadata_agent_config {
    "DEFAULT/debug":                        value => $log_debug;
    "DEFAULT/auth_host":                    value => $auth_host;
    "DEFAULT/auth_port":                    value => $auth_port;
    "DEFAULT/auth_uri":                     value => $auth_uri;
    "DEFAULT/admin_tenant_name":            value => $keystone_tenant;
    "DEFAULT/admin_user":                   value => $keystone_user;
    "DEFAULT/admin_password":               value => $keystone_password;
    "DEFAULT/nova_metadata_ip":             value => $nova_metadata_ip;
    "DEFAULT/nova_metadata_port":           value => $nova_metadata_port;
    "DEFAULT/root_helper":                  value => $root_helper;
    "DEFAULT/metadata_proxy_shared_secret": value => $metadata_proxy_shared_secret;
  }

  if $enabled {
    $ensure = 'running'
  } else {
    $ensure = 'stopped'
  }

  service { 'quantum-metadata-service':
    name    => $::quantum::params::metadata_service,
    enable  => $enabled,
    ensure  => $ensure,
    require => Class['quantum'],
  }

}
