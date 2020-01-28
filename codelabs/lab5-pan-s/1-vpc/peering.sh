gcloud beta compute networks peerings create trust-to-zone1 \
  --network lab3-trust-vpc \
  --peer-network lab3-zone1-vpc \
  --peer-project $project_id \
  --import-custom-routes \
  --export-custom-routes

gcloud beta compute networks peerings create zone1-to-trust \
  --network lab3-zone1-vpc \
  --peer-network lab3-trust-vpc \
  --peer-project $project_id \
  --import-custom-routes \
  --export-custom-routes
