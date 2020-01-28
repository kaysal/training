#! /bin/bash

apt-get update
apt-get install -y apache2-utils

# fetch batch job

touch /usr/local/bin/probez
chmod a+x /usr/local/bin/probez
cat <<EOF > /usr/local/bin/probez
i=0
while [ \$i -lt 10 ]; do
  ab -n ${n} -c ${c} http://${TARGET}/ > /dev/null 2>&1
  let i=i+1
  sleep 1
done
EOF

echo "0 * * * * /usr/local/bin/probez 2>&1 > /dev/null" > /tmp/crontab.txt
crontab /tmp/crontab.txt
