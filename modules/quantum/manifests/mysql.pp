class quantum::mysql(
  $password,
  $dbname = 'quantum',
  $user = 'quantum',
  $host = '127.0.0.1'
) {

  if defined(Class['mysql::server']) {
    # Create the db instance before openstack-quantum if its installed
    Mysql::Db[$dbname] -> Package<| title == "openstack-quantum" |>
  }

  mysql::db { $dbname:
    user         => $user,
    password     => $password,
    host         => $host,
    charset      => 'latin1',
    require      => Class['mysql::server']
  }

}
