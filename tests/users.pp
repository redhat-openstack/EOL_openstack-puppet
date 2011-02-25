$users3 = {
 'dannyboy454' => {
   'user_name'=>'dlfjdslkf',
   'ensure'=>present,
   'require' => 'User[foobar]',
   'before' => 'User[sally-mae]'
  },
 'bobby-joe' => {'ensure'=>present}
}
create_resources('create_resources::user', $users3)

# TODO - types are not applied in main stage
$users = {
  'sally-mae' => 
  {'ensure' => 'present',
   'require' => 'User[bobby-joe]'
  }
} 
create_resources('user', $users)

user { 'foobar':
  ensure => present,
  require => User['bobby-joe']
}

$classes = {
  'create_resources' => {
    'ensure' => 'present'
  } 
}

create_resources('class', $classes)
