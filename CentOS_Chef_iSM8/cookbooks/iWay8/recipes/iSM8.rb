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
iSM_base_trace_error = node[:ISM8][:BASE][:TRACE][:ERROR]
iSM_base_trace_info = node[:ISM8][:BASE][:TRACE][:INFO]
iSM_base_trace_warn = node[:ISM8][:BASE][:TRACE][:WARN]
iSM_base_trace_debug = node[:ISM8][:BASE][:TRACE][:DEBUG]
iSM_base_trace_deepdebug = node[:ISM8][:BASE][:TRACE][:DEEPDEBUG]
iSM_base_trace_treedebug = node[:ISM8][:BASE][:TRACE][:TREEDEBUG]
iSM_base_trace_datadebug = node[:ISM8][:BASE][:TRACE][:DATADEBUG]
iSM_base_trace_ruledebug = node[:ISM8][:BASE][:TRACE][:RULEDEBUG]
iSM_base_trace_externaldebug = node[:ISM8][:BASE][:TRACE][:EXTERNALDEBUG]
iSM_base_trace_tracedefer = node[:ISM8][:BASE][:TRACE][:TRACEDEFER]
iSM_base_jvm_setting = node[:ISM8][:BASE][:JVM_SETTING]
iSM_base_log_enabled = node[:ISM8][:BASE][:LOG][:ENABLED]
iSM_base_log_location = node[:ISM8][:BASE][:LOG][:LOCATION]
iSM_base_log_timezone = node[:ISM8][:BASE][:LOG][:TIMEZONE]
iSM_base_log_maxfilesize = node[:ISM8][:BASE][:LOG][:MAXDILESIZE]
iSM_base_log_maxfilenumber = node[:ISM8][:BASE][:LOG][:MAXFILENUMBER]
iSM_base_log_datadebugsize = node[:ISM8][:BASE][:LOG][:DATADEBUGSIZE]
iSM_extra_jars_lib = node[:ISM8][:EXTRA_JARS][:LIB]
iSM_extra_jars_extensions = node[:ISM8][:EXTRA_JARS][:EXTENSIONS]
iSM_extra_jars_transform = node[:ISM8][:EXTRA_JARS][:TRANSFORM]


# Copy over the iSM installer
cookbook_file "#{iSM_installer_dir}/#{iSM_installer_name}" do
	source iSM_installer_name
	user iSM_service_account
	group iSM_service_account
	mode '0755'
	action :create
end

# Create ISS file from template
template "#{iSM_installer_dir}/iway80.iss" do
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

# Make backup copy of base.xml file
execute 'base_XML_Backup' do
	cwd "#{iSM_home}/config/base"
	user iSM_service_account
	group iSM_service_account
	environment ({'HOME' => "/home/#{iSM_service_account}", 'USER' => "#{iSM_service_account}"}) 
	command 'cp base.xml base_xml.backup'
	action :run
end

# Replace the default base.xml with one customised with existing vars
template "#{iSM_home}/config/base/base.xml" do
	source 'base_xml.erb'
	owner iSM_service_account
	group iSM_service_account
	mode '0755'
	variables(
		:ISM_PORTS_IBSP_SOAP => iSM_ports_ibsp_soap,
		:ISM_BASE_TRACE_ERROR => iSM_base_trace_error,
		:ISM_BASE_TRACE_INFO => iSM_base_trace_info,
		:ISM_BASE_TRACE_WARN => iSM_base_trace_warn,
		:ISM_BASE_TRACE_DEBUG => iSM_base_trace_debug,
		:ISM_BASE_TRACE_DEEPDEBUG => iSM_base_trace_deepdebug,
		:ISM_BASE_TRACE_TREEDEBUG => iSM_base_trace_treedebug,
		:ISM_BASE_TRACE_DATADEBUG => iSM_base_trace_datadebug,
		:ISM_BASE_TRACE_RULEDEBUG => iSM_base_trace_ruledebug,
		:ISM_BASE_TRACE_EXTERNALDEBUG => iSM_base_trace_externaldebug,
		:ISM_BASE_TRACE_TRACEDEFER => iSM_base_trace_tracedefer,
		:ISM_BASE_LOG_ENABLED => iSM_base_log_enabled,
		:ISM_BASE_LOG_LOCATION => iSM_base_log_location,
		:ISM_BASE_LOG_TIMEZONE => iSM_base_log_timezone,
		:ISM_BASE_LOG_MAXFILESIZE => iSM_base_log_maxfilesize,
		:ISM_BASE_LOG_MAXFILENUMBER => iSM_base_log_maxfilenumber,
		:ISM_BASE_LOG_DATADEBUGSIZE => iSM_base_log_datadebugsize
	)
end

# Make backup copy of config.xml file
execute 'config_XML_Backup' do
	cwd "#{iSM_home}/config"
	user iSM_service_account
	group iSM_service_account
	environment ({'HOME' => "/home/#{iSM_service_account}", 'USER' => "#{iSM_service_account}"}) 
	command 'cp config.xml config_xml.backup'
	action :run
end

# Replace the default config.xml with one customised with existing vars
template "#{iSM_home}/config/config.xml" do
	source 'config_xml.erb'
	owner iSM_service_account
	group iSM_service_account
	mode '0755'
	variables(
		:ISM_PORTS_CONSOLE_HTTP => iSM_ports_console_http,
		:ISM_BASE_JVM_SETTING => iSM_base_jvm_setting
	)
end

# Replace the default signtree.sh script with corrected one
template "#{iSM_home}/bin/signtree.sh" do
	source 'signtree_sh.erb'
	owner iSM_service_account
	group iSM_service_account
	mode '0755'
	variables(
		:ISM_HOME => iSM_home
	)
end

# Digitally resign config.xml
execute 'config_XML_Resign' do
	cwd "#{iSM_home}/bin"
	user iSM_service_account
	group iSM_service_account
	environment ({'HOME' => "/home/#{iSM_service_account}", 'USER' => "#{iSM_service_account}"}) 
	command "./signtree.sh -s #{iSM_home}/config/config.xml"
	action :run
end

# Copy in any additional jars for the 'lib' folder
iSM_extra_jars_lib.each do |this_file|
	cookbook_file "#{iSM_home}/lib/" + this_file do
		source this_file
		owner iSM_service_account
		group iSM_service_account
		mode '0644'
	end
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

