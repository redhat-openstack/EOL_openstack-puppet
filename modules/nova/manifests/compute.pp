# this class should probably never be declared except
# from the virtualization implementation of the compute node
class nova::compute(
  $enabled = true
) {

  Exec['post-nova_config'] ~> Service['nova-compute']
  Exec['nova-db-sync']  ~> Service['nova-compute']

  if $enabled {
    $service_ensure = 'running'
  } else {
    $service_ensure = 'stopped'
  }

  package {"libvirt":
    ensure => 'present'
  }
  
  service {"libvirtd" :
    ensure => 'running',
    require => Package['libvirt']
  }

  package {'openstack-nova-compute':
    ensure  => present
  }

  service { "nova-compute":
    name => 'openstack-nova-compute',
    ensure  => $service_ensure,
    enable  => $enabled,
    require => [Package["openstack-nova-compute"], Service["libvirtd"]],
    before  => Exec['networking-refresh'],
  }

  # forward guest metadata requests to correct API server
  # $aws_address = '169.254.169.254'
  # $api_server,
  # $api_port = 8773,
#  exec { "forward_api_requests":
#    command => "/sbin/iptables -t nat -A PREROUTING -d ${aws_address}/32 -p tcp -m tcp --dport 80 -j DNAT --to-destination ${api_server}:${api_port}",
#    unless => "/sbin/iptables -L PREROUTING -t nat -n | egrep 'DNAT[ ]+tcp+[ ]+--[ ]+0.0.0.0\\/0+[ ]+${aws_address}+[ ]+tcp+[ ]+dpt:80+[ ]+to:${api_server}:${api_port}'",
#    logoutput => on_failure
#  }
}
