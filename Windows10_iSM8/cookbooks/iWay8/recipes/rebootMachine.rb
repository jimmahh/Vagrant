#
# Cookbook Name:: iWay8	
# Recipe:: rebootMachine
#

# Restart the box (yay for Windows =)


reboot 'reboot' do
  reason          "Reboot by Chef as part of provisioning"
  action          :reboot_now
end