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
region=$OS_SERVICE_REGION
hostname=$OS_HOST_NAME
ext_start=$OS_EXTERNAL_START
ext_end=$OS_EXTERNAL_END
ext_gateway=$OS_EXTERNAL_GATEWAY
ext_area=$OS_EXTERNAL_AREA
ext_dns=$OS_EXTERNAL_DNS
int_gateway=$OS_INTERNAL_GATEWAY
int_area=$OS_INTERNAL_AREA

apt-get install -y neutron-server neutron-common neutron-plugin-ml2 neutron-plugin-openvswitch-agent openvswitch-datapath-dkms neutron-l3-agent neutron-dhcp-agent
source admin_openrc.sh

tenant_id=$(keystone tenant-get service | awk '/ id / {print $4}')
echo "
[DEFAULT]
# Print more verbose output (set logging level to INFO instead of default WARNING level).
# verbose = False

# Print debugging output (set logging level to DEBUG instead of default WARNING level).
# debug = False

# Where to store Neutron state files.  This directory must be writable by the
# user executing the agent.
state_path = /var/lib/neutron

# Where to store lock files
lock_path = \$state_path/lock

# log_format = %(asctime)s %(levelname)8s [%(name)s] %(message)s
# log_date_format = %Y-%m-%d %H:%M:%S

# use_syslog                           -> syslog
# log_file and log_dir                 -> log_dir/log_file
# (not log_file) and log_dir           -> log_dir/{binary_name}.log
# use_stderr                           -> stderr
# (not user_stderr) and (not log_file) -> stdout
# publish_errors                       -> notification system

# use_syslog = False
# syslog_log_facility = LOG_USER

# use_stderr = True
# log_file =
# log_dir =

# publish_errors = False

# Address to bind the API server to
# bind_host = 0.0.0.0

# Port the bind the API server to
# bind_port = 9696

# Path to the extensions.  Note that this can be a colon-separated list of
# paths.  For example:
# api_extensions_path = extensions:/path/to/more/extensions:/even/more/extensions
# The __path__ of neutron.extensions is appended to this, so if your
# extensions are in there you don't need to specify them here
# api_extensions_path =

# (StrOpt) Neutron core plugin entrypoint to be loaded from the
# neutron.core_plugins namespace. See setup.cfg for the entrypoint names of the
# plugins included in the neutron source distribution. For compatibility with
# previous versions, the class name of a plugin can be specified instead of its
# entrypoint name.
#
#core_plugin = neutron.plugins.ml2.plugin.Ml2Plugin
core_plugin = ml2

# (ListOpt) List of service plugin entrypoints to be loaded from the
# neutron.service_plugins namespace. See setup.cfg for the entrypoint names of
# the plugins included in the neutron source distribution. For compatibility
# with previous versions, the class name of a plugin can be specified instead
# of its entrypoint name.
#
service_plugins = router
# Example: service_plugins = router,firewall,lbaas,vpnaas,metering

# Paste configuration file
# api_paste_config = api-paste.ini

# The strategy to be used for auth.
# Supported values are 'keystone'(default), 'noauth'.
auth_strategy = keystone

# Base MAC address. The first 3 octets will remain unchanged. If the
# 4h octet is not 00, it will also be used. The others will be
# randomly generated.
# 3 octet
# base_mac = fa:16:3e:00:00:00
# 4 octet
# base_mac = fa:16:3e:4f:00:00

# Maximum amount of retries to generate a unique MAC address
# mac_generation_retries = 16

# DHCP Lease duration (in seconds)
# dhcp_lease_duration = 86400

# Allow sending resource operation notification to DHCP agent
# dhcp_agent_notification = True

# Enable or disable bulk create/update/delete operations
# allow_bulk = True
# Enable or disable pagination
# allow_pagination = False
# Enable or disable sorting
# allow_sorting = False
# Enable or disable overlapping IPs for subnets
# Attention: the following parameter MUST be set to False if Neutron is
# being used in conjunction with nova security groups
allow_overlapping_ips = True
# Ensure that configured gateway is on subnet
# force_gateway_on_subnet = False


