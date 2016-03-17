# == Define: ipsectunnel::add_connection
#
# Define to set up connection files in the ipsec
# directory.  The name of the connection must be unique.
# This will configure a path to and from the given ip address.
#
#  == Parameters
# See the libreswan documentation for in depth details of values
# for these settings.
#
# [*left*]  The IP Address of the local connection.
# [*type*]  The type of connection:  passthrough, tunnel
# [*comment*]
#   A comment to add to the entry.
#
# [*insecure*]
# [*rw*]
# [*async*]
# [*no_wdelay*]
# [*nohide*]
# [*crossmnt*]
# [*subtree_check*]
# [*insecure_locks*]
# [*no_acl*]
# [*mountpoint*]
# [*fsid*]
# [*refer*]
# [*sec*]
# [*no_root_squash*]
# [*all_squash*]
# [*anonuid*]
# [*anongid*]
# [*custom*]
#   A custom set of options.  If $custom is set, all other options will be
#   ignored. $mountpoint and $client must still be set.  Do not include the
#   parenthesis if you are writing a custom options string.
#
# == Authors
#
#
define ipsectunnel::add_connection (
  $left = undef,
  $right = undef,
  $connaddrfamily = undef,
  $type = undef,
  $leftsubnet = undef,
  $leftsubnets = undef,
  $leftprotoport = undef,
  $leftsourceip = undef,
  $leftupdown = undef,
  $authby = undef,
  $leftcert = undef,
  $leftrsasigkey = undef,
  $rightrsasigkey = undef,
  $leftsendcert = undef,
  $leftid = undef,
  $rightid = undef,
  $rightrsasigkey = undef,
  $auto = undef,

) {
  include 'ipsectunnel'

  case $right {
    undef  :  {}
    /^%*/  :  {validate_array_member($right, ['%any', '%defaultroute'])}
    default:  {validate_ipv4_address($right)}
  }
  case $left {
    undef  :  {}
    /^%*/  :  {validate_array_member($left, ['%any', '%defaultroute'])}
    default:  {validate_ipv4_address($left)}
  }
  if $leftprotoport   { validate_port($leftprotoport)}
  if $rightprotoport  { validate_port($rightprotoport)}
  if $leftsourceip    { validate_ipv4_address($leftsourceip)}
  if $rightsourceip   { validate_ipv4_address($rightsourceip)}
  if $leftupdown      { validate_string($leftupdown)}
  if $rightupdown     { validate_string($rightupdown)}
  if $authby          { validate_array_member($authby, ['rsasig','secrets'])}
  if $auto            { validate_array_member($auto, ['add','start','ondemand','ignore'])}
  if $leftcert        { validate_absoulte_path($leftcert)}
  if $rightcert       { validate_absoulte_path($rightcert)}
  if $leftrsasigkey   { validate_array_member($leftrsasigkey, ['%cert','%none','%dns','%dnsonload','%dnsondemand'])}
  if $rightrsasigkey  { validate_array_member($rightrsasigkey, ['%cert','%none','%dns','%dnsonload','%dnsondemand'])}
  if $leftsendcert    { validate_array_member($leftsendcert, ['yes','no','never','always','ifasked'])}
  if $leftid          { validate_string($leftid)}
  if $rightid         { validate_string($rightid)}
  if $connaddrfamily  { validate_re($connaddrfamily,'^(ipv4|ipv6)$',"${connaddrfamily} is not supported for hidetos") }
  if $type            { validate_array_member($type, ['tunnel','transport','passthough','reject','drop'])}
  if $leftsubnets     { validate_net_list($leftsubnets)}
  if $rightsubnets    { validate_net_list($rightsubnets)}
  if $leftsubnet      { validate_net_list($leftsubnet)}
  if $rightsubnet     { validate_net_list($rightsubnet)}

  if $name == "default" { $conn_name = "%default" }
  else                  { $conn_name = $name }

  $conn_file_name =  $::ipsectunnel::ipsec_dir/$name

  file { $conn_file_name:
    name => $conn_name,
    mode => '644',
    content => template('simplib/etc/ipsec.d/ipsec.conf.erb')
  }
}
