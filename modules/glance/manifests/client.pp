#
# class for installing glanceclient
#
#
class glance::client(
  $ensure='present',
) {

  package { 'python-glanceclient':
    ensure => $ensure,
  }

}
