$db_host     = 'localhost'
$db_name     = 'nova'
$db_username = 'nova'
$db_password = 'password'

$old_root_password = ''
$root_password = ''

$rabbit_user     = 'guest'
$rabbit_password = 'guest'
$rabbit_vhost    = '/'
$rabbit_host     = 'localhost'
$rabbit_port     = '5672'

$glance_api_servers = 'localhost:9292'
$glance_host        = 'localhost'
$glance_port        = '9292'

$api_server = 'localhost'

$nova_admin_user = 'admin'
$nova_project_name = 'nova'

$nova_network = '192.168.0.0/24'
$floating_network = '172.20.0.0/24'

$lock_path = '/var/lib/nova/tmp'

resources { 'nova_config':
  purge => true,
}

class { 'mysql::server':
  config_hash => {
                  'bind_address' => '0.0.0.0',
                   #'root_password' => '',
                   #'etc_root_password' => true
                 }
}

class { 'mysql::ruby': 
  package_provider => 'yum',
  package_name => 'ruby-mysql',
}

class { 'keystone': }

class { 'keystone::api': }

class { 'nova::mysql':
  password      => $db_password,
  dbname        => $db_name,
  user          => $db_username,
  host          => $clientcert,
  # does glance need access?
  allowed_hosts => ['localhost'],
}

class { 'nova::controller':
  db_password => $db_password,
  db_name => $db_name,
  db_user => $db_username,
  db_host => $db_host,

  rabbit_password => $rabbit_password,
  rabbit_port => $rabbit_port,
  rabbit_userid => $rabbit_user,
  rabbit_virtual_host => $rabbit_vhost,
  rabbit_host => $rabbit_host,

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

class { 'nova::rabbitmq':
  userid       => $rabbit_user,
  password     => $rabbit_password,
  port         => $rabbit_port,
  virtual_host => $rabbit_vhost,
}
