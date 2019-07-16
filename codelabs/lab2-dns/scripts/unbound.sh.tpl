#! /bin/bash

apt update
apt install -y tcpdump unbound dnsutils traceroute

wget ftp://FTP.INTERNIC.NET/domain/named.cache -O /var/lib/unbound/root.hints

rm /etc/unbound/unbound.conf
cat <<EOF > /etc/unbound/unbound.conf
# Unbound configuration file for Debian.
#
# See the unbound.conf(5) man page.
#
# See /usr/share/doc/unbound/examples/unbound.conf for a commented
# reference config file.
server:
# Use the root servers key for DNSSEC
auto-trust-anchor-file: "/var/lib/unbound/root.key"
# Enable logs
verbosity: 1
# Respond to DNS requests on all interfaces
interface: 0.0.0.0
# DNS request port, IP and protocol
port: 53
do-ip4: yes
do-ip6: no
do-udp: yes
do-tcp: yes

# Authorized IPs to access the DNS Server
access-control: 0.0.0.0 deny
access-control: 127.0.0.0/8 allow
access-control: 172.16.0.0/16 allow
access-control: 10.10.1.0/24 allow
access-control: ${DNS_EGRESS_PROXY} allow

# Root servers information (To download here: ftp://ftp.internic.net/domain/named.cache)
root-hints: "/var/lib/unbound/root.hints"

# Hide DNS Server info
hide-identity: yes
hide-version: yes

# Improve the security of your DNS Server (Limit DNS Fraud and use DNSSEC)
harden-glue: yes
harden-dnssec-stripped: yes

# Rewrite URLs written in CAPS
use-caps-for-id: yes

# TTL Min (Seconds)
cache-min-ttl: 3600
# TTL Max (Seconds)
cache-max-ttl: 86400
# Enable the prefetch
prefetch: yes

# Number of maximum threads to use
num-threads: 2

### Tweaks and optimizations
# Number of slabs to use (Must be a multiple of num-threads value)
msg-cache-slabs: 8
rrset-cache-slabs: 8
infra-cache-slabs: 8
key-cache-slabs: 8
# Cache and buffer size (in mb)
rrset-cache-size: 51m
msg-cache-size: 25m
so-rcvbuf: 1m

# Make sure your DNS Server treat your local network requests
private-address: 10.0.0.0/8
private-address: 172.16.0.0/12
private-address: 192.168.0.0/16
private-address: 169.254.0.0/16

# Add an unwanted reply threshold to clean the cache and avoid when possible a DNS Poisoning
unwanted-reply-threshold: 10000

# Authorize or not the localhost requests
do-not-query-localhost: no

# Use the root.key file for DNSSEC
#auto-trust-anchor-file: "/var/lib/unbound/root.key"

val-clean-additional: yes

# Configure local DNS A Records
${LOCAL_DATA1}
EOF

/etc/init.d/unbound restart
