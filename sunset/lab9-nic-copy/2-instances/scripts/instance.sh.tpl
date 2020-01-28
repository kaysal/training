#! /bin/bash

apt update
apt install -y tcpdump fping dnsutils libxml2-utils httperf

# file containing DNS records to test
#------------------------------------

mkdir /var/temp
touch /var/temp/dns_ping.txt
cat <<EOF > /var/temp/dns_ping.txt
  vm1.onprem.lab
  vm2.onprem.lab
  vm3.onprem.lab
  vm1.spoke1.lab
  vm2.spoke1.lab
  vm1.spoke2.lab
  vm2.spoke2.lab
  8.8.8.8
EOF

mkdir /var/temp
touch /var/temp/dns_dig.txt
cat <<EOF > /var/temp/dns_dig.txt
  vm1.onprem.lab
  vm2.onprem.lab
  vm3.onprem.lab
  vm1.spoke1.lab
  vm2.spoke1.lab
  vm1.spoke2.lab
  vm2.spoke2.lab
  google.com
  storage.googleapis.com
  www.googleapis.com
  compute.googleapis.com
  gcr.io
EOF

# script to test DNS resolution
#------------------------------

touch /usr/local/bin/digger
chmod a+x /usr/local/bin/digger
cat <<EOF > /usr/local/bin/digger
while read p; do
  echo -e "dig +noall +answer \$p"
  dig +noall +answer \$p
  echo ""
done < /var/temp/dns_dig.txt
EOF

# script to fping DNS names
#--------------------------

touch /usr/local/bin/pinger
chmod a+x /usr/local/bin/pinger
cat <<EOF > /usr/local/bin/pinger
  fping -A -f /var/temp/dns_ping.txt
EOF

# script for private google access test
#--------------------------------------

touch /usr/local/bin/api_trace.sh
chmod a+x /usr/local/bin/api_trace.sh
cat <<EOF > /usr/local/bin/api_trace.sh
#!/usr/bin/env python3

import os
import json
import requests
import urllib.request

url = "https://www.googleapis.com/discovery/v1/apis"
response = urllib.request.urlopen(url)
content = response.read()
data = json.loads(content.decode("utf8"))
googleapis = data['items']
reachable = []
unreachable = []

for api in googleapis:
    name = api['name']
    version = api['version']
    title = api['title']
    url = api['discoveryRestUrl']

    try:
        r = requests.get(url, timeout=3)
        if r.status_code == 200:
            reachable.append([r.status_code, title, url])
            print("{} : {:<40s} {}".format(r.status_code, title, version))
        else:
            unreachable.append([r.status_code, title, url])
            print("{} : {:<40s} {}".format(r.status_code, title, version))

    except Exception as e:
        print("{} : {:<40s} {}: __Exception__:  {}".format(r.status_code, title, version, e))

print("\n===== Reachable APIs =====")
for code, title, url in sorted(reachable):
    print("{} : {:<40s} {}".format(code, title, url))

print("\n===== Unreachable APIs =====")
for code, title, url in sorted(unreachable):
    print("{} : {:<40s} {}".format(code, title, url))
EOF
