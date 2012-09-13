class nova::mysql(
  $password,
  $dbname = 'nova',
  $user = 'nova',
  $host = '127.0.0.1'
) {

  # Create the db instance before openstack-nova if its installed
  Mysql::Db[$dbname] -> Package<| title == "openstack-nova-common" |>

  mysql::db { $dbname:
    user         => $user,
    password     => $password,
    host         => $host,
    charset      => 'latin1',
    require      => Class['mysql::server'],
    notify       => Exec["initial-db-sync"],
  }

}
