define ss_php::package(
  $ensure = 'present',
  $php_version = $::ss_php::globals_php_version
) {
  $php_version_float = Numeric($php_version)
  if $php_version_float >= 7.2 and $name == 'mcrypt' {
    notice('mcrypt is deprecated and unavailable for PHP >= 7.2. Skipping install')
  } elsif $php_version_float >= 8.0 and ($name == 'json' or $name == 'xmlrpc' or $name == 'apcu-bc') {
    notice("${name} is not available as a standard package for PHP >= 8. Skipping install")
  } elsif $php_version_float <= 5.6 and $name == 'apcu-bc' {
    notice("${name} is not available as a standard package for PHP <= 5.6. Skipping install")
  } elsif $php_version_float >= 8.5 and $name == 'opcache' {
    notice("${name} is not available as a standard package for PHP >= 8.5 Skipping install")
  } else {
    package { "php${php_version}-${name}":
      ensure => $ensure,
      # We know exactly what we want, we don't need recommended packages because they tend to be
      # metapackages such as "php-apcu", which then install versions we don't want.
      # Sury repo currently seems to point these metapackages to random specific php module versions,
      # e.g. php-mysql points to php8.0-mysql, but php-apcu-bc points to php7.4-apcu-bc.
      install_options => ['--no-install-recommends'],
    }
  }
}
