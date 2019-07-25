#! /bin/bash

apt update
apt install -y tcpdump unbound dnsutils traceroute

rm /etc/unbound/unbound.conf
cat <<EOF > /etc/unbound/unbound.conf

server:
verbosity: 1
num-threads: 2

interface: 0.0.0.0

access-control: 0.0.0.0 deny
access-control: 127.0.0.0/8 allow
access-control: 172.16.0.0/16 allow
access-control: 10.10.1.0/24 allow
access-control: ${DNS_EGRESS_PROXY} allow

private-address: 10.0.0.0/8
private-address: 172.16.0.0/12
private-address: 192.168.0.0/16
private-address: 169.254.0.0/16

local-data: "${DNS_NAME1} A ${DNS_RECORD1}"

forward-zone:
        name: "cloud.lab"
        forward-addr: 10.10.1.3

forward-zone:
        name: "."
        forward-addr: 8.8.8.8
        forward-addr: 8.8.4.4

EOF

/etc/init.d/unbound restart
