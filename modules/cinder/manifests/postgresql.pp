#
# class for installing postgresql server for cinder
#
#
class cinder::postgresql(
  $db_name='cinder',
  $db_user='cinder',
  $db_password='p@ssw0rd$',
  $db_host='localhost'
) {

  Class['postgresql::server'] -> Package<| title == 'openstack-cinder' |>

  postgresql_database_user { $db_name:
    db_user  => $db_user,
    db_password  => $db_password,
    provider => 'psql',
    require   => Class['postgresql::server'],
    notify       => Exec["cinder-db-sync"],
  }

}
