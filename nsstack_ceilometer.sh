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
token=$OS_SERVICE_TOKEN

apt-get install -y ceilometer-api ceilometer-collector ceilometer-agent-central ceilometer-agent-notification ceilometer-alarm-evaluator ceilometer-alarm-notifier ceilometer-agent-compute python-ceilometerclient
apt-get install -y mongodb-server

# patch mongo config
sed -e "
/^bind_ip =.*$/s/^.*$/bind_ip = $managementip/
" -i /etc/mongodb.conf

service mongodb restart

mongo --host $hostname --eval '
db = db.getSiblingDB("ceilometer");
db.addUser({user: "ceilometer",
            pwd: "$password",
            roles: [ "readWrite", "dbAdmin" ]})'
            
            
echo "   
[DEFAULT]

auth_strategy=keystone

log_dir= /var/log/ceilometer

rabbit_host= $hostname
rabbit_password = $password

[alarm]


[api]



[collector]

[database]


connection= mongodb://ceilometer:$password@$hostname:27017/ceilometer


[dispatcher_file]


[event]



[keystone_authtoken]
auth_host = $hostname
auth_port = 35357
auth_protocol = http
auth_uri = http://$hostname:5000
admin_tenant_name = service
admin_user = ceilometer
admin_password = $password


[matchmaker_redis]



[matchmaker_ring]


[notification]



[publisher]

metering_secret=$token


[publisher_rpc]



[rpc_notifier2]


[service_credentials]
os_auth_url = http://$hostname:5000/v2.0
os_username = ceilometer
os_tenant_name = service
os_password = $password



[ssl]


[vmware]

" > /etc/ceilometer/ceilometer.conf


service ceilometer-agent-central restart
service ceilometer-agent-notification restart
service ceilometer-api restart
service ceilometer-collector restart
service ceilometer-alarm-evaluator restart
service ceilometer-alarm-notifier restart
service ceilometer-agent-compute restart
service glance-registry restart
service glance-api restart
service cinder-api restart
service cinder-scheduler restart
service cinder-volume restart