class quantum::client (
  $ensure = present
) {
  package { "python-quantumclient":
    name   => $::quantum::params::client_package_name,
    ensure => $ensure
  }
}
