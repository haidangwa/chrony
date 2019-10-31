# # encoding: utf-8

# Inspec test for recipe chrony::default
def systemd?
  pid_1_file = file('/proc/1/comm')
  pid_1_file.content.strip == 'systemd'
end

chrony_service = systemd? ? systemd_service('chronyd') : upstart_service('chrony')
chrony_conf_file = os.redhat? ? '/etc/chrony.conf' : '/etc/chrony/chrony.conf'

control 'chrony master' do
  title 'chrony master server'
  desc 'verify chrony daemon is installed and running'
  only_if { os.redhat? || os.debian? }

  describe chrony_service do
    it { should be_installed }
    it { should be_enabled }
  end

  describe file(chrony_conf_file) do
    it { should be_file }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('mode') { should cmp '0644' }
    its('content') { should match(/^allow.*/) }
  end
end
