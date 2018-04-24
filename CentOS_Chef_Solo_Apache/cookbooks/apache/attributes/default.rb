#
# Cookbook Name:: apache
#
#

default["apache"]["sites"]["example.com"] = { "port" => 80, "servername" => "example.com", "serveradmin" => "webmaster@example.com" }
default["apache"]["sites"]["example.org"] = { "port" => 80, "servername" => "example.org", "serveradmin" => "webmaster@example.org" }
