#
# Cookbook Name:: iWay8
# Recipe:: iSM8
#

# Steps to install and configure iSM 8

iSM_installer_name = 'iway80.jar'
iSM_home = node[:ISM8][:ISM_HOME]
iSM_installer_dir = node[:ISM8][:ISM_INSTALLER_PATH]
iSM_service_account = node[:ISM8][:ISM_SERVICE_ACCOUNT]
iSM_license_details_user_name = node[:ISM8][:ISM_LICENSE_DETAILS][:USER_NAME]
iSM_license_details_company_name = node[:ISM8][:ISM_LICENSE_DETAILS][:COMPANY_NAME]
iSM_license_details_site_code = node[:ISM8][:ISM_LICENSE_DETAILS][:SITECODE]
iSM_ports_console_http = node[:ISM8][:ISM_PORTS][:CONSOLE_HTTP]
iSM_ports_ibsp_soap = node[:ISM8][:ISM_PORTS][:IBSP_SOAP]

# Copy over the iSM installer
cookbook_file "#{iSM_installer_dir}/#{iSM_installer_name}" do
	source iSM_installer_name
	user iSM_service_account
	group iSM_service_account
	mode '0755'
	action :create
end

# Copy over the iSM installer baseline ISS file (replace this with templating later)
#cookbook_file "#{iSM_installer_dir}/iway80_baseline.iss" do
#	source 'iway80_baseline.iss'
#	mode '0755'
#	action :create
#end

# Create ISS file from template
template "#{iSM_installer_dir}/bin/iway80.iss" do
	source 'iway80_baseline_iss.erb'
	owner iSM_service_account
	group iSM_service_account
	mode '0755'
	variables(
		:ISM_HOME => iSM_home,
		:ISM_LICENSE_DETAILS_USER_NAME => iSM_license_details_user_name,
		:ISM_LICENSE_DETAILS_COMPANY_NAME => iSM_license_details_company_name,
		:ISM_LICENSE_DETAILS_SITECODE => iSM_license_details_site_code,
		:ISM_PORTS_CONSOLE_HTTP => iSM_ports_console_http,
		:ISM_PORTS_IBSP_SOAP => iSM_ports_ibsp_soap
	)
end

# Create folder to install to and set ownership/permissions
directory "#{iSM_home}" do
	owner iSM_service_account
	group iSM_service_account
	mode '0755'
	recursive true
end

# Run the JAR install as the vagrant user

execute 'iSM_Install' do
	cwd iSM_installer_dir
	user iSM_service_account
	group iSM_service_account
	environment ({'HOME' => "/home/#{iSM_service_account}", 'USER' => "#{iSM_service_account}"}) 
	command 'java -jar iway80.jar -r iway80.iss'
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
	owner iSM_service_account
	group iSM_service_account
	mode '0755'
	variables(
		:ISM_HOME => iSM_home,
		:ISM_USER => iSM_service_account
	)
end

template "#{iSM_home}/bin/iSM_stopService_sudo.sh" do
	source 'iSM_stopService_sudo.erb'
	owner iSM_service_account
	group iSM_service_account
	mode '0755'
	variables(
		:ISM_HOME => iSM_home,
		:ISM_USER => iSM_service_account
	)
end

# Create empty service.log in bin folder
file "#{iSM_home}/bin/service.log" do
	owner iSM_service_account
	group iSM_service_account
  	mode '0755'
end

# Register iSM base as service and autostart

systemd_unit 'iSM_base.service' do
  content(Unit: {
            Description: 'iSM8 base',
          },
          Service: {
          	Type: 'forking',
            ExecStart: "#{iSM_home}/bin/iSM_startService_sudo.sh base",
            ExecStop: "#{iSM_home}/bin/iSM_stopService_sudo.sh base",
            SuccessExitStatus: '143',
          },
          Install: {
            WantedBy: 'multi-user.target',
          })
  action [:create, :enable, :start]
end

