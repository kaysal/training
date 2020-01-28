#! /bin/bash

apt-get update
apt-get install -y apache2-utils

# probe script

touch /usr/local/bin/probez.sh
chmod a+x /usr/local/bin/probez.sh
cat <<EOF > /usr/local/bin/probez.sh
i=0
while [ \$i -lt 3 ]; do
  ab -n 1 -c 1 http://${ILB}/ > /dev/null 2>&1
  ab -n 1 -c 1 http://${SITE}/ > /dev/null 2>&1
  let i=i+1
  sleep 3
done
EOF

echo "*/5 * * * * /usr/local/bin/probez.sh 2>&1 > /dev/null" > /tmp/crontab.txt
crontab /tmp/crontab.txt
