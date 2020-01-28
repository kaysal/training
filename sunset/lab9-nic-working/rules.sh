#!/bin/bash

PROJECT_ID=$(gcloud config get-value project)
URL=https://reachability.googleapis.com/v1alpha1/projects/${PROJECT_ID}/locations/global/connectivityTests?testId=


TEST_ID=vtest-m-to-vm
#-----------------------------------
cat <<EOF > data.json
{
  "source": {
    "ipAddress": "10.10.1.2",
    "network": "projects/${PROJECT_ID}/global/networks/hub-vpc",
  },
  "destination": {
    "ipAddress": "10.2.1.2",
    "network": "projects/${PROJECT_ID}/global/networks/spoke2-vpc",
  },
  "protocol": "ICMP"
}
EOF
curl -i -X POST \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d  @data.json ${URL}${TEST_ID}


TEST_ID=test-ha-vpn
#-----------------------------------
cat <<EOF > data.json
{
  "source": {
    "ipAddress": "10.1.1.2",
      "network": "projects/${PROJECT_ID}/global/networks/hub-vpc",
  },
  "destination": {
    "ipAddress": "8.8.8.8",
    "networkType": "NON_GCP_NETWORK",
  },
  "protocol": "ICMP"
}
EOF
curl -i -X POST \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d  @data.json ${URL}${TEST_ID}


# 3) internet to vm (use GUI)
#-----------------------------------
TEST_ID=internet-to-vm
GCLB_VIP=

cat <<EOF > data.json
{
  "source": {
    "ipAddress": "8.8.8.8",
    "networkType": "NON_GCP_NETWORK",
  },
  "destination": {
    "ipAddress": "10.10.1.2",
    "network": "projects/${PROJECT_ID}/global/networks/hub-vpc",
    "port": 22,
  },
  "protocol": "TCP"
}
EOF
curl -i -X POST \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d  @data.json ${URL}${TEST_ID}
