#! /bin/bash

apt-get update
apt-get install -y apache2 apache2-utils dnsutils

# probe script

touch /usr/local/bin/probez
chmod a+x /usr/local/bin/probez
cat <<EOF > /usr/local/bin/probez
i=0
while [ \$i -lt 5 ]; do
  ab -n 2 -c 2 http://${MQTT}:1883/ > /dev/null 2>&1
  ab -n 2 -c 2 http://${GCLB_STD}/ > /dev/null 2>&1
  ab -n 2 -c 2 -H "Host: ${HOST}" http://${GCLB}/browse/ > /dev/null 2>&1
  ab -n 2 -c 2 -H "Host: ${HOST}" http://${GCLB}/cart/ > /dev/null 2>&1
  ab -n 2 -c 2 -H "Host: ${HOST}" http://${GCLB}/checkout/ > /dev/null 2>&1
  ab -n 2 -c 2 -H "Host: ${HOST}" http://${GCLB}/feeds/ > /dev/null 2>&1
  let i=i+1
  sleep 3
done
EOF

echo "* * * * * /usr/local/bin/probez 2>&1 > /dev/null" > /tmp/crontab.txt
crontab /tmp/crontab.txt

touch /usr/local/bin/screenz.sh
chmod a+x /usr/local/bin/screenz.sh
cat <<EOF > /usr/local/bin/screenz.sh
while true
do
  ab -n 2 -c 2 http://${MQTT}:1883/
  ab -n 2 -c 2 http://${GCLB_STD}/
  ab -n 2 -c 2 -H "Host: ${HOST}" http://${GCLB}/browse/
  ab -n 2 -c 2 -H "Host: ${HOST}" http://${GCLB}/cart/
  ab -n 2 -c 2 -H "Host: ${HOST}" http://${GCLB}/checkout/
  ab -n 2 -c 2 -H "Host: ${HOST}" http://${GCLB}/feeds/
  sleep 3
done
EOF
