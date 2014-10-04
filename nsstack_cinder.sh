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

# install packages
apt-get install -y lvm2
apt-get install -y python-cinderclient
apt-get install -y cinder-api cinder-scheduler cinder-volume 




su -s /bin/sh -c "cinder-manage db sync" cinder

echo "
[DEFAULT]
rootwrap_config = /etc/cinder/rootwrap.conf
api_paste_confg = /etc/cinder/api-paste.ini
iscsi_helper = tgtadm
volume_name_template = volume-%s
volume_group = cinder-volumes
verbose = True
auth_strategy = keystone
state_path = /var/lib/cinder
lock_path = /var/lock/cinder
volumes_dir = /var/lib/cinder/volumes
connection = mysql://cinder:$password@$hohostname/cinder
rpc_backend = rabbit
rabbit_host = $hostname
rabbit_port = 5672
rabbit_userid = guest
rabbit_password = 1
glace_host = $hostname
control_exchange = cinder
notification_driver = cinder.openstack.common.notifier.rpc_notifier

[database]
connection = mysql://cinder:$password@$hostname/cinder

[keystone_authtoken]
auth_uri = http://$hostname:5000
auth_host = $hostname
auth_port = 35357
auth_protocol = http
admin_tenant_name = service
admin_user = cinder
admin_password = $password
" >> /etc/cinder/cinder.conf

service cinder-scheduler restart
service cinder-api restart
service cinder-volume restart
service tgt restart


# ask how big and create loopback file
read -p "Enter the integer amount in gigabytes (min 1G) to use as a loopback file for Cinder: " gigabytes
echo;
echo "Creating loopback file of size $gigabytes GB at /cinder-volumes..."
gigabytesly=$gigabytes"G"
dd if=/dev/zero of=/cinder-volumes bs=1 count=0 seek=$gigabytesly
echo;

# loop the file up
losetup /dev/loop2 /cinder-volumes

# create a rebootable remount of the file
echo "losetup /dev/loop2 /cinder-volumes; exit 0;" > /etc/init.d/cinder-setup-backing-file
chmod 755 /etc/init.d/cinder-setup-backing-file
ln -s /etc/init.d/cinder-setup-backing-file /etc/rc2.d/S10cinder-setup-backing-file

# create the physical volume and volume group
sudo pvcreate /dev/loop2
sudo vgcreate cinder-volumes /dev/loop2

# create storage type
sleep 2
cinder type-create Storage

# restart cinder services
service cinder-scheduler restart
service cinder-api restart
service cinder-volume restart
service tgt restart