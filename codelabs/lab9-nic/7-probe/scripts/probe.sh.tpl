#! /bin/bash

apt update
apt install -y tcpdump fping apache2-utils dnsutils

# file containing DNS records to test

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

# probe script

touch /usr/local/bin/probez
chmod a+x /usr/local/bin/probez
cat <<EOF > /usr/local/bin/probez
while true
do
  fping -A -f /var/temp/ping_list.txt
  echo ""
  ab -n 2000 -c 20 -s 3 http://${GCLB_VIP}/
  ab -n 2000 -c 20 -s 3 http://${ILB_VIP}/
  echo ""
  sleep 1
done
EOF
