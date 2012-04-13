#
# class for installing postgresql server for nova
#
#
class nova::postgresql(
  $db_name='nova',
  $db_user='nova',
  $db_password='p@ssw0rd$',
  $db_host='localhost'
) {

  Class['postgresql::server'] -> Package<| title == 'openstack-nova' |>

  package { 'python-psycopg2':
    ensure => present,
  }

  postgresql_database_user { $db_name:
    db_user  => $db_user,
    db_password  => $db_password,
    provider => 'psql',
    require   => [Class['postgresql::server'], Package['python-psycopg2']],
    notify       => Exec["initial-db-sync"],
  }

}
