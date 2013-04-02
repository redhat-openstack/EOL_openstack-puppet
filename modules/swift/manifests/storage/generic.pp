# Creates the files packages and services that are
# needed to deploy each type of storage server.
#
# == Parameters
#  [*package_ensure*] The desired ensure state of the swift storage packages.
#    Optional. Defaults to present.
#  [*service_provider*] The provider to use for the service
#
# == Dependencies
#  Requires Class[swift::storage]
# == Examples
#
# == Authors
#
#   Dan Bode dan@puppetlabs.com
#
# == Copyright
#
# Copyright 2011 Puppetlabs Inc, unless otherwise noted.
define swift::storage::generic(
  $bind_port,
  $package_ensure   = 'present',
  $service_provider = $::swift::params::service_provider
) {

  include swift::params

  Class['swift::storage'] -> Swift::Storage::Generic[$name]

  validate_re($name, '^object|container|account$')

  package { "swift-${name}":
    # this is a way to dynamically build the variables to lookup
    # sorry its so ugly :(
    name   => inline_template("<%= scope.lookupvar('::swift::params::${name}_package_name') %>"),
    ensure => $package_ensure,
    before => Service["swift-${name}", "swift-${name}-replicator"],
  }

  file { "/etc/swift/${name}-server/":
    ensure => directory,
    owner  => 'swift',
    group  => 'swift',
  }

  if $operatingsystem == "Fedora" {

     # Fedora 17/18 now use systemd
     service { "swift-${name}":
      name      => "openstack-swift-$name@$bind_port",
      ensure    => running,
      hasstatus => true,
      provider  => $service_provider,
      subscribe => Package["swift-${name}"],
    }

    service { "swift-${name}-replicator":
      name      => "openstack-swift-$name-replicator@$bind_port",
      ensure    => running,
      hasstatus => true,
      provider  => $service_provider,
      subscribe => Package["swift-${name}"],
    }

  } else {

    service { "swift-${name}":
      name      => inline_template("<%= scope.lookupvar('::swift::params::${name}_service_name') %>"),
      ensure    => running,
      enable    => true,
      hasstatus => true,
      provider  => $service_provider,
      subscribe => Package["swift-${name}"],
    }

    service { "swift-${name}-replicator":
      name      => inline_template("<%= scope.lookupvar('::swift::params::${name}_replicator_service_name') %>"),
      ensure    => running,
      enable    => true,
      hasstatus => true,
      provider  => $service_provider,
      subscribe => Package["swift-${name}"],
    }

    if $operatingsystem == "Ubuntu" and $name == "container" {
      # The following container service conf is missing in Ubunty 12.04
      file { '/etc/init/swift-container-sync.conf':
        source  => 'puppet:///modules/swift/swift-container-sync.conf.upstart',
        require => Package['swift-container'],
      }
      file { '/etc/init.d/swift-container-sync':
        ensure => link,
        target => '/lib/init/upstart-job',
      }
      service { 'swift-container-sync':
        ensure    => running,
        enable    => true,
        provider  => $::swift::params::service_provider,
        require   => File['/etc/init/swift-container-sync.conf', '/etc/init.d/swift-container-sync']
      }

    }

  }

}
