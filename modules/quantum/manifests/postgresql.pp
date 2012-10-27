#
# class for installing postgresql server for quantum
#
#
class quantum::postgresql(
  $db_name='quantum',
  $db_user='quantum',
  $db_password='p@ssw0rd$',
  $db_host='localhost'
) {

  if defined(Class['postgresql::server']) {
    Class['postgresql::server'] -> Package<| title == 'openstack-quantum' |>
    Class['postgresql::server'] -> Postgresql_database_user<||>
  }

  postgresql_database_user { $db_name:
    db_user  => $db_user,
    db_password  => $db_password,
    provider => 'psql'
  }

}
