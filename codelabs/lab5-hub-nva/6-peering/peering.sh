
project_id=kayode-salawu

gcloud beta compute networks peerings create trust-to-east \
  --network lab3-trust-vpc \
  --peer-network lab3-east-vpc \
  --peer-project ${project_id} \
  --import-custom-routes \
  --export-custom-routes

gcloud beta compute networks peerings create east-to-trust \
  --network lab3-east-vpc \
  --peer-network lab3-trust-vpc \
  --peer-project ${project_id} \
  --import-custom-routes \
  --export-custom-routes
