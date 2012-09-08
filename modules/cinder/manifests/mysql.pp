class cinder::mysql(
  $password,
  $dbname = 'cinder',
  $user = 'cinder',
  $host = '127.0.0.1'
) {

  # Create the db instance before openstack-cinder if its installed
  Mysql::Db[$dbname] -> Package<| title == "openstack-cinder" |>

  mysql::db { $dbname:
    user         => $user,
    password     => $password,
    host         => $host,
    charset      => 'latin1',
    require      => Class['mysql::server'],
    notify       => Exec["cinder-db-sync"],
  }

}
