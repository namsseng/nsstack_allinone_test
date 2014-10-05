#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root' dude." 1>&2
   exit 1
fi
. ./nsstack_setuprc
managementip=$OS_SERVICE_IP
rignic=$OS_SERVICE_NIC


source ./admin_openrc.sh


ovs-vsctl add-br br-ex
ovs-vsctl add-port br-ex $rignic

echo "
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

# The loopback network interface
auto lo
iface lo inet loopback

auto br-ex
iface br-ex inet static
        address         $managementip
        netmask         255.255.255.0
        gateway         $ext_gateway
        up ifconfig \$IFACE promisc
        dns-nameservers $ext_dns

auto $rignic
iface $rignic inet manual
        up ip address add 0/0 dev \$IFACE
        up ip link set \$IFACE up
        up ifconfig \$IFACE multicast
        down ip link set \$IFACE down

" > /etc/network/interfaces

sudo /etc/init.d/networking restart