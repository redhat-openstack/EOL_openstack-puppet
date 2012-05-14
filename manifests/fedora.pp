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

class { 'nova::mysql':
  password      => $db_password,
  dbname        => $db_name,
  user          => $db_username,
  host          => $db_host,
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

  nova_network => $nova_network,
  floating_network => $floating_network,

}

class { 'nova::compute':
  api_server     => $api_server,
  enabled        => true,
  api_port       => 8773,
  aws_address    => '169.254.169.254',
}

# set up glance server
class { 'glance::api':
  swift_store_user => 'foo_user',
  swift_store_key => 'foo_pass',
}

class { 'glance::registry': }

class { 'nova::rabbitmq':
  userid       => $rabbit_user,
  password     => $rabbit_password,
  port         => $rabbit_port,
  virtual_host => $rabbit_vhost,
}
