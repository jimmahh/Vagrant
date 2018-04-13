#!/usr/bin/env bash

yum update
yum install -y avahi avahi-tools
systemctl enable avahi-daemon.service
systemctl start avahi-daemon.service
