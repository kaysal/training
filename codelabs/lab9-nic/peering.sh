
HUB_PROJECT_ID=orange-project-c3
SPOKE2_PROJECT_ID=orange-project-c3

gcloud beta compute networks peerings create hub-to-spoke2 \
  --network hub-vpc \
  --peer-network spoke2-vpc \
  --peer-project ${SPOKE2_PROJECT_ID} \
  --import-custom-routes \
  --export-custom-routes

gcloud beta compute networks peerings create spoke2-to-hub \
  --network spoke2-vpc \
  --peer-network hub-vpc \
  --peer-project ${HUB_PROJECT_ID} \
  --import-custom-routes \
  --export-custom-routes