# RPC configuration options. Defined in rpc __init__
# The messaging module to use, defaults to kombu.
# rpc_backend = neutron.openstack.common.rpc.impl_kombu
# Size of RPC thread pool
# rpc_thread_pool_size = 64
# Size of RPC connection pool
# rpc_conn_pool_size = 30
# Seconds to wait for a response from call or multicall
# rpc_response_timeout = 60
# Seconds to wait before a cast expires (TTL). Only supported by impl_zmq.
# rpc_cast_timeout = 30
# Modules of exceptions that are permitted to be recreated
# upon receiving exception data from an rpc call.
# allowed_rpc_exception_modules = neutron.openstack.common.exception, nova.exception
# AMQP exchange to connect to if using RabbitMQ or QPID
# control_exchange = neutron

# If passed, use a fake RabbitMQ provider
# fake_rabbit = False

# Configuration options if sending notifications via kombu rpc (these are
# the defaults)
# SSL version to use (valid only if SSL enabled)
# kombu_ssl_version =
# SSL key file (valid only if SSL enabled)
# kombu_ssl_keyfile =
# SSL cert file (valid only if SSL enabled)
# kombu_ssl_certfile =
# SSL certification authority file (valid only if SSL enabled)
# kombu_ssl_ca_certs =
# IP address of the RabbitMQ installation
# rabbit_host = localhost

# Password of the RabbitMQ server
# rabbit_password = guest
# Port where RabbitMQ server is running/listening
# rabbit_port = 5672
# RabbitMQ single or HA cluster (host:port pairs i.e: host1:5672, host2:5672)
# rabbit_hosts is defaulted to '$rabbit_host:$rabbit_port'
# rabbit_hosts = localhost:5672
# User ID used for RabbitMQ connections
# rabbit_userid = guest
# Location of a virtual RabbitMQ installation.
# rabbit_virtual_host = /
# Maximum retries with trying to connect to RabbitMQ
# (the default of 0 implies an infinite retry count)
# rabbit_max_retries = 0
# RabbitMQ connection retry interval
# rabbit_retry_interval = 1
# Use HA queues in RabbitMQ (x-ha-policy: all). You need to
# wipe RabbitMQ database when changing this option. (boolean value)
# rabbit_ha_queues = false
rpc_backend = neutron.openstack.common.rpc.impl_kombu
rabbit_host = $hostname
rabbit_password = $password
# QPID
# rpc_backend=neutron.openstack.common.rpc.impl_qpid
# Qpid broker hostname
# qpid_hostname = localhost
# Qpid broker port
# qpid_port = 5672
# Qpid single or HA cluster (host:port pairs i.e: host1:5672, host2:5672)
# qpid_hosts is defaulted to '$qpid_hostname:$qpid_port'
# qpid_hosts = localhost:5672
# Username for qpid connection
# qpid_username = ''
# Password for qpid connection
# qpid_password = ''
# Space separated list of SASL mechanisms to use for auth
# qpid_sasl_mechanisms = ''
# Seconds between connection keepalive heartbeats
# qpid_heartbeat = 60
# Transport to use, either 'tcp' or 'ssl'
# qpid_protocol = tcp
# Disable Nagle algorithm
# qpid_tcp_nodelay = True

# ZMQ
# rpc_backend=neutron.openstack.common.rpc.impl_zmq
# ZeroMQ bind address. Should be a wildcard (*), an ethernet interface, or IP.
# The "host" option should point or resolve to this address.
# rpc_zmq_bind_address = *

# ============ Notification System Options =====================

# Notifications can be sent when network/subnet/port are created, updated or deleted.
# There are three methods of sending notifications: logging (via the
# log_file directive), rpc (via a message queue) and
# noop (no notifications sent, the default)

