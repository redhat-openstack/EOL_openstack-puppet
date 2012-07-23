class nova::compute::xenserver {

  package { 'python-pip':
    ensure   => installed
  }
 
  exec { '/usr/bin/pip-python install xenapi':
    onlyif => '/bin/python -c "import XenAPI" || exit 0',
    require => Package['python-pip']
  }

}
