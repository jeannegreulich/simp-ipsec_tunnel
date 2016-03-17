# == Class: ipsec_tunnel
#
# Full description of SIMP module 'ipsec_tunnel' here.
#
# === Welcome to SIMP!
# This module is a component of the System Integrity Management Platform, a
# a managed security compliance framework built on Puppet.
#
# ---
# *FIXME:* verify that the following paragraph fits this module's characteristics!
# ---
#
# This module is optimally designed for use within a larger SIMP ecosystem, but
# it can be used independently:
#
# * When included within the SIMP ecosystem,
#   security compliance settings will be managed from the Puppet server.
#
# * If used independently, all SIMP-managed security subsystems are disabled by
#   default, and must be explicitly opted into by administrators.  Please review
#   the +client_nets+ and +$enable_*+ parameters for details.
#
#
# == Parameters
#
# [*service_name*]
#   The name of the ipsec_tunnel service.
#   Type: String
#   Default:  +$::ipsec_tunnel::params::service_name+
#
# [*package_name*]
#   Type: String
#   Default:  +$::ipsec_tunnel::params::package_name+
#   The name of the ipsec_tunnel package.
#
# [*client_nets*]
#   Type: Array of Strings
#   Default: +['127.0.0.1/32']+
#   A whitelist of subnets (in CIDR notation) permitted access.
#
# [*enable_auditing*]
#   Type: Boolean
#   Default: +false+
#   If true, manage auditing for ipsec_tunnel.
#
# [*enable_firewall*]
#   Type: Boolean
#   Default: +false+
#   If true, manage firewall rules to acommodate ipsec_tunnel.
#
# [*enable_logging*]
#   Type: Boolean
#   Default: +false+
#   If true, manage logging configuration for ipsec_tunnel.
#
# [*enable_pki*]
#   Type: Boolean
#   Default: +false+
#   If true, manage PKI/PKE configuration for ipsec_tunnel.
#
# [*enable_selinux*]
#   Type: Boolean
#   Default: +false+
#   If true, manage selinux to permit ipsec_tunnel.
#
# [*enable_tcpwrappers*]
#   Type: Boolean
#   Default: +false+
#   If true, manage TCP wrappers configuration for ipsec_tunnel.
#
# == Authors
#
# * simp
#
class ipsec_tunnel (
  $service_name    = $::ipsec_tunnel::params::service_name,
  $package_name    = $::ipsec_tunnel::params::package_name,
  $client_nets     = defined('$::client_nets') ? { true => $::client_nets, default => hiera('client_nets', ['127.0.0.1/32']) },
  $enable_auditing = defined('$::enable_auditing') ? { true => $::enable_auditing, default => hiera('enable_auditing',false) },
  $enable_firewall = defined('$::enable_firewall') ? { true => $::enable_firewall, default => hiera('enable_firewall',false) },
  $enable_logging  = defined('$::enable_logging')  ? { true => $::enable_logging,  default => hiera('enable_logging',false) },
  $enable_pki  = defined('$::enable_pki')  ? { true => $::enable_pki,  default => hiera('enable_pki',false) },
  $enable_selinux  = defined('$::enable_selinux')  ? { true => $::enable_selinux,  default => hiera('enable_selinux',false) },
  $enable_tcpwrappers  = defined('$::enable_tcpwrappers')  ? { true => $::enable_tcpwrappers,  default => hiera('enable_tcpwrappers',false) },
  $nss_fips= defined('$::use_fips') ? { true => $::use_fips, default => hiera('nss_fips',false) },
  $nssdb_password        = passgen('nssdb_password'),
  $myid = undef,
  $interfaces =  undef,
  $listen =  undef,
  $ikeport = '500',
  $nat_ikeport = '4500',
  $keep_alive = undef,
  $retransmits = "yes",
  $virtual_private = ["10.0.0.0/8","192.168.0.0/16","172.16.0.0/12"],
  $myvendorid = undef,
  $nhelpers =  undef,
  $plutofork =  undef,
  $crlcheckinterval = undef,
  $strictcrlpolicy = undef,
  $syslog = undef,
  $klipsdebug = "none",
  $plutodebug = "none",
  $uniqueids = undef,
  $plutorestartoncrash = undef,
  $plutostderrlog = undef,
  $plutostderrlogtime = undef,
  $force_busy =  undef,
  $dumpdir = "/var/run/pluto",
  $statsbin = undef,
  $ipsecdir = "/etc/ipsec.d",
  $secretsfile = "/etc/ipsec.secrets",
  $perpeerlog = undef,
  $perpeerlogdir = "/var/log/pluto/peer",
  $fragicmp = undef,
  $hidetos = undef,
  $overridemtu = undef
  $cacert = "/etc/pki/cacerts/cacerts.pem",
  $local_cert = "/etc/pki/public/{::fqdn}.pem",
  $local_key  = "/etc/pki/private/{::fqdn}.pem",
) inherits ::ipsec_tunnel::params {

  validate_string( $service_name )
  validate_string( $package_name )
  validate_string( $tcp_listen_port )
  validate_array( $client_nets )
  validate_bool( $enable_auditing )
  validate_bool( $enable_firewall )
  validate_bool( $enable_logging )
  validate_bool( $enable_pki )
  validate_bool( $enable_selinux )
  validate_bool( $enable_tcpwrappers )
  validate_bool( $nss_fips )
  # config setup section of ipsec.conf
  if $strictcrlpolicy { validate_re($strictcrlpolicy,'(yes|no)$',"${strictcrlpolicy} is not supported for hidetos") }
  if $force_busy { validate_re($force_busy,'(yes|no)$',"${force_busy} is not supported for hidetos") }
  if $hidetos { validate_re($hidetos,'(yes|no)$',"${hidetos} is not supported for hidetos") }
  if $plutofork { validate_re($plutofork,'(yes|no)$',"${plutofork} is not supported for plutofork") }
  if $uniqueids { validate_re($uniqueids,'(yes|no)$',"${uniqueids} is not supported for uniqueids") }
  if $retransmits { validate_re($retransmits,'(yes|no)$',"${retransmits} is not supported for retransmits") }
  if $plutorestartoncrash { validate_re($plutorestartoncrash,'(yes|no)$',"${plutorestartoncrash} is not supported for plutorestartoncrash") }
  if $fragicmp { validate_re($fragicmp,'(yes|no)$',"${fragicmp} is not supported for hidetos") }
  if $listen { validate_ipv4_address($listen) }
  if $perpeerlog { validate_re($perpeerlog,'(yes|no)$',"${perpeerlog} is not supported for hidetos") }
  if $nhelpers { validate_integer($nhelpers)}
  if $overridemtu { validate_integer($overridemtu)}
  if $keep_alive { validate_integer($keep_alive)}
  if $crlcheckinterval { validate_integer($crlcheckinterval)}
  if $myvendorid { validate_string($myvendorid)}
  if $statsbin { validate_string($statsbin)}
  if $syslog { validate_string($syslog)}
  if $plutostderrlog { validate_absolute_path ($plutostderrlog) }
  if $plutostderrlog { plutostderrlogtime = yes }
  validate_absolute_path($ipsecdir),
  validate_absolute_path($secretsfile),
  validate_absolute_path($dumpdir),
  validate_absolute_path($cacerts),
  validate_absolute_path($local_cert),
  validate_absolute_path($local_key),
  validate_array_member( $protostack,["netkey","klips","mast"])
  validate_integer($ikeport)
  validate_integer($nat_ikeport)
  validate_re($retransmits,'(yes|no)$',"${retransmits} is not supported for retransmits") 

  include '::ipsec_tunnel::install'
  include '::ipsec_tunnel::config'
  include '::ipsec_tunnel::service'
  Class[ '::ipsec_tunnel::install' ] ->
  Class[ '::ipsec_tunnel::config'  ] ~>
  Class[ '::ipsec_tunnel::service' ] ->
  Class[ '::ipsec_tunnel' ]

  if $enable_auditing {
    include '::ipsec_tunnel::config::auditing'
    Class[ '::ipsec_tunnel::config::auditing' ] ->
    Class[ '::ipsec_tunnel::service' ]
  }

  if $enable_firewall {
    include '::ipsec_tunnel::config::firewall'
    Class[ '::ipsec_tunnel::config::firewall' ] ->
    Class[ '::ipsec_tunnel::service'  ]
  }

  if $enable_logging {
    include '::ipsec_tunnel::config::logging'
    Class[ '::ipsec_tunnel::config::logging' ] ->
    Class[ '::ipsec_tunnel::service' ]
  }

  if $enable_pki {
    include '::ipsec_tunnel::config::pki'
    Class[ '::ipsec_tunnel::config::pki' ] ->
    Class[ '::ipsec_tunnel::service' ]
  }

  if $enable_selinux {
    include '::ipsec_tunnel::config::selinux'
    Class[ '::ipsec_tunnel::config::selinux' ] ->
    Class[ '::ipsec_tunnel::service' ]
  }

  if $enable_tcpwrappers {
    include '::ipsec_tunnel::config::tcpwrappers'
    Class[ '::ipsec_tunnel::config::tcpwrappers' ] ->
    Class[ '::ipsec_tunnel::service' ]
  }

# == Class: ipsec_tunnel
}
