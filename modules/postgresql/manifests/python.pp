# Class: postgresql::python
#
# This class installs the python libs for postgresql.
#
# Parameters:
#   [*ensure*]       - ensure state for package.
#                        can be specified as version.
#   [*package_name*] - name of package
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class postgresql::python(
  $ensure = installed,
  $package_name = 'python-psycopg2'
) {

  package { 'python-psycopg2':
    name => $package_name,
    ensure => $ensure,
  }

}
