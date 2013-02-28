class keystone() {

  package { 'python-keystone': ensure => 'present' }
  package { 'python-oslo-config': ensure => 'present' }

}
