# # encoding: utf-8

# Inspec test for recipe chrony::default

chrony_service = os.redhat? ? service('chronyd') : service('chrony')

control 'chrony client service' do
  title 'chrony client service'
  desc 'verify chrony daemon is installed and running'
  only_if { os.redhat? || os.debian? }

  describe chrony_service do
    it { should be_installed }
    it { should be_running }
  end
end