# Notification_driver can be defined multiple times
# Do nothing driver
# notification_driver = neutron.openstack.common.notifier.no_op_notifier
# Logging driver
# notification_driver = neutron.openstack.common.notifier.log_notifier
# RPC driver.
notification_driver = neutron.openstack.common.notifier.rpc_notifier

# default_notification_level is used to form actual topic name(s) or to set logging level
# default_notification_level = INFO

# default_publisher_id is a part of the notification payload
# host = myhost.com
# default_publisher_id = $host

# Defined in rpc_notifier, can be comma separated values.
# The actual topic names will be %s.%(default_notification_level)s
# notification_topics = notifications

# Default maximum number of items returned in a single response,
# value == infinite and value < 0 means no max limit, and value must
# be greater than 0. If the number of items requested is greater than
# pagination_max_limit, server will just return pagination_max_limit
# of number of items.
# pagination_max_limit = -1

# Maximum number of DNS nameservers per subnet
# max_dns_nameservers = 5

# Maximum number of host routes per subnet
# max_subnet_host_routes = 20

# Maximum number of fixed ips per port
# max_fixed_ips_per_port = 5

# =========== items for agent management extension =============
# Seconds to regard the agent as down; should be at least twice
# report_interval, to be sure the agent is down for good
# agent_down_time = 75
# ===========  end of items for agent management extension =====

# =========== items for agent scheduler extension =============
# Driver to use for scheduling network to DHCP agent
# network_scheduler_driver = neutron.scheduler.dhcp_agent_scheduler.ChanceScheduler
# Driver to use for scheduling router to a default L3 agent
# router_scheduler_driver = neutron.scheduler.l3_agent_scheduler.ChanceScheduler
# Driver to use for scheduling a loadbalancer pool to an lbaas agent
# loadbalancer_pool_scheduler_driver = neutron.services.loadbalancer.agent_scheduler.ChanceScheduler

# Allow auto scheduling networks to DHCP agent. It will schedule non-hosted
# networks to first DHCP agent which sends get_active_networks message to
# neutron server
# network_auto_schedule = True

# Allow auto scheduling routers to L3 agent. It will schedule non-hosted
# routers to first L3 agent which sends sync_routers message to neutron server
# router_auto_schedule = True

# Number of DHCP agents scheduled to host a network. This enables redundant
# DHCP agents for configured networks.
# dhcp_agents_per_network = 1

# ===========  end of items for agent scheduler extension =====

# =========== WSGI parameters related to the API server ==============
# Number of separate worker processes to spawn.  The default, 0, runs the
# worker thread in the current process.  Greater than 0 launches that number of
# child processes as workers.  The parent process manages them.
# api_workers = 0

# Number of separate RPC worker processes to spawn.  The default, 0, runs the
# worker thread in the current process.  Greater than 0 launches that number of
# child processes as RPC workers.  The parent process manages them.
# This feature is experimental until issues are addressed and testing has been
# enabled for various plugins for compatibility.
# rpc_workers = 0

# Sets the value of TCP_KEEPIDLE in seconds to use for each server socket when
# starting API server. Not supported on OS X.
# tcp_keepidle = 600

# Number of seconds to keep retrying to listen
# retry_until_window = 30

# Number of backlog requests to configure the socket with.
# backlog = 4096

# Max header line to accommodate large tokens
# max_header_line = 16384

# Enable SSL on the API server
# use_ssl = False

# Certificate file to use when starting API server securely
# ssl_cert_file = /path/to/certfile

# Private key file to use when starting API server securely
# ssl_key_file = /path/to/keyfile

# CA certificate file to use when starting API server securely to
# verify connecting clients. This is an optional parameter only required if
# API clients need to authenticate to the API server using SSL certificates
# signed by a trusted CA
# ssl_ca_file = /path/to/cafile
# ======== end of WSGI parameters related to the API server ==========


# ======== neutron nova interactions ==========
# Send notification to nova when port status is active.
notify_nova_on_port_status_changes = True

