#
# Builds out a default storage node
#   a storage node is a device that contains
#   a storage endpoint for account, container, and object
#   on the same mount point
#
define swift::storage::node(
  $mnt_base_dir,
  $zone,
  $weight = 1,
  $owner = 'swift',
  $group  = 'swift',
  $max_connections = 25,
  $workers = 1,
  $storage_local_net_ip = '0.0.0.0',
  $manage_ring = true
) {

  Swift::Storage::Server {
    storage_local_net_ip => $storage_local_net_ip,
    devices              => $mnt_base_dir,
    max_connections      => $max_connections,
    owner                => $owner,
    group                => $group,
  }

  swift::storage::server { "60${name}0":
    type => 'object',
  }
  ring_object_device { "${storage_local_net_ip}:60${name}0":
    zone        => $zone,
    device_name => $name,
    weight      => $weight,
  }

  swift::storage::server { "60${name}1":
    type => 'container',
  }
  ring_container_device { "${storage_local_net_ip}:60${name}1":
    zone        => $zone,
    device_name => $name,
    weight      => $weight,
  }

  swift::storage::server { "60${name}2":
    type => 'account',
  }
  ring_account_device { "${storage_local_net_ip}:60${name}2":
    zone        => $zone,
    device_name => $name,
    weight      => $weight,
  }

  service{"openstack-swift-object@60${name}0":
    ensure => running,
    require => [Swift::Storage::Server["60${name}0"], File["/etc/swift/object-server/60${name}0.conf"], Ring_object_device["${storage_local_net_ip}:60${name}0"]]
  }

  service{"openstack-swift-container@60${name}1":
    ensure => running,
    require => [Swift::Storage::Server["60${name}1"], File["/etc/swift/container-server/60${name}1.conf"], Ring_container_device["${storage_local_net_ip}:60${name}1"]]
  }

  service{"openstack-swift-account@60${name}2":
    ensure => running,
    require => [Swift::Storage::Server["60${name}2"], File["/etc/swift/account-server/60${name}2.conf"], Ring_account_device["${storage_local_net_ip}:60${name}2"]]
  }

}
