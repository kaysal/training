#! /bin/bash

apt-get update
apt-get install -y apache2 apache2-utils dnsutils

# probe script

touch /usr/local/bin/probez.sh
chmod a+x /usr/local/bin/probez.sh
cat <<EOF > /usr/local/bin/probez.sh
i=0
while [ \$i -lt 8 ]; do
  ab -n 4 -c 2 http://${SMTP_PROXY}:25/ > /dev/null 2>&1
  ab -n 4 -c 2 http://${GCLB_STD}/ > /dev/null 2>&1
  ab -n 4 -c 2 http://${GCLB_PREM}/ > /dev/null 2>&1
  ab -n 4 -c 2 -H "Host: ${HOST}" http://${GCLB}/browse/ > /dev/null 2>&1
  ab -n 4 -c 2 -H "Host: ${HOST}" http://${GCLB}/cart/ > /dev/null 2>&1
  ab -n 4 -c 2 -H "Host: ${HOST}" http://${GCLB}/checkout/ > /dev/null 2>&1
  ab -n 4 -c 2 -H "Host: ${HOST}" http://${GCLB}/feeds/ > /dev/null 2>&1
  let i=i+1
  sleep 1
done
EOF

echo "* * * * * /usr/local/bin/probez.sh 2>&1 > /dev/null" > /tmp/crontab.txt
crontab /tmp/crontab.txt

touch /usr/local/bin/screenz.sh
chmod a+x /usr/local/bin/screenz.sh
cat <<EOF > /usr/local/bin/screenz.sh
while true
do
  ab -n 4 -c 2 http://${SMTP_PROXY}:25/ > /dev/null 2>&1
  ab -n 4 -c 2 http://${GCLB_STD}/ > /dev/null 2>&1
  ab -n 4 -c 2 http://${GCLB_PREM}/ > /dev/null 2>&1
  ab -n 4 -c 2 -H "Host: ${HOST}" http://${GCLB}/browse/ > /dev/null 2>&1
  ab -n 4 -c 2 -H "Host: ${HOST}" http://${GCLB}/cart/ > /dev/null 2>&1
  ab -n 4 -c 2 -H "Host: ${HOST}" http://${GCLB}/checkout/ > /dev/null 2>&1
  ab -n 4 -c 2 -H "Host: ${HOST}" http://${GCLB}/feeds/ > /dev/null 2>&1
done
EOF
