#
# class for installing qpid server for cinder
#
#
class cinder::qpid(
  $user='guest',
  $password='guest',
  $file='/var/lib/qpidd/qpidd.sasldb',
  $realm='OPENSTACK'
) {

  # only configure cinder after the queue is up
  Class['qpid::server'] -> Package<| title == 'openstack-cinder' |>

  qpid_user { $user:
    password  => $password,
    file  => $file,
    realm  => $realm,
    provider => 'saslpasswd2',
    require   => Class['qpid::server'],
  }

}
