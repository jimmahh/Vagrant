#
# Cookbook Name:: apache
# Recipe:: default
#
#


# Update yum ahead of next steps
execute "yum update" do
  command "yum update"
  action :run
end