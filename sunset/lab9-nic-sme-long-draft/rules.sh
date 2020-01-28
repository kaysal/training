#!/bin/bash

# (1) Packet Dropped Due to Firewall Rule

PROJECT_ID=$(gcloud config get-value project)
export GCLB_IP=`gcloud compute addresses describe vip-gclb --format="value(address)" --global`
export ILB_IP=`gcloud compute addresses describe vip-ilb --format="value(address)" --region=asia-east2`
URL=https://reachability.googleapis.com/v1alpha1/projects/${PROJECT_ID}/locations/global/connectivityTests?testId=

#-----------------------------------
TEST_ID=web-test
cat <<EOF > data.json
{
  "source": {
    "instance": "projects/${PROJECT_ID}/zones/europe-west2-b/instances/hub-eu-vm",
  },
  "destination": {
    "instance": "projects/${PROJECT_ID}/zones/asia-east2-b/instances/hub-asia-vm",
    "port": 80,
  },
  "protocol": "TCP"
}
EOF
curl -i -X POST \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d  @data.json ${URL}${TEST_ID}



PROJECT_ID=$(gcloud config get-value project)
export GCLB_IP=`gcloud compute addresses describe vip-gclb --format="value(address)" --global`
export ILB_IP=`gcloud compute addresses describe vip-ilb --format="value(address)" --region=asia-east2`
URL=https://reachability.googleapis.com/v1alpha1/projects/${PROJECT_ID}/locations/global/connectivityTests?testId=

# 1) vm to GCLB VIP
#-----------------------------------
TEST_ID=vm-to-gclb
cat <<EOF > data.json
{
  "source": {
    "ipAddress": "10.10.1.2",
    "network": "projects/${PROJECT_ID}/global/networks/hub-vpc",
  },
  "destination": {
    "ipAddress": "${GCLB_IP}",
    "network": "projects/${PROJECT_ID}/global/networks/spoke1-vpc",
    "port": 80,
  },
  "protocol": "TCP"
}
EOF
curl -i -X POST \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d  @data.json ${URL}${TEST_ID}



PROJECT_ID=$(gcloud config get-value project)
export GCLB_IP=`gcloud compute addresses describe vip-gclb --format="value(address)" --global`
export ILB_IP=`gcloud compute addresses describe vip-ilb --format="value(address)" --region=asia-east2`
URL=https://reachability.googleapis.com/v1alpha1/projects/${PROJECT_ID}/locations/global/connectivityTests?testId=

# 2) vm to GCLB VIP
#-----------------------------------
TEST_ID=vm-to-ilb
cat <<EOF > data.json
{
  "source": {
    "ipAddress": "10.10.1.2",
    "network": "projects/${PROJECT_ID}/global/networks/hub-vpc",
  },
  "destination": {
    "ipAddress": "${ILB_IP}",
    "network": "projects/${PROJECT_ID}/global/networks/spoke2-vpc",
    "port": 80,
  },
  "protocol": "TCP"
}
EOF
curl -i -X POST \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d  @data.json ${URL}${TEST_ID}

#====================================================

# 1) vm to vm ping
#-----------------------------------
TEST_ID=vm-to-vm
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


# 2) vm to internet ping
#-----------------------------------
TEST_ID=vm-to-internet
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
