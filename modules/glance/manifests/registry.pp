class glance::registry(
  $log_verbose = 'False',
  $log_debug = 'False',
  $bind_host = '0.0.0.0',
  $bind_port = '9191',
  $log_file = '/var/log/glance/registry.log',
  $backlog = '4096',
  $sql_connection = 'sqlite:///var/lib/glance/glance.sqlite',
  $sql_idle_timeout = '3600',
  $sql_limit_max = '1000',
  $sql_limit_default = '25',
  $use_syslog = 'False',
  $syslog_log_facility = 'LOG_LOCAL1',
  $api_limit_max = '1000',
  $limit_param_default = '25',
  $cert_file = '',
  $key_file = '',
  $registry_flavor = ''
) inherits glance {

  file { "/etc/glance/glance-registry-paste.ini":
    ensure  => present,
    owner   => 'glance',
    group   => 'root',
    mode    => 640,
    content => template('glance/glance-registry-paste.ini.erb'),
    require => Class["glance"]
  }

  file { "/etc/glance/glance-registry.conf":
    ensure  => present,
    owner   => 'glance',
    group   => 'root',
    mode    => 640,
    content => template('glance/glance-registry.conf.erb'),
    require => Class["glance"]
  }

  service { "openstack-glance-registry":
    ensure     => running,
    enable     => true,
    hasstatus  => true,
    hasrestart => true,
    subscribe  => [File["/etc/glance/glance-registry.conf"], File["/etc/glance/glance-registry-paste.ini"]],
    require    => Class["glance"]
  }

}
