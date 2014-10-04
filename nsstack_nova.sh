#!/bin/bash

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "You need to be 'root' dude." 1>&2
   exit 1
fi
. ./nsstack_setuprc

password=$OS_PASSWORD    
managementip=$OS_SERVICE_IP
rignic=$OS_SERVICE_NIC
hostname=$OS_HOST_NAME

# install packages
apt-get install -y nova-api nova-cert nova-conductor nova-consoleauth nova-novncproxy nova-scheduler python-novaclient
apt-get install -y nova-compute-kvm


echo "
[DEFAULT]
dhcpbridge_flagfile=/etc/nova/nova.conf
dhcpbridge=/usr/bin/nova-dhcpbridge
logdir=/var/log/nova
state_path=/var/lib/nova
lock_path=/var/lock/nova
force_dhcp_release=True
iscsi_helper=tgtadm
libvirt_use_virtio_for_bridges=True
connection_type=libvirt
root_helper=sudo nova-rootwrap /etc/nova/rootwrap.conf
verbose=True
ec2_private_dns_show_ip=True
osapi_compute_extension = nova.api.openstack.compute.contrib.standard_extensions
ec2_workers=4
osapi_compute_workers=4
metadata_workers=4
osapi_volume_workers=4
osapi_compute_listen=$hostname
osapi_compute_listen_port=8774
ec2_listen=$hostname
ec2_listen_port=8773
ec2_host=$hostname
ec2_private_dns_show_ip=True

api_paste_config=/etc/nova/api-paste.ini
volumes_path=/var/lib/nova/volumes
enabled_apis=ec2,osapi_compute,metadata
rpc_backend = rabbit
rabbit_host = $hostname
rabbit_password = $password
my_ip = $managementip
vnc_enabled = True
vncserver_listen = $managementip
vncserver_proxyclient_address = $managementip
novncproxy_base_url = http://$managementip:6080/vnc_auto.html
auth_strategy =keystone
glance_host = $hostname


network_api_class = nova.network.neutronv2.api.API
neutron_url = http://$hostname:9696
neutron_auth_strategy = keystone
neutron_admin_tenant_name = service
neutron_admin_username = neutron
neutron_admin_password = $password
neutron_admin_auth_url = http://$hostname:35357/v2.0
linuxnet_interface_driver = nova.network.linux_net.LinuxOVSInterfaceDriver
firewall_driver = nova.virt.firewall.NoopFirewallDriver
security_group_api = neutron
service_neutron_metadata_proxy = True
neutron_metadata_proxy_shared_secret = kkkooorrreeeaaa



instance_usage_audit = True
instance_usage_audit_period = hour
notify_on_state_change = vm_and_task_state
notification_driver = nova.openstack.common.notifier.rpc_notifier
notification_driver = ceilometer.compute.nova_notifier




[database]
connection = mysql://nova:$password@$hostname/nova


[keystone_authtoken]
auth_uri = http://$hostname:5000
auth_host = $hostname
auth_port = 35357
auth_protocol = http
admin_tenant_name = service
admin_user = nova
admin_password = $password
" > /etc/nova/nova.conf

su -s /bin/sh -c "nova-manage db sync" nova

rm /var/lib/nova/nova.sqlite
service nova-api restart
service nova-cert restart
service nova-consoleauth restart
service nova-scheduler restart
service nova-conductor restart
service nova-novncproxy restart
service nova-compute restart



