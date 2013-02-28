define nova::paste_config(
  $context = '',
  $key = '',
  $value = '',
  $basecontext = '/files/etc/nova/'
) {

  include 'common::config'

  augeas { $name:
    context   => "$basecontext",
    changes   => [
        "set $key $value"
      ],
    require => [Class["nova"], File["/usr/share/augeas/lenses/pythonpaste.aug"]],
    onlyif  => "get $basecontext/$key != $value"
  }

}
