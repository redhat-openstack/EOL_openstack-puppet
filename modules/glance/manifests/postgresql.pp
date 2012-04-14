#
# class for installing postgresql server for glance
#
#
class glance::postgresql(
  $db_name='glance',
  $db_user='glance',
  $db_password='p@ssw0rd$',
  $db_host='localhost'
) {

  Class['postgresql::server'] -> Package<| title == 'openstack-glance' |>

  postgresql_database_user { $db_name:
    db_user  => $db_user,
    db_password  => $db_password,
    provider => 'psql',
    require   => Class['postgresql::server'],
  }

}
