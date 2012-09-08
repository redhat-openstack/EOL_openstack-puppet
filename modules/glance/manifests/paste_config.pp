define glance::paste_config(
  $context = '',
  $key = '',
  $value = '',
  $basecontext = '/files/etc/glance/',
) {

  include 'common::config'

  augeas { $name:
    context   => "$basecontext",
    changes   => [
        "set $key $value",
      ],
    require => [Class["glance"], File["/usr/share/augeas/lenses/pythonpaste.aug"]],
    onlyif  => "get $basecontext/$key != $value",
  }

}