# Send notifications to nova when port data (fixed_ips/floatingips) change
# so nova can update it's cache.
notify_nova_on_port_data_changes = True

# URL for connection to nova (Only supports one nova region currently).
nova_url = http://$hostname:8774/v2

# Name of nova region to use. Useful if keystone manages more than one region
# nova_region_name =

# Username for connection to nova in admin context
nova_admin_username = nova

# The uuid of the admin nova tenant
nova_admin_tenant_id = $tenant_id

# Password for connection to nova in admin context.
nova_admin_password = $password

# Authorization URL for connection to nova in admin context.
nova_admin_auth_url = http://$hostname:35357/v2.0

# Number of seconds between sending events to nova if there are any events to send
# send_events_interval = 2

# ======== end of neutron nova interactions ==========

[quotas]
# Default driver to use for quota checks
# quota_driver = neutron.db.quota_db.DbQuotaDriver

# Resource name(s) that are supported in quota features
# quota_items = network,subnet,port

# Default number of resource allowed per tenant. A negative value means
# unlimited.
# default_quota = -1

# Number of networks allowed per tenant. A negative value means unlimited.
# quota_network = 10

# Number of subnets allowed per tenant. A negative value means unlimited.
# quota_subnet = 10

# Number of ports allowed per tenant. A negative value means unlimited.
# quota_port = 50

# Number of security groups allowed per tenant. A negative value means
# unlimited.
# quota_security_group = 10

# Number of security group rules allowed per tenant. A negative value means
# unlimited.
# quota_security_group_rule = 100

# Number of vips allowed per tenant. A negative value means unlimited.
# quota_vip = 10

# Number of pools allowed per tenant. A negative value means unlimited.
# quota_pool = 10

# Number of pool members allowed per tenant. A negative value means unlimited.
# The default is unlimited because a member is not a real resource consumer
# on Openstack. However, on back-end, a member is a resource consumer
# and that is the reason why quota is possible.
# quota_member = -1

# Number of health monitors allowed per tenant. A negative value means
# unlimited.
# The default is unlimited because a health monitor is not a real resource
# consumer on Openstack. However, on back-end, a member is a resource consumer
# and that is the reason why quota is possible.
# quota_health_monitors = -1

# Number of routers allowed per tenant. A negative value means unlimited.
# quota_router = 10

# Number of floating IPs allowed per tenant. A negative value means unlimited.
# quota_floatingip = 50

[agent]
# Use "sudo neutron-rootwrap /etc/neutron/rootwrap.conf" to use the real
# root filter facility.
# Change to "sudo" to skip the filtering and just run the comand directly
root_helper = sudo /usr/bin/neutron-rootwrap /etc/neutron/rootwrap.conf

# =========== items for agent management extension =============
# seconds between nodes reporting state to server; should be less than
# agent_down_time, best if it is half or less than agent_down_time
# report_interval = 30

# ===========  end of items for agent management extension =====

[keystone_authtoken]
auth_uri = http://$hostname:5000
auth_host = $hostname
auth_port = 35357
auth_protocol = http
admin_tenant_name = service
admin_user = neutron
admin_password = $password
signing_dir = \$state_path/keystone-signing

[database]
# This line MUST be changed to actually run the plugin.
# Example:
# connection = mysql://root:pass@127.0.0.1:3306/neutron
# Replace 127.0.0.1 above with the IP address of the database used by the
# main neutron server. (Leave it as is if the database runs on this host.)
connection = mysql://neutron:$password@$hostname/neutron

# The SQLAlchemy connection string used to connect to the slave database
# slave_connection =

# Database reconnection retry times - in event connectivity is lost
# set to -1 implies an infinite retry count
# max_retries = 10

# Database reconnection interval in seconds - if the initial connection to the
# database fails
# retry_interval = 10

# Minimum number of SQL connections to keep open in a pool
# min_pool_size = 1

# Maximum number of SQL connections to keep open in a pool
# max_pool_size = 10

