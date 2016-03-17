# == Class ipsec_tunnel::config::config::pki
#
# This class is meant to be called from ipsec_tunnel.
# It creates the NSS database and loads the PKI cert
# for the machine and Certificate Authorities into 
# the NSS database.  
#
class ipsec_tunnel::config::nss {
  assert_private()

  # Verify that PKI is enabled and if so create the NSS database.
  if $::ipsec_tunnel::pki_defined {
  
  $ipsecdir=$::ipsec_tunnel::ipsecdir
  $db_file =${::ipsec_tunnel::ipsecdir}/cert9.db
  $nsspwd_file="$ipsecdir/nsspassword"
  $dotnsspwd_file="$ipsecdir/.nsspassword"
  $cacerts=$::ipsec_tunnel::cacerts
  $cert=$::ipsec_tunnel::local_cert
  $key=$::ipsec_tunnel::local_key
  if $::ipsec_tunnel::nss_fips {
    $soft_token = "NSS FIPS 140-2 Certificate DB"
  } else {
    $soft_token = "NSS Certificate DB" 
  }
  
  exec { "init_nssdb":
    unless   File.exists[$db_file],
    cmd => "ipsec initnss", 
  }
  
  file { $nsspwd_file:
     ensure => file,
     content => "${soft_token}:${::ipsec_tunnel::nssdb_password}",
     owner => "root",
     group => "root",
     mode => "0600",
     notify => Service["$::ipsec_tunnel::service_name"]
   }
   file { $dotnsspwd_file:
     ensure => file,
     content => "${::ipsec_tunnel::nssdb_password}",
     owner => "root",
     group => "root",
     mode => "0600",
   }
  $cacert_enter="certutil -A -i ${cacerts} -d sql:${ipsecdir} -f ${dotnsspwd_file} -n ${ca_cert_name} -t \'C,,\'"

}

