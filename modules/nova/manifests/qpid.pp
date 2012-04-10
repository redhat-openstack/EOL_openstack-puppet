#
# class for installing qpid server for nova
#
#
class nova::qpid(
  $user='guest',
  $password='guest',
  $file='/var/lib/qpidd/qpidd.sasldb',
  $realm='OPENSTACK'
) {

  qpid_user { $user:
    password  => $password,
    file  => $file,
    realm  => $realm,
    provider => 'saslpasswd2',
    require   => Class['qpid::server'],
  }

}
