class vswitch::ovs(
  $package_ensure = 'present'
) {

  package { 'openvswitch':
     ensure => $package_ensure
  }

  service {"openvswitch":
    ensure      => running,
    enable      => true,
    hasstatus   => true,
    hasrestart   => true,
    require   => Package['openvswitch']
  }

}
