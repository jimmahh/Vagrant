#
# Cookbook Name:: iWay8
# Recipe:: iIT8
#

# Steps to install and configure iIT 8

iIT_zip_name = node['iIT']['iIT_zip_name']
iIT_zip_path = node['iIT']['iIT_zip_path']
iIT_user_account = node['iIT']['iIT_user_account']
iIT_install_path = node['iIT']['iIT_install_path']


# Create folder to unpack to and set ownership/permissions
directory "#{iIT_install_path}" do
	owner iIT_user_account
	mode '0755'
	recursive true
end

# unzip IIT install into the target folder
windows_zipfile "#{iIT_install_path}" do
  source "#{iIT_zip_path}/#{iIT_zip_name}"
  action :unzip
  not_if {::File.exists?("#{iIT_install_path}/iit.exe")}
end
