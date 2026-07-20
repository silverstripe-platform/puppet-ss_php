class ss_php::repo(
  String                  $domain = "apt.silverstripe.cloud",
  Variant[String, Undef]  $login = undef,
  String                  $password = "",
  String                  $gpg_key_id = "DD9E8E9D0E7125F71CFA8BED66E8175101A28EDE"
) {
  include apt

  if $login {
    file { '/etc/apt/auth.conf.d/apt-mirror.conf':
      ensure  => file,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => "machine ${domain}\nlogin ${login}\npassword ${password}\n",
    }
  }

  ensure_packages(['apt-transport-https', 'lsb-release', 'ca-certificates'], {'ensure' => 'present'})

  $_mirror_deps = $login ? {
    undef => [
      Package['apt-transport-https', 'lsb-release', 'ca-certificates'],
    ],
    default => [
      Package['apt-transport-https', 'lsb-release', 'ca-certificates'],
      File['/etc/apt/auth.conf.d/apt-mirror.conf'],
    ]
  }

  apt::source { 'sury-php-mirror':
    location => "https://${domain}/php/",
    release  => 'jammy',
    repos    => 'main',
    key      => {
      'id'     => $gpg_key_id,
      'source' => "https://${domain}/gpg/repo-signing.gpg",
    },
    include  => {
      'src' => false,
      'deb' => true,
    },
    require  => $_mirror_deps,
    notify   => Exec['ss_php_repo_force_update'],
  }

  exec { 'ss_php_repo_force_update':
    command     => "/bin/echo 'Apt update after adding sury repo'",
    refreshonly => true,
    logoutput   => true,
    subscribe   => Exec['apt_update'],
  }
}
