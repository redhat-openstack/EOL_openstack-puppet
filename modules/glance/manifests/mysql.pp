class glance::mysql(
  $password,
  $dbname = 'glance',
  $user = 'glance',
  $host = '127.0.0.1'
) {

  # Create the db instance before openstack-glance if its installed
  Mysql::Db[$dbname] -> Package<| title == "openstack-glance" |>

  mysql::db { $dbname:
    user         => $user,
    password     => $password,
    host         => $host,
    charset      => 'latin1',
    require      => Class['mysql::server'],
  }

}
