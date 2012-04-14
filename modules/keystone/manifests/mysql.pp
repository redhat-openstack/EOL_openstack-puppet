class keystone::mysql(
  $password,
  $dbname = 'keystone',
  $user = 'keystone',
  $host = '127.0.0.1'
) {

  # Create the db instance before openstack-keystone if its installed
  Mysql::Db[$dbname] -> Package<| title == "openstack-keystone" |>

  mysql::db { $dbname:
    user         => $user,
    password     => $password,
    host         => $host,
    charset      => 'latin1',
    require      => Class['mysql::server'],
  }

}
