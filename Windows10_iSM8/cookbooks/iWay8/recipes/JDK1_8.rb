#
# Cookbook Name:: iWay8
# Recipe:: JDK1_8
#

# Steps to install and configure JDK 1.8

java_home = 'C:/Program Files/java/jdk1.8.0_211'
java_installer_name = 'jdk-8u211-windows-x64.exe'
java_installer_dir = node[:JDK][:JDK_INSTALLER_PATH]

# Copy over the RPM installer
cookbook_file "#{java_installer_dir}/#{java_installer_name}" do
	source     "#{java_installer_name}"
	mode       '0755'
	action     :create
end

# Install the package
windows_package 'java' do
  source          "#{java_installer_dir}/#{java_installer_name}"
  options         "/s /v\"/qn INSTALLDIR=\\\"C:\\Program Files\\Java\\\"\""
  installer_type  :custom
end

windows_env 'JAVA_HOME' do
  value     java_home
end