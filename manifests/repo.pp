class ss_php::repo(
  $debian_repo_location,
) {
  include apt

  ensure_packages(['apt-transport-https', 'lsb-release', 'ca-certificates'], {'ensure' => 'present'})

  apt::source { 'php':
    location => $debian_repo_location,
    release  => $facts['os']['distro']['codename'],
    repos    => 'main',
    notify   => Exec['ss_php_repo_force_update'],
    key      => {
      name   => 'debsuryorg-php.gpg',
      source => 'https://packages.sury.org/php/apt.gpg',
    },
    include  => {
      src => false,
    }
  }

  exec { 'ss_php_repo_force_update':
    command     => "/bin/echo 'Apt update after adding sury repo'",
    refreshonly => true,
    logoutput   => true,
    subscribe   => Exec['apt_update'],
  }
}
