
PROJECT1=hub-project-x
PROJECT2=spoke1-project-x
NETWORK1=default
NETWORK2=custom

# mango project

gcloud beta compute networks peerings create hub-to-spoke1 \
  --network ${NETWORK1} \
  --peer-network ${NETWORK2} \
  --peer-project ${PROJECT2} \
  --import-custom-routes \
  --export-custom-routes

# spoke1 project

PROJECT1=hub-project-x
PROJECT2=spoke1-project-x
NETWORK1=default
NETWORK2=custom

gcloud beta compute networks peerings create spoke1-to-hub \
  --network ${NETWORK2} \
  --peer-network ${NETWORK1} \
  --peer-project ${PROJECT1} \
  --import-custom-routes \
  --export-custom-routes
