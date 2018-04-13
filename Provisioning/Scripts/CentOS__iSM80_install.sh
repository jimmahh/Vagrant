#!/usr/bin/env bash

sudo mkdir /iway
sudo chown vagrant:vagrant /iway

chmod 755 iway80.jar

java -jar iway80.jar -r iway80_baseline.iss

rm iway80.jar
rm iway80_baseline.iss

# install the bugger as an autostart service 
# Not sure how to do this tbf =)