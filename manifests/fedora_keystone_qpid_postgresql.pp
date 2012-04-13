$db_driver     = 'postgresql'
$db_host     = 'localhost'
$db_name     = 'nova'
$db_user = 'nova'
$db_password = 'password'

$old_root_password = ''
$root_password = ''

$glance_api_servers = 'localhost:9292'
$glance_host        = 'localhost'
$glance_port        = '9292'

$api_server = 'localhost'

$nova_admin_user = 'admin'
$nova_project_name = 'nova'

$nova_network = '192.168.0.0/24'
$floating_network = '172.20.0.0/24'

$lock_path = '/var/lib/nova/tmp'

$qpid_password = 'p@ssw0rd'
$qpid_user = 'nova_qpid'
$qpid_realm = 'OPENSTACK'

resources { 'nova_config':
  purge => true,
}

class { 'qpid::server':
  realm => $qpid_realm,
}

class { 'nova::qpid':
  user => $qpid_user,
  password => $qpid_password,
  realm => $qpid_realm,
}

class { 'keystone': }

class { 'keystone::api': }

class { 'postgresql::server': }

class { 'nova::postgresql':
  db_password      => $db_password,
  db_name        => $db_name,
  db_user          => $db_user,
  db_host          => $db_host
}

class { 'nova::controller':
  db_driver => $db_driver,
  db_password => $db_password,
  db_name => $db_name,
  db_user => $db_user,
  db_host => $db_host,

  image_service => 'nova.image.glance.GlanceImageService',

  glance_api_servers => $glance_api_servers,
  glance_host => $glance_host,
  glance_port => $glance_port,

  libvirt_type => 'qemu',

  admin_user => $nova_admin_user,
  project_name => $nova_project_name,

  nova_network => $nova_network,
  floating_network => $floating_network,
  keystone_enabled => true,
  scheduler_default_filters => 'AvailabilityZoneFilter,ComputeFilter',
  allow_resize_to_same_host => true,
  libvirt_wait_soft_reboot_seconds => 15,
  require => Class["keystone"],
  rpc_backend => 'nova.rpc.impl_qpid',
  qpid_username => $qpid_user,
  qpid_password => $qpid_password,
}

class { 'nova::compute':
  api_server     => $api_server,
  enabled        => true,
  api_port       => 8773,
  aws_address    => '169.254.169.254',
}

class { 'glance::api':
  api_flavor => 'keystone+cachemanagement',
  require => Class["keystone"]
}

class { 'glance::registry':
  registry_flavor => 'keystone',
  require => Class["keystone"]
}
