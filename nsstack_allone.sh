#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root' dude." 1>&2
   exit 1
fi

. ./nsstack_setuprc

password=$OS_PASSWORD    
managementip=$OS_SERVICE_IP
hostname=$OS_HOST_NAME


ed -e "
/^127.0.1.1 .*$/s/^.*$//
" -i /etc/hosts
echo "
$managementip		$hostname
" >> /etc/hosts
./nsstack_ntp.sh

sleep 2

./nsstack_mysql.sh

sleep 2

./nsstack_openstack_and_mq.sh

sleep 2

./nsstack_keystone.sh

sleep 2

./nsstack_glance.sh

sleep 2

./nsstack_nova.sh

sleep 2

./nsstack_cinder.sh

sleep 2

./nsstack_neutron.sh

sleep 2

./nsstack_horizon.sh

sleep 2

./nsstack_ceilometer.sh


reboot
