#
# Cookbook Name:: iWay8
# Recipe:: default
#

# Bootstrapping bits (update yum repository in the main =)

# Update yum ahead of next steps
execute "yum update" do
  command "yum update"
  action :run
end