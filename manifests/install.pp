# == Class ipsec_tunnel::install
#
# This class is called from ipsec_tunnel for install.
#
class ipsec_tunnel::install {
  assert_private()

  package { $::ipsec_tunnel::package_name:
    ensure => present,
  }
}
