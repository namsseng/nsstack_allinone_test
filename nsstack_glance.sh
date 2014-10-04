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

apt-get install -y glance python-glanceclient

rm /var/lib/glance/glance.sqlite

sed -e "
/^sqlite_db =.*$/s/^.*$/connection = mysql:\/\/glance:$password@$hostname\/glance/
/^backend = sqlalchemy/d
/\[paste_deploy\]/a flavor = keystone
/\[keystone_authtoken\]/a auth_uri = http://$hostname:5000
/^auth_host =.*$/s/^.*$/auth_host = $hostname/
s,%SERVICE_TENANT_NAME%,service,g;
s,%SERVICE_USER%,glance,g;
s,%SERVICE_PASSWORD%,$password,g;
" -i /etc/glance/glance-registry.conf


sed -e "
/^sqlite_db =.*$/s/^.*$/connection = mysql:\/\/glance:$password@$hostname\/glance/
/^# notifier_strategy =.*$/s/^.*$/notifier_strategy = messaging/
/^rabbit_host =.*$/s/^.*$/rabbit_host = $hostname/
/^rabbit_password =.*$/s/^.*$/rabbit_host = $password/
/rabbit_use_ssl = false/a rpc_backend = rabbit
/\[paste_deploy\]/a flavor = keystone
/\[keystone_authtoken\]/a auth_uri = http://$hostname:5000
/^auth_host =.*$/s/^.*$/auth_host = $hostname/
s,%SERVICE_TENANT_NAME%,service,g;
s,%SERVICE_USER%,glance,g;
s,%SERVICE_PASSWORD%,$password,g;
" -i /etc/glance/glance-api.conf
sed -e "/^backend = sqlalchemy/d" -i /etc/glance/glance-api.conf


service glance-api restart; service glance-registry restart
sleep 3
glance-manage db_sync
sleep 3
service glance-api restart; service glance-registry restart
sleep 3

source admin_openrc.sh
# add cirros image
glance image-create --name="Cirros 0.3.0"  --is-public=true --container-format=bare --disk-format=qcow2 --copy-from http://download.cirros-cloud.net/0.3.2/cirros-0.3.2-x86_64-disk.img

# add ubuntu image
glance image-create --name="Ubuntu Precise 12.04 LTS" --is-public=true --container-format=ovf --disk-format=qcow2 --copy-from http://cloud-images.ubuntu.com/precise/current/precise-server-cloudimg-amd64-disk1.img

# add ubuntu image
glance image-create --name="Ubuntu Server 14.10 LTS " --is-public=true --container-format=ovf --disk-format=qcow2 --copy-from http://cloud-images.ubuntu.com/utopic/current/utopic-server-cloudimg-amd64-disk1.img