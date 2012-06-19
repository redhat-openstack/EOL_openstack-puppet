# Class: common::config
class common::config {

  package { ['augeas', 'augeas-libs']:
    ensure  => present,
  }

  file { '/usr/share/augeas/lenses/pythonpaste.aug':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    source  => 'puppet:///modules/common/pythonpaste.aug',
    require  => Package['augeas-libs']
  }

}
