#!/usr/bin/env bash

yum update
yum install -y httpd avahi avahi-tools nss-mdns
if ! [ -L /var/www/html ]; then
  rm -rf /var/www/html
  ln -fs /vagrant /var/www/html
fi
systemctl enable httpd.service
systemctl start httpd.service
systemctl enable avahi-daemon.service
systemctl start avahi-daemon.service
touch ran_provision_step.txt