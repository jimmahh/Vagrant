#
# Cookbook Name:: iWay8
# Recipe:: mDNS
#

# Steps to configure allow machine to be pinged from MacOS
# ----------------------------------------------------------

# Disable LLMNR via the registry
registry_key "HKEY_LOCAL_MACHINE\\Software\\Policies\\Microsoft\\Windows NT\\DNSClient" do
  values [{
    name: 'EnableMulticast',
    type: :dword,
    data: 0
  }]
  action :create
end

# Install Bonjour
windows_package 'Bonjour64' do
  action :install
  source 'C:/vagrant/cookbooks/iWay8/files/Bonjour64.msi'
end