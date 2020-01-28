
gcloud beta compute networks peerings create hub-to-spoke2 \
  --network hub-vpc \
  --peer-network spoke2-vpc \
  --peer-project orange-project-c3 \
  --import-custom-routes \
  --export-custom-routes

gcloud beta compute networks peerings create spoke2-to-hub \
  --network spoke2-vpc \
  --peer-network hub-vpc \
  --peer-project orange-project-c3 \
  --import-custom-routes \
  --export-custom-routes


gcloud beta compute networks peerings create hub-to-spoke2 \
  --network hub-vpc \
  --peer-network spoke2-vpc \
  --peer-project spoke2-project-x \
  --import-custom-routes \
  --export-custom-routes

gcloud beta compute networks peerings create spoke2-to-hub \
  --network spoke2-vpc \
  --peer-network hub-vpc \
  --peer-project hub-project-x \
  --import-custom-routes \
  --export-custom-routes


  httperf --server 34.102.167.95 \
   --port 80 --uri / \
   --rate 1 --num-conn 20 \
   --num-call 1000000 --timeout 5

httperf --server 34.102.167.95


PROJECT=orange-project-c3
ONPREM="172.16.1.2"
HUB="10.2.2.99"
SPOKE1="10.1.1.2"
SPOKE2="10.2.2.2"
TOKEN=$(gcloud auth print-access-token)

curl -i -X POST -H "Authorization: Bearer $(gcloud auth print-access-token)" -H "Content-Type: application/json" \
  https://reachability.googleapis.com/v1alpha1/projects/orange-project-c3/locations/global/tests?testId=test \
  -d '
  {
    "source": {
      "ipAddress": "1.1.1.1",
      "network": "projects/orange-project-c3/global/networks/hub-vpc",
      "projectId": "orange-project-c3"
    },
    "destination": {
      "ipAddress": "10.142.0.3",
      "port": 80,
      "projectId": "orange-project-c3"
    },
    "protocol": "TCP"
  }'
