class ss_php(
  Optional[Pattern[/^[578].[0-9]/]] $php_version = $ss_php::params::php_version,
  $cli = $ss_php::params::cli,
  $dev = $ss_php::params::dev,
  $apt_domain = $ss_php::params::apt_domain,
  $apt_login = $ss_php::params::apt_login,
  $apt_password = $ss_php::params::apt_password,
) inherits ss_php::params {
  $globals_php_version = pick($php_version, $ss_php::params::php_version)
  $globals_cli_inifile = "/etc/php/${globals_php_version}/cli/php.ini"

  class { 'ss_php::repo':
    domain    => $apt_domain,
    login     => $apt_login,
    password  => $apt_password,
  }
  -> class { 'ss_php::install':
  }
}
