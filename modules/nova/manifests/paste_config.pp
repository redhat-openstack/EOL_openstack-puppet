define nova::paste_config(
  $context = '',
  $value = '',
  $basecontext = '/files/etc/nova/'
) {

  include 'common::config'

  augeas { $name:
    context   => "$basecontext",
    changes   => [
        "set $name $value",
      ],
    require => [Class["nova"], File["/usr/share/augeas/lenses/pythonpaste.aug"]],
    onlyif  => "get $basecontext/$name != $value",
  }

}
