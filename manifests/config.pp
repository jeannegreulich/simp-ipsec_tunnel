# == Class ipsec_tunnel::config
#
# This class is called from ipsec_tunnel for service config.
#
class ipsec_tunnel::config {
 assert_private()
  file { '/etc/ipsec.conf':
    ensure => file,
    owner  => root,
    mode  => '0400',
    notify =>  Service['ipsec'],
    content => template('etc/ipsec.conf.erb')
  }
  file { $::ipsec_tunnel::secretsfile:
    ensure => file,
    owner  => root,
    mode   => '0400',
    require => Package['$::ipsec_tunnel::params::package'],
  }
  file { $::ipsec_tunnel::ipsecdir:
    ensure => directory,
    owner  => root,
    mode   => '0700',
    require => Package['$::ipsec_tunnel::params::package'],
  }
  file { $::ipsec_tunnel::dumpdir:
    ensure => directory,
    owner  => root,
    mode   => '0700',
    require => Package['$::ipsec_tunnel::params::package'],
  }
  if $::ipsec_tunnel::plutostderrlog {
    file {$::ipsec_tunnel::plutostderrlog:
      ensure => file,
      owner  => root,
      mode   => '0600',
      require => Package['$::ipsec_tunnel::params::package'],
    }
 }
}
