#
# class for installing rabbitmq server for cinder
#
#
class cinder::rabbitmq(
  $userid='guest',
  $password='guest',
  $port='5672',
  $virtual_host='/',
  $install_repo = false
) {

  # only configure cinder after the queue is up
  Class['rabbitmq::service'] -> Package<| title == 'openstack-cinder' |>

  # work around hostname bug, LP #653405
  host { $hostname:
    ip => $ipaddress,
    host_aliases => $fqdn,
  }

  if $install_repo {
    # this is debian specific
    class { 'rabbitmq::repo::apt':
      pin    => 900,
      before => Class['rabbitmq::server']
    }
  }
  if $userid == 'guest' {
    $delete_guest_user = false
  } else {

    $delete_guest_user = true
    rabbitmq_user { $userid:
      admin     => true,
      password  => $password,
      provider => 'rabbitmqctl',
      require   => Class['rabbitmq::server'],
    }
    # I need to figure out the appropriate permissions
    rabbitmq_user_permissions { "${userid}@${virtual_host}":
      configure_permission => '.*',
      write_permission     => '.*',
      read_permission      => '.*',
      provider             => 'rabbitmqctl',
    }->Package<| title == 'openstack-cinder' |>
  }

  class { 'rabbitmq::server':
    port              => $port,
    delete_guest_user => $delete_guest_user,
  }

  rabbitmq_vhost { $virtual_host:
    provider => 'rabbitmqctl',
    require => Class['rabbitmq::server'],
  }

}
