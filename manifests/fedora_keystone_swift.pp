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

class { 'nova::db':
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
  scheduler_default_filters => 'AvailabilityZoneFilter,RamFilter,ComputeFilter',
  allow_resize_to_same_host => true,
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
  default_store => 'swift',
  swift_store_auth_address => 'http://127.0.0.1:8080/auth/v1.0/',
  swift_store_user => 'test:tester',
  swift_store_key => 'testing',
  swift_store_create_container_on_put => 'True',
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


#
# Build a swift All in one, to be used by glance
#
$proxy_local_net_ip='127.0.0.1'
$swift_shared_secret='PfppwiB1WkoodcnJjFkHrbm5OY'

Exec { logoutput => true }

class { 'ssh::server::install': }

class { 'memcached':
  listen_ip => $proxy_local_net_ip,
}

class { 'swift':
  # not sure how I want to deal with this shared secret
  swift_hash_suffix => $swift_shared_secret,
  package_ensure => latest,
}

# create xfs partitions on a loopback device and mounts them
swift::storage::loopback { ['1', '2', '3']:
  require => Class['swift'],
  seek => '250000',
}

# sets up storage nodes which is composed of a single
# device that contains an endpoint for an object, account, and container

Swift::Storage::Node {
  mnt_base_dir         => '/srv/node',
  weight               => 1,
  manage_ring          => true,
  storage_local_net_ip => '127.0.0.1',
}

swift::storage::node { '1':
  zone                 => 1,
  require              => Swift::Storage::Loopback[1],
}

swift::storage::node { '2':
  zone                 => 2,
  require              => Swift::Storage::Loopback[2],
}

swift::storage::node { '3':
  zone                 => 3,
  require              => Swift::Storage::Loopback[3],
}

class { 'swift::ringbuilder':
  part_power     => '18',
  replicas       => '3',
  min_part_hours => 1,
  require        => Class['swift'],
}

class { 'swift::storage': }

# TODO should I enable swath in the default config?
class { 'swift::proxy':
  account_autocreate => true,
  require            => Class['swift::ringbuilder'],
}

# I need to start the storage services after the nodes are installed 
# since the init scipt looks for the config to start them all in one go
service{'openstack-swift-account':
    ensure => running,
    require => [Swift::Storage::Node["1"], Swift::Storage::Node["2"], Swift::Storage::Node["3"], Class["swift::storage"]]
}

service{'openstack-swift-container':
    ensure => running,
    require => [Swift::Storage::Node["1"], Swift::Storage::Node["2"], Swift::Storage::Node["3"], Class["swift::storage"]]
}

service{'openstack-swift-object':
    ensure => running,
    require => [Swift::Storage::Node["1"], Swift::Storage::Node["2"], Swift::Storage::Node["3"], Class["swift::storage"]]
}

