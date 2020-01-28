#! /bin/bash

apt-get update
apt-get install -y apache2 apache2-utils dnsutils

# probe script

touch /usr/local/bin/probez
chmod a+x /usr/local/bin/probez
cat <<EOF > /usr/local/bin/probez
i=0
while [ \$i -lt 2 ]; do
  ab -n 1 -c 1 http://${MQTT}:1883/ > /dev/null 2>&1
  ab -n 1 -c 1 http://${GCLB_STD}/ > /dev/null 2>&1
  ab -n 1 -c 1 -H "Host: ${HOST}" http://${GCLB}/browse/ > /dev/null 2>&1
  ab -n 1 -c 1 -H "Host: ${HOST}" http://${GCLB}/cart/ > /dev/null 2>&1
  ab -n 1 -c 1 -H "Host: ${HOST}" http://${GCLB}/checkout/ > /dev/null 2>&1
  let i=i+1
  sleep 5
done
EOF

echo "*/5 * * * * /usr/local/bin/probez 2>&1 > /dev/null" > /tmp/crontab.txt
crontab /tmp/crontab.txt
