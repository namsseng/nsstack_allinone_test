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



apt-get install heat-api heat-api-cfn heat-engine

su -s /bin/sh -c "heat-manage db_sync" heat

sleep 5

sed -e "
/^connection=sq.*$/s/^.*$/connection = mysql:\/\/heat:$password@$hostname\/heat/
/^#verbose=.*$/s/^.*$/verbose=true/
/^#log_dir=.*$/s/^.*$/log_dir=\/var\/log\/heat/
/^#rabbit_host=.*$/s/^.*$/rabbit_host = $hostname/
/^#rabbit_password=.*$/s/^.*$/rabbit_password = $password/
/\[keystone_authtoken\]/a auth_uri = http:\/\/$hostname:5000\nauth_port = 35357\nauth_protocol = http\nauth_uri = http:\/\/$hostname:5000\/v2.0\nadmin_tenant_name = service\nadmin_user = heat\nadmin_password = $password
/\[ec2authtoken\]/a auth_uri = http:\/\/$hostname:5000
/^#heat_metadata_server_url=.*$/s/^.*$/heat_metadata_server_url=http:\/\/$managementip:8000/
/^#heat_waitcondition_server_url=.*$/s/^.*$/heat_waitcondition_server_url=http:\/\/$managementip:8000\/v1\/waitcondition/
" -i /etc/heat/heat.conf


service heat-api restart
service heat-api-cfn restart
service heat-engine restart

sleep 4


source demo_openrc.sh
cat > ns-stack.yml <<EOF
heat_template_version: 2014-10-06

description: Test Template

parameters:
  ImageID:
    type: string
    description: Image use to boot a server
  NetID:
    type: string
    description: Network ID for the server

resources:
  server1:
    type: OS::Nova::Server
    properties:
      name: "Test server"
      image: { get_param: ImageID }
      flavor: "m1.tiny"
      networks:
      - network: { get_param: NetID }

outputs:
  server1_private_ip:
    description: IP address of the server in the private network
    value: { get_attr: [ server1, first_address ] }
EOF

sleep 1

NET_ID=$(nova net-list | awk '/ demo-net / { print $2 }')
heat stack-create -f ns-stack.yml -P "ImageID=cirros-0.3.2-x86_64;NetID=$NET_ID" testStack