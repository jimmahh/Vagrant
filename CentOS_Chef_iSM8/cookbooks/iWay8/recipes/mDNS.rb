#
# Cookbook Name:: iWay8
# Recipe:: mDNS
#

# Steps to configure mDNS
# ----------------------------------------------------------

# A zero-congig mDNS package
package "avahi" do
  action :install
end

# A package for command-line tools for mDNS browsing and publishing
package "avahi-tools" do
  action :install
end

# Registers avahi as an auto-start background service
service "avahi-daemon" do
  action [:enable, :start]
end
