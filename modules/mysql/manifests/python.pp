# Class: mysql::python
#
# This class installs the python libs for mysql.
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
class mysql::python(
  $ensure = 'present',
  $package_name = $mysql::params::python_package_name
) inherits mysql::params {

  ensure_resource( 'package', $package_name, {'ensure' => $ensure})

}
