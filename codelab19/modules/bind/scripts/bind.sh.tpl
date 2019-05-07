#! /bin/bash

# Copyright 2019 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

apt-get update
apt-get -y install dnsutils bind9 bind9-doc bind9utils

# resovconf()
cp /etc/resolv.conf /etc/resolv.conf.bak
cp /etc/dhcp/dhclient.conf /etc/dhcp/dhclient.conf.bak
cat <<EOF >> /etc/dhcp/dhclient.conf
supersede domain-name-servers ${NAME_SERVER};
supersede domain-name ${DOMAIN_NAME};
supersede domain-search ${DOMAIN_NAME_SEARCH};
EOF

wget https://storage.googleapis.com/salawu-gcs/gcp/bind/named.conf.options.text
cp named.conf.options.text /etc/bind/named.conf.options
sed -i "s|\<GCP_DNS_RANGE\>|${GCP_DNS_RANGE}|" /etc/bind/named.conf.options
sed -i "s|\<LOCAL_FORWARDERS\>|${LOCAL_FORWARDERS}|" /etc/bind/named.conf.options
sed -i "s|\<GOOGLEAPIS_ZONE\>|${GOOGLEAPIS_ZONE}|" /etc/bind/named.conf.options

wget https://storage.googleapis.com/salawu-gcs/gcp/bind/named.conf.local.text
cp named.conf.local.text /etc/bind/named.conf.local
sed -i "s|\<LOCAL_ZONE\>|${LOCAL_ZONE}|" /etc/bind/named.conf.local
sed -i "s|\<LOCAL_ZONE_FILE\>|${LOCAL_ZONE_FILE}|" /etc/bind/named.conf.local
sed -i "s|\<LOCAL_ZONE_INV\>|${LOCAL_ZONE_INV}|" /etc/bind/named.conf.local
sed -i "s|\<LOCAL_ZONE_INV_FILE\>|${LOCAL_ZONE_INV_FILE}|" /etc/bind/named.conf.local
sed -i "s|\<GOOGLEAPIS_ZONE\>|${GOOGLEAPIS_ZONE}|" /etc/bind/named.conf.local
sed -i "s|\<GOOGLEAPIS_ZONE_FILE\>|${GOOGLEAPIS_ZONE_FILE}|" /etc/bind/named.conf.local
sed -i "s|\<REMOTE_ZONE_GCP\>|${REMOTE_ZONE_GCP}|" /etc/bind/named.conf.local
sed -i "s|\<REMOTE_NS_GCP\>|${REMOTE_NS_GCP}|" /etc/bind/named.conf.local

wget https://storage.googleapis.com/salawu-gcs/gcp/bind/db.onprem.training.com.text
cp db.onprem.training.com.text ${LOCAL_ZONE_FILE}

wget https://storage.googleapis.com/salawu-gcs/gcp/bind/db.onprem.training.com.inv.text
cp db.onprem.training.com.inv.text ${LOCAL_ZONE_INV_FILE}

wget https://storage.googleapis.com/salawu-gcs/aws/bind9/db.googleapis.zone.text
cp db.googleapis.zone.text ${GOOGLEAPIS_ZONE_FILE}

service bind9 restart
reboot
