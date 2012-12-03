class quantum::params {
  case $::osfamily {
    'Fedora', 'Redhat': {
      $package_name       = 'openstack-quantum'
      $server_service     = 'quantum-server'

      $ovs_package        = 'openstack-quantum-openvswitch'
      $ovs_agent_service  = 'quantum-openvswitch-agent'

      $linuxbridge_package        = 'openstack-quantum-linuxbridge'
      $linuxbridge_agent_service  = 'quantum-linuxbridge-agent'

      $dhcp_package       = 'quantum-dhcp-agent'
      $dhcp_service       = 'quantum-dhcp-agent'

      $l3_package         = 'quantum-l3-agent'
      $l3_service         = 'quantum-l3-agent'
      $metadata_service   = 'quantum-metadata-agent'

      $kernel_headers     = "linux-headers-${::kernelrelease}"
    }
    'Debian', 'Ubuntu': {
      $package_name       = 'quantum-common'
      $server_service     = 'quantum-server'

      $ovs_package  = 'quantum-plugin-openvswitch-agent'
      $ovs_agent_service  = 'quantum-plugin-openvswitch-agent'
      $ovs_server_package = 'quantum-plugin-openvswitch'

      $dhcp_package       = 'quantum-dhcp-agent'
      $dhcp_service       = 'quantum-dhcp-agent'

      $l3_package         = 'quantum-l3-agent'
      $l3_service         = 'quantum-l3-agent'

      $kernel_headers     = "linux-headers-${::kernelrelease}"
    }
  }
}
