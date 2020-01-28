
PROJECT1=nic-host-project
PROJECT2=nic-spoke1-project
NETWORK1=default-vpc
NETWORK2=custom

gcloud beta compute networks peerings create hub-to-spoke1 \
  --network ${NETWORK1} \
  --peer-network ${NETWORK2} \
  --peer-project ${PROJECT2} \
  --import-custom-routes \
  --export-custom-routes

# spoke1 project

PROJECT1=nic-host-project
PROJECT2=nic-spoke1-project
NETWORK1=default-vpc
NETWORK2=custom

gcloud beta compute networks peerings create spoke1-to-hub \
  --network ${NETWORK2} \
  --peer-network ${NETWORK1} \
  --peer-project ${PROJECT1} \
  --import-custom-routes \
  --export-custom-routes
