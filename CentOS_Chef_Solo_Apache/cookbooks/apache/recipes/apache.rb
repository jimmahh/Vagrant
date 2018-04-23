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