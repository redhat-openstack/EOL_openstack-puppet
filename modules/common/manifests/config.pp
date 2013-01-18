# Class: common::config
class common::config {

  #package { ['augeas', 'augeas-libs', 'ruby-augeas']:
    #ensure  => latest,
  #}

  file { '/usr/share/augeas/lenses/pythonpaste.aug':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    source  => 'puppet:///modules/common/pythonpaste.aug'
    #require  => [Package['augeas-libs'], Package['augeas'], Package['ruby-augeas']]
  }

}
