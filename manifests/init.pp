class create_resources(
 $ensure,
 $user_name=$name
){
 user{$name: ensure => $ensure}
 notify{$user_name:}
}
