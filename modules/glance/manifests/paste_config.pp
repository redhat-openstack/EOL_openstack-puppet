define glance::paste_config(
  $context = '',
  $value = '',
  $basecontext = '/files/etc/glance/',
) {

  include 'common::config'

  augeas { $name:
    context   => "$basecontext",
    changes   => [
        "set $name $value",
      ],
    require => [Class["glance"], File["/usr/share/augeas/lenses/pythonpaste.aug"]],
    onlyif  => "get $basecontext/$name != $value",
  }

}