# Timeout in seconds before idle sql connections are reaped
# idle_timeout = 3600

# If set, use this value for max_overflow with sqlalchemy
# max_overflow = 20

# Verbosity of SQL debugging information. 0=None, 100=Everything
# connection_debug = 0

# Add python stack traces to SQL as comment strings
# connection_trace = False

# If set, use this value for pool_timeout with sqlalchemy
# pool_timeout = 10

[service_providers]
# Specify service providers (drivers) for advanced services like loadbalancer, VPN, Firewall.
# Must be in form:
# service_provider=<service_type>:<name>:<driver>[:default]
# List of allowed service types includes LOADBALANCER, FIREWALL, VPN
# Combination of <service type> and <name> must be unique; <driver> must also be unique
# This is multiline option, example for default provider:
# service_provider=LOADBALANCER:name:lbaas_plugin_driver_path:default
# example of non-default provider:
# service_provider=FIREWALL:name2:firewall_driver_path
# --- Reference implementations ---
service_provider=LOADBALANCER:Haproxy:neutron.services.loadbalancer.drivers.haproxy.plugin_driver.HaproxyOnHostPluginDriver:default
service_provider=VPN:openswan:neutron.services.vpn.service_drivers.ipsec.IPsecVPNDriver:default
# In order to activate Radware's lbaas driver you need to uncomment the next line.
# If you want to keep the HA Proxy as the default lbaas driver, remove the attribute default from the line below.
# Otherwise comment the HA Proxy line
# service_provider = LOADBALANCER:Radware:neutron.services.loadbalancer.drivers.radware.driver.LoadBalancerDriver:default
# uncomment the following line to make the 'netscaler' LBaaS provider available.
# service_provider=LOADBALANCER:NetScaler:neutron.services.loadbalancer.drivers.netscaler.netscaler_driver.NetScalerPluginDriver
# Uncomment the following line (and comment out the OpenSwan VPN line) to enable Cisco's VPN driver.
# service_provider=VPN:cisco:neutron.services.vpn.service_drivers.cisco_ipsec.CiscoCsrIPsecVPNDriver:default
# Uncomment the line below to use Embrane heleos as Load Balancer service provider.
# service_provider=LOADBALANCER:Embrane:neutron.services.loadbalancer.drivers.embrane.driver.EmbraneLbaas:default

" > /etc/neutron/neutron.conf

echo "
[ml2]
# (ListOpt) List of network type driver entrypoints to be loaded from
# the neutron.ml2.type_drivers namespace.
#
# type_drivers = local,flat,vlan,gre,vxlan
# Example: type_drivers = flat,vlan,gre,vxlan

# (ListOpt) Ordered list of network_types to allocate as tenant
# networks. The default value 'local' is useful for single-box testing
# but provides no connectivity between hosts.
#
# tenant_network_types = local
# Example: tenant_network_types = vlan,gre,vxlan

# (ListOpt) Ordered list of networking mechanism driver entrypoints
# to be loaded from the neutron.ml2.mechanism_drivers namespace.
# mechanism_drivers =
# Example: mechanism_drivers = openvswitch,mlnx
# Example: mechanism_drivers = arista
# Example: mechanism_drivers = cisco,logger
# Example: mechanism_drivers = openvswitch,brocade
# Example: mechanism_drivers = linuxbridge,brocade

type_drivers = gre
tenant_network_types = gre
mechanism_drivers = openvswitch


[ml2_type_flat]
# (ListOpt) List of physical_network names with which flat networks
# can be created. Use * to allow flat networks with arbitrary
# physical_network names.
#
#flat_networks = External_network
# Example:flat_networks = physnet1,physnet2
# Example:flat_networks = *

[ml2_type_vlan]
# (ListOpt) List of <physical_network>[:<vlan_min>:<vlan_max>] tuples
# specifying physical_network names usable for VLAN provider and
# tenant networks, as well as ranges of VLAN tags on each
# physical_network available for allocation as tenant networks.
#
#network_vlan_ranges = Physnet1:100:200
# Example: network_vlan_ranges = physnet1:1000:2999,physnet2

