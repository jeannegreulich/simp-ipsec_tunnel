require 'spec_helper'

describe 'ipsec_tunnel' do
  shared_examples_for "a structured module" do
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to create_class('ipsec_tunnel') }
    it { is_expected.to contain_class('ipsec_tunnel') }
    it { is_expected.to contain_class('ipsec_tunnel::params') }
    it { is_expected.to contain_class('ipsec_tunnel::install').that_comes_before('ipsec_tunnel::config') }
    it { is_expected.to contain_class('ipsec_tunnel::config') }
    it { is_expected.to contain_class('ipsec_tunnel::service').that_subscribes_to('ipsec_tunnel::config') }

    it { is_expected.to contain_service('ipsec_tunnel') }
    it { is_expected.to contain_package('ipsec_tunnel').with_ensure('present') }
  end


  context 'supported operating systems' do
    on_supported_os.each do |os, facts|
      context "on #{os}" do
        let(:facts) do
          facts
        end

        context "ipsec_tunnel class without any parameters" do
          let(:params) {{ }}
          it_behaves_like "a structured module"
          it { is_expected.to contain_class('ipsec_tunnel').with_client_nets( ['127.0.0.1/32']) }
        end

        context "ipsec_tunnel class with firewall enabled" do
          let(:params) {{
            :client_nets     => ['10.0.2.0/24'],
            :tcp_listen_port => '1234',
            :enable_firewall => true,
          }}
          ###it_behaves_like "a structured module"
          it { is_expected.to contain_class('ipsec_tunnel::config::firewall') }

          it { is_expected.to contain_class('ipsec_tunnel::config::firewall').that_comes_before('ipsec_tunnel::service') }
          it { is_expected.to create_iptables__add_tcp_stateful_listen('allow_ipsec_tunnel_tcp_connections').with_dports('1234') }
        end

        context "ipsec_tunnel class with selinux enabled" do
          let(:params) {{
            :enable_selinux => true,
          }}
          ###it_behaves_like "a structured module"
          it { is_expected.to contain_class('ipsec_tunnel::config::selinux') }
          it { is_expected.to contain_class('ipsec_tunnel::config::selinux').that_comes_before('ipsec_tunnel::service') }
          it { is_expected.to create_notify('FIXME: selinux') }
        end

        context "ipsec_tunnel class with auditing enabled" do
          let(:params) {{
            :enable_auditing => true,
          }}
          ###it_behaves_like "a structured module"
          it { is_expected.to contain_class('ipsec_tunnel::config::auditing') }
          it { is_expected.to contain_class('ipsec_tunnel::config::auditing').that_comes_before('ipsec_tunnel::service') }
          it { is_expected.to create_notify('FIXME: auditing') }
        end

        context "ipsec_tunnel class with logging enabled" do
          let(:params) {{
            :enable_logging => true,
          }}
          ###it_behaves_like "a structured module"
          it { is_expected.to contain_class('ipsec_tunnel::config::logging') }
          it { is_expected.to contain_class('ipsec_tunnel::config::logging').that_comes_before('ipsec_tunnel::service') }
          it { is_expected.to create_notify('FIXME: logging') }
        end
      end
    end
  end

  context 'unsupported operating system' do
    describe 'ipsec_tunnel class without any parameters on Solaris/Nexenta' do
      let(:facts) {{
        :osfamily        => 'Solaris',
        :operatingsystem => 'Nexenta',
      }}

      it { expect { is_expected.to contain_package('ipsec_tunnel') }.to raise_error(Puppet::Error, /Nexenta not supported/) }
    end
  end
end
