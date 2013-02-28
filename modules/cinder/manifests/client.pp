#
# Class for installing cinderclient
#
#
class cinder::client(
  $ensure='present'
) {

  package { 'python-cinderclient':
    ensure => $ensure
  }

}
