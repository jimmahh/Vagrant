#
# Cookbook Name:: iWay8
# Recipe:: iSM8
#

# Steps to install and configure iSM 8

iSM_home = '/iway/iway8'
iSM_installer_name = 'iway80.jar'
iSM_installer_dir = '/home/vagrant'
iSM_user = 'vagrant'

# Copy over the iSM installer
cookbook_file "#{iSM_installer_dir}/#{iSM_installer_name}" do
	source iSM_installer_name
	mode '0755'
	action :create
end

# Copy over the iSM installer baseline ISS file (replace this with templating later)
cookbook_file "#{iSM_installer_dir}/iway80_baseline.iss" do
	source 'iway80_baseline.iss'
	mode '0755'
	action :create
end

# Create folder to install to and set ownership/permissions
directory "#{iSM_home}" do
	owner iSM_user
	group iSM_user
	mode '0755'
	recursive true
end

# Run the JAR install as the vagrant user

execute 'iSM_Install' do
	cwd iSM_installer_dir
	user iSM_user
	group iSM_user
	environment ({'HOME' => "/home/#{iSM_user}", 'USER' => "#{iSM_user}"}) 
	command 'java -jar iway80.jar -r iway80_baseline.iss'
	action :run
end

# Set up environment variables 

directory '/etc/profile.d' do
  mode '0755'
end

template "/etc/profile.d/iSM8_EnvVars.sh" do
	source 'iSM8_EnvVars.erb'
	mode '0755'
	variables(
		:ISM_HOME => iSM_home
	)
end

execute 'Init_EnvVars' do
	cwd '/etc/profile.d'
	command './iSM8_EnvVars.sh'
	action :run
end

# Create stop/start scripts for iSM

template "#{iSM_home}/bin/iSM_startService_sudo.sh" do
	source 'iSM_startService_sudo.erb'
	owner iSM_user
	group iSM_user
	mode '0755'
	variables(
		:ISM_HOME => iSM_home,
		:ISM_USER => iSM_user
	)
end

template "#{iSM_home}/bin/iSM_stopService_sudo.sh" do
	source 'iSM_stopService_sudo.erb'
	owner iSM_user
	group iSM_user
	mode '0755'
	variables(
		:ISM_HOME => iSM_home,
		:ISM_USER => iSM_user
	)
end

# Create empty service.log in bin folder
file "#{iSM_home}/bin/service.log" do
	owner iSM_user
	group iSM_user
  	mode '0755'
end

# Register iSM base as service and autostart

systemd_unit 'iSM_base.service' do
  content(Unit: {
            Description: 'iSM8 base',
          },
          Service: {
            ExecStart: "#{iSM_home}/bin/iSM_startService_sudo.sh base",
            ExecStop: "#{iSM_home}/bin/iSM_stopService_sudo.sh base",
          },
          Install: {
            WantedBy: 'multi-user.target',
          })
  action [:create, :enable, :start]
end


#service "iSM_base" do
#	supports :start => true, :stop => true, :restart => false, :reload => false, :status => false
#	start_command "#{iSM_home}/bin/iSM_startService_sudo.sh base -l java"
#	stop_command "#{iSM_home}/bin/iSM_stopService_sudo.sh base"
#	action [:enable, :start]
#end

