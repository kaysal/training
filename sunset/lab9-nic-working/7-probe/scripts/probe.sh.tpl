#! /bin/bash

apt update
apt install -y tcpdump fping apache2-utils dnsutils

# probe script

touch /usr/local/bin/probez
chmod a+x /usr/local/bin/probez
cat <<EOF > /usr/local/bin/probez
while true
do
  echo ""
  ab -n 1000 -c 20 -s 3 http://${GCLB_VIP}/
  ab -n 1000 -c 20 -s 3 http://${ILB_VIP}/
  ab -n 500 -c 20 -s 3 http://ifconfig.me/
  ab -n 500 -c 20 -s 3 https://199.36.153.8/
  ab -n 500 -c 20 -s 3 http://10.10.1.2/
  ab -n 500 -c 20 -s 3 http://10.10.2.2/
  ab -n 500 -c 20 -s 3 http://10.10.3.2/
  ab -n 500 -c 20 -s 3 http://10.1.1.2/
  ab -n 500 -c 20 -s 3 http://10.1.2.2/
  ab -n 500 -c 20 -s 3 http://10.1.3.2/
  ab -n 500 -c 20 -s 3 http://10.2.1.2/
  echo ""
  sleep 1
done
EOF
