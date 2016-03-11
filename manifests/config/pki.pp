# == Class ipsec_tunnel::config::config::pki
#
# This class is meant to be called from ipsec_tunnel.
# It ensures that pki rules are defined.
#
class ipsec_tunnel::config::pki {
  assert_private()

  # FIXME: ensure your module's pki settings are defined here.
  $msg = "FIXME: define the ${module_name} module's pki settings."

  notify{ 'FIXME: pki': message => $msg } # FIXME: remove this and add logic
  err( $msg )                             # FIXME: remove this and add logic

}

