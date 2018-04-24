#
# Cookbook Name:: apache
# Recipe:: apache
#
#



package "httpd" do
  action :install
end

service "httpd" do
  action [:enable, :start]
end


# Add line to httd.conf if missing
ruby_block "httpd_conf-update" do
  block do
    line = 'IncludeOptional sites-enabled/*.conf'
    file = Chef::Util::FileEdit.new('/etc/httpd/conf/httpd.conf')
    file.insert_line_if_no_match(/#{line}/, line)
    file.write_file
  end
end

# Virtual Hosts Files

node["apache"]["sites"].each do |sitename, data|
  document_root = "/var/www/#{sitename}"

  directory document_root do
    mode "0755"
    recursive true
  end

  directory "/etc/httpd/sites-available" do
    mode "0755"
    recursive true
  end

  directory "/etc/httpd/sites-enabled" do
    mode "0755"
    recursive true
  end

  template "/etc/httpd/sites-available/#{sitename}.conf" do
    source "virtualhosts.erb"
    mode "0644"
    variables(
      :document_root => document_root,
      :port => data["port"],
      :serveradmin => data["serveradmin"],
      :servername => data["servername"]
    )
    notifies :restart, "service[httpd]"
  end

  link "/etc/httpd/sites-enabled/#{sitename}.conf" do
    to "/etc/httpd/sites-available/#{sitename}.conf"
  end

  directory "/var/www/#{sitename}/public_html" do
    mode "0755"
    action :create
  end

  directory "/var/www/#{sitename}/logs" do
    mode "0755"
    action :create
  end
end

