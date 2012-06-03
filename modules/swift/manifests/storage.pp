#
#  Configures a swift storage node to host servers for object,
#  container, and accounts.
#
#  Includes:
#    installing an rsync server
#    installs storeage packages (object,account,containers)
# == Parameters
#  [*storeage_local_net_ip*] ip address that the swift servers should
#    bind to. Optional. Defaults to 0.0.0.0 .
#  [*package_ensure*] The desired ensure state of the swift storage packages.
#    Optional. Defaults to present.
#  [*devices*] The path where the managed volumes can be found.
#    This assumes that all servers use the same path.
#    Optional. Defaults to /srv/node/
#  [*object_port*] Port where object storage server should be hosted.
#    Optional. Defaults to 6000.
#  [*container_port*] Port where the container storage server should be hosted.
#    Optional. Defaults to 6001.
#  [*account_port*] Port where the account storage server should be hosted.
#    Optional. Defaults to 6002.
# == Dependencies
#
# == Examples
#
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
#
class swift::storage(
  $package_ensure = 'present',
  $storage_local_net_ip = '0.0.0.0',
  $devices = '/srv/node',
  $object_port = '6000',
  $container_port = '6001',
  $account_port = '6002'
) inherits swift {


  class{ 'rsync::server':
    use_xinetd => true,
    address => $storage_local_net_ip,
  }

  Service {
    ensure    => running,
    enable    => true,
    hasstatus => true,
    #subscribe => Service['rsync'],
  }

  File {
    owner => 'swift',
    group => 'swift',
  }

  Swift::Storage::Server {
    devices              => $devices,
    storage_local_net_ip => $storage_local_net_ip,
  }

  # package dependencies
  package { ['xfsprogs']:
    ensure => 'present'
  }

  package { 'openstack-swift-account':
    ensure => $package_ensure,
  }

  file { '/etc/swift/account-server/':
    ensure => directory,
  }

  # container server configuration
  package { 'openstack-swift-container':
    ensure => $package_ensure,
  }

  file { '/etc/swift/container-server/':
    ensure => directory,
  }

  # object server configuration
  package { 'openstack-swift-object':
    ensure => $package_ensure,
  }

  file { '/etc/swift/object-server/':
    ensure => directory,
  }

  file { "/etc/swift/${type}-server.conf":
	ensure => "absent"
  }

}
