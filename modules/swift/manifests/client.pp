#
# class for installing swiftclient
#
#
class swift::client(
  $ensure='present',
) {

  package { 'python-swiftclient':
    ensure => $ensure,
  }

}
