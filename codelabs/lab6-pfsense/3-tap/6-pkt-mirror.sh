





gcloud alpha compute forwarding-rules create lab6-trust-fr-ilb-collector \
  --region europe-west1 \
  --network lab6-trust-vpc \
  --subnet lab6-trust-subnet1 \
  --load-balancing-scheme internal \
  --backend-service lab6-trust-be-svc-collector \
  --ports all \
  --is-mirroring-collector

gcloud alpha compute packet-mirrorings create packet-mirror \
  --region europe-west1 \
  --network lab6-trust-vpc	 \
  --collector-ilb lab6-trust-fr-ilb-collector \
  --mirrored-subnets lab6-trust-subnet2
