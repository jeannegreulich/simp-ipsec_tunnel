# == Class ipsec_tunnel::config::firewall
#
# This class is meant to be called from ipsec_tunnel.
# It ensures that firewall rules are defined.
#
class ipsec_tunnel::config::firewall {
  assert_private()

  # FIXME: ensure yoour module's firewall settings are defined here.
  iptables::add_tcp_stateful_listen { 'allow_ipsec_tunnel_tcp_connections':
    client_nets => $::ipsec_tunnel::client_nets,
    dports      => $::ipsec_tunnel::tcp_listen_port,
  }

}
