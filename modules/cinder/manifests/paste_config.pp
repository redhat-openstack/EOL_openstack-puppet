define cinder::paste_config(
  $context = '',
  $key = '',
  $value = '',
  $basecontext = '/files/etc/cinder/'
) {

  include 'common::config'

  augeas { $name:
    context   => "$basecontext",
    changes   => [
        "set $key $value"
      ],
    require => [Class["cinder"], File["/usr/share/augeas/lenses/pythonpaste.aug"]],
    onlyif  => "get $basecontext/$key != $value"
  }

}
