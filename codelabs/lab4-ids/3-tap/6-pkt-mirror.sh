

gcloud alpha compute forwarding-rules create lab4-vpc1-fr-ilb-collector \
  --region europe-west1 \
  --network lab4-vpc1-vpc \
  --subnet lab4-vpc1-collector \
  --load-balancing-scheme internal \
  --backend-service lab4-vpc1-be-svc-collector \
  --ports all \
  --is-mirroring-collector

gcloud alpha compute packet-mirrorings create packet-mirror \
  --region europe-west1 \
  --network lab4-vpc1-vpc \
  --collector-ilb lab4-vpc1-fr-ilb-collector \
  --mirrored-subnets lab4-vpc1-mirror

gcloud -q alpha compute packet-mirrorings delete packet-mirror --region europe-west1
gcloud -q alpha compute forwarding-rules delete lab4-vpc1-fr-ilb-collector --region europe-west1
