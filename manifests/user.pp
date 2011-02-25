define create_resources::user(
 $ensure,
 $user_name=$operatingsystem
){
  user{$name: ensure => $ensure}
  notify{$user_name:}
}