[ml2_type_gre]
# (ListOpt) Comma-separated list of <tun_min>:<tun_max> tuples enumerating ranges of GRE tunnel IDs that are available for tenant network allocation
# tunnel_id_ranges =
tunnel_id_ranges = 1:1000

[ml2_type_vxlan]
# (ListOpt) Comma-separated list of <vni_min>:<vni_max> tuples enumerating
# ranges of VXLAN VNI IDs that are available for tenant network allocation.
#
# vni_ranges =

# (StrOpt) Multicast group for the VXLAN interface. When configured, will
# enable sending all broadcast traffic to this multicast group. When left
# unconfigured, will disable multicast VXLAN mode.
#
# vxlan_group =
# Example: vxlan_group = 239.1.1.1

[securitygroup]
# Controls if neutron security group is enabled or not.
# It should be false when you use nova security group.
# enable_security_group = True

firewall_driver = neutron.agent.linux.iptables_firewall.OVSHybridIptablesFirewallDriver
enable_security_group = True


[ovs]
local_ip = $managementip
tunnel_type = gre
enable_tunneling = True

" > /etc/neutron/plugins/ml2/ml2_conf.ini

echo "
[DEFAULT]
# Show debugging output in log (sets DEBUG log level output)
# debug = False

# The DHCP agent will resync its state with Neutron to recover from any
# transient notification or rpc errors. The interval is number of
# seconds between attempts.
# resync_interval = 5

# The DHCP agent requires an interface driver be set. Choose the one that best
# matches your plugin.
# interface_driver =

# Example of interface_driver option for OVS based plugins(OVS, Ryu, NEC, NVP,
# BigSwitch/Floodlight)
# interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver

# Name of Open vSwitch bridge to use
# ovs_integration_bridge = br-int

# Use veth for an OVS interface or not.
# Support kernels with limited namespace support
# (e.g. RHEL 6.5) so long as ovs_use_veth is set to True.
# ovs_use_veth = False

# Example of interface_driver option for LinuxBridge
# interface_driver = neutron.agent.linux.interface.BridgeInterfaceDriver

# The agent can use other DHCP drivers.  Dnsmasq is the simplest and requires
# no additional setup of the DHCP server.
# dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq

# Allow overlapping IP (Must have kernel build with CONFIG_NET_NS=y and
# iproute2 package that supports namespaces).
# use_namespaces = True

# The DHCP server can assist with providing metadata support on isolated
# networks. Setting this value to True will cause the DHCP server to append
# specific host routes to the DHCP request. The metadata service will only
# be activated when the subnet does not contain any router port. The guest
# instance must be configured to request host routes via DHCP (Option 121).
# enable_isolated_metadata = False

# Allows for serving metadata requests coming from a dedicated metadata
# access network whose cidr is 169.254.169.254/16 (or larger prefix), and
# is connected to a Neutron router from which the VMs send metadata
# request. In this case DHCP Option 121 will not be injected in VMs, as
# they will be able to reach 169.254.169.254 through a router.
# This option requires enable_isolated_metadata = True
# enable_metadata_network = False

# Number of threads to use during sync process. Should not exceed connection
# pool size configured on server.
# num_sync_threads = 4

# Location to store DHCP server config files
# dhcp_confs = $state_path/dhcp

# Domain to use for building the hostnames
# dhcp_domain = openstacklocal

# Override the default dnsmasq settings with this file
# dnsmasq_config_file =

# Comma-separated list of DNS servers which will be used by dnsmasq
# as forwarders.
# dnsmasq_dns_servers =

# Limit number of leases to prevent a denial-of-service.
# dnsmasq_lease_max = 16777216

# Location to DHCP lease relay UNIX domain socket
# dhcp_lease_relay_socket = $state_path/dhcp/lease_relay

