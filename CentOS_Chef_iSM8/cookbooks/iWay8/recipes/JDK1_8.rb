#
# Cookbook Name:: iWay8
# Recipe:: JDK1_8
#

# Steps to install and configure JDK 1.8

java_home = '/usr/java/jdk1.8.0_161'
java_rpm_name = 'jdk-8u161-linux-x64.rpm'
java_installer_dir = node[:JDK][:JDK_INSTALLER_PATH]

# Copy over the RPM installer
cookbook_file "#{java_installer_dir}/#{java_rpm_name}" do
	source "#{java_rpm_name}"
	mode '0755'
	action :create
end

# Install the package
package "#{java_rpm_name}" do
  source "#{java_installer_dir}/#{java_rpm_name}"
end

ruby_block 'set-env-java-home' do
  block do
    ENV['JAVA_HOME'] = java_home
  end
  not_if { ENV['JAVA_HOME'] == java_home }
end

directory '/etc/profile.d' do
  mode '0755'
end

file '/etc/profile.d/jdk.sh' do
  content "export JAVA_HOME=#{java_home}"
  mode '0755'
end

