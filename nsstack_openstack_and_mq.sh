#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root' dude." 1>&2
   exit 1
fi
. ./nsstack_setuprc
service_pass=$OS_PASSWORD
# Install the Ubuntu Cloud Archive for Icehouse: 
apt-get install -y python-software-properties
apt-get install - y software-properties-common
add-apt-repository cloud-archive:icehouse

# Update the package database and upgrade your system:
apt-get -y update
apt-get -y dist-upgrade

# Ubuntu and Debian use RabbitMQ.
apt-get install -y rabbitmq-server
sleep 4

rabbitmqctl change_password guest $service_pass