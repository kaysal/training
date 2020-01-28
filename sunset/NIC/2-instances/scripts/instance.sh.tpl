#! /bin/bash

apt update
apt install -y tcpdump fping apache2-utils dnsutils

# file containing IP addresses to ping

mkdir /var/temp
touch /var/temp/ping_list.txt
cat <<EOF > /var/temp/ping_list.txt
10.10.1.2
10.10.2.2
10.10.3.2
10.1.1.2
10.1.2.2
10.1.3.2
10.2.1.2
EOF

# script to ping all IPs

touch /usr/local/bin/pinger
chmod a+x /usr/local/bin/pinger
cat <<EOF > /usr/local/bin/pinger
fping -A -f /var/temp/ping_list.txt
EOF
