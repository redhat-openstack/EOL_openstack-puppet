#
# class for installing postgresql server for keystone
#
#
class keystone::postgresql(
  $db_name='keystone',
  $db_user='keystone',
  $db_password='p@ssw0rd$',
  $db_host='localhost'
) {

  Class['postgresql::server'] -> Package<| title == 'openstack-keystone' |>

  postgresql_database_user { $db_name:
    db_user  => $db_user,
    db_password  => $db_password,
    provider => 'psql',
    require   => Class['postgresql::server'],
  }

}