# Location of Metadata Proxy UNIX domain socket
# metadata_proxy_socket = $state_path/metadata_proxy

# dhcp_delete_namespaces, which is false by default, can be set to True if
# namespaces can be deleted cleanly on the host running the dhcp agent.
# Do not enable this until you understand the problem with the Linux iproute
# utility mentioned in https://bugs.launchpad.net/neutron/+bug/1052535 and
# you are sure that your version of iproute does not suffer from the problem.
# If True, namespaces will be deleted when a dhcp server is disabled.
# dhcp_delete_namespaces = False

# Timeout for ovs-vsctl commands.
# If the timeout expires, ovs commands will fail with ALARMCLOCK error.
# ovs_vsctl_timeout = 10

interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
use_namespaces = True
verbose = True
dnsmasq_config_file = /etc/neutron/dnsmasq-neutron.conf
" > /etc/neutron/dhcp_agent.ini



echo "
dhcp-option-force=26,1454
" > /etc/neutron/dnsmasq-neutron.conf

echo "
interface_driver = neutron.agent.linux.interface.OVSInterfaceDriver
dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
use_namespaces = True
" >> /etc/neutron/l3_agent.ini

echo "

[DEFAULT]
# Show debugging output in log (sets DEBUG log level output)
# debug = True

# The Neutron user information for accessing the Neutron API.
auth_url = http://$hostname:5000/v2.0
auth_region = $region
# Turn off verification of the certificate for ssl
# auth_insecure = False
# Certificate Authority public key (CA cert) file for ssl
# auth_ca_cert =
admin_tenant_name = service
admin_user = neutron
admin_password = $password
nova_metadata_ip = $password
metadata_proxy_shared_secret = kkkooorrreeeaaa

# Network service endpoint type to pull from the keystone catalog
# endpoint_type = adminURL

# IP address used by Nova metadata server
# nova_metadata_ip = 127.0.0.1

# TCP Port used by Nova metadata server
# nova_metadata_port = 8775

# When proxying metadata requests, Neutron signs the Instance-ID header with a
# shared secret to prevent spoofing.  You may select any string for a secret,
# but it must match here and in the configuration used by the Nova Metadata
# Server. NOTE: Nova uses a different key: neutron_metadata_proxy_shared_secret
# metadata_proxy_shared_secret =

# Location of Metadata Proxy UNIX domain socket
# metadata_proxy_socket = $state_path/metadata_proxy

# Number of separate worker processes for metadata server
# metadata_workers = 0

# Number of backlog requests to configure the metadata server socket with
# metadata_backlog = 128

# URL to connect to the cache backend.
# Example of URL using memory caching backend
# with ttl set to 5 seconds: cache_url = memory://?default_ttl=5
# default_ttl=0 parameter will cause cache entries to never expire.
# Otherwise default_ttl specifies time in seconds a cache entry is valid for.
# No cache is used in case no value is passed.
# cache_url =

" > /etc/neutron/metadata_agent.ini

service openvswitch-switch restart


echo "
net.ipv4.ip_forward=1
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0
" >> /etc/sysctl.conf
sysctl -p


service nova-compute restart
service nova-api restart
service nova-scheduler restart
service nova-conductor restart
service neutron-server restart
service neutron-plugin-openvswitch-agent restart
service neutron-l3-agent restart
service neutron-dhcp-agent restart
service neutron-metadata-agent restart

sleep 4


source admin_openrc.sh
neutron net-create ext-net --shared --router:external=True
neutron subnet-create ext-net --name ext-subnet --allocation-pool start=$ext_start,end=$ext_end --disable-dhcp --gateway $ext_gateway $ext_area

source demo_openrc.sh
neutron net-create demo-net
neutron subnet-create demo-net --name demo-subnet --gateway $int_gateway $int_area

neutron router-create demo-router
neutron router-interface-add demo-router demo-subnet
neutron router-gateway-set demo-router ext-net

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
