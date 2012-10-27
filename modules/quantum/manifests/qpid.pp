#
# class for installing qpid server for quantum
#
#
class quantum::qpid(
  $user='guest',
  $password='guest',
  $file='/var/lib/qpidd/qpidd.sasldb',
  $realm='OPENSTACK'
) {

  if defined(Class['qpid::server']) {
    # only configure quantum after the queue is up
    Class['qpid::server'] -> Package<| title == 'openstack-quantum' |>
    Class['qpid::server'] -> Qpid_user<||>
  }

  qpid_user { $user:
    password  => $password,
    file  => $file,
    realm  => $realm,
    provider => 'saslpasswd2'
  }

}
