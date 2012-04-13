class nova::mysql(
  $password,
  $dbname = 'nova',
  $user = 'nova',
  $host = '127.0.0.1',
  $allowed_hosts = undef,
  $cluster_id = 'localzone'
) {

  # Create the db instance before openstack-nova if its installed
  Mysql::Db[$dbname] -> Package<| title == "openstack-nova" |>

  mysql::db { $dbname:
    user         => $user,
    password     => $password,
    host         => $host,
    charset      => 'latin1',
    require      => Class['mysql::server'],
    notify       => Exec["initial-db-sync"],
  }

  if $allowed_hosts {
     nova::mysql::host_access { $allowed_hosts:
      user      => $user,
      password  => $password,
      database  => $dbname,
    }
  }

}
