#!/bin/bash

PROJECT_ID=$(gcloud config get-value project)
URL=https://reachability.googleapis.com/v1alpha1/projects/${PROJECT_ID}/locations/global/connectivityTests?testId=


TEST_ID=test-vm-to-vm
#-----------------------------------
cat <<EOF > data.json
{
  "source": {
    "instance": "projects/${PROJECT_ID}/zones/europe-west1-c/instances/batch-job-eu",
  },
  "destination": {
    "instance": "projects/${PROJECT_ID}/zones/europe-west1-b/instances/db-eu",
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
    "instance": "projects/${PROJECT_ID}/zones/europe-west1-c/instances/batch-job-eu",
  },
  "destination": {
    "instance": "projects/${PROJECT_ID}/zones/us-central1-c/instances/data-importer-us",
    "port": 80,
  },
  "protocol": "TCP"
}
EOF
curl -i -X POST \
  -H "Authorization: Bearer $(gcloud auth print-access-token)" \
  -H "Content-Type: application/json" \
  -d  @data.json ${URL}${TEST_ID}
