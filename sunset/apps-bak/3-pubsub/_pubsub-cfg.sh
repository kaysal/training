#!/bin/bash -xe

cd
export GKE_DIRECTORY=~/tf/gcp/cloudtuple/2-service/0-main-demo/gke/clust-w1/scripts/pubsub
export PROJECT_ID=gke-service-project-1b
export GCR_IMAGE_REPO_1=gcr.io/google-samples/pubsub-sample:v1
export REGION=europe-west1
export SERVICE_ACCOUNT=~/tf/credentials/gke-service-project.json
export CLUSTER='clust-w1'
gcloud config set compute/region ${REGION}
gcloud auth activate-service-account --key-file ${SERVICE_ACCOUNT}
gcloud auth configure-docker
gcloud container clusters get-credentials ${CLUSTER} --region=${REGION}
gcloud compute instances list
kubectl config current-context

cd ${GKE_DIRECTORY}
kubectl apply -f pubsub.yaml

cd ~/tf/credentials
kubectl create secret generic pubsub-key \
  --from-file=key.json='gke-service-project-k8sapp.json'

kubectl get pods -l app=pubsub
kubectl logs -l app=pubsub

TOKEN=ya29.GludBpDbUSw_i2yMuj3UxtRYMCZh95XbmKLm416X9oVJMnYFZB4ITrU4nimvImOTchkLwmQx5bFbpt4TwKFZgZQP6wxyqnnnp818E9azCZ_Susq_sqi4uDmZnUwx
wget \
  --header="Authorization: Bearer $TOKEN" \
  https://www.googleapis.com/storage/v1/b?project=host-project-39


curl -X GET \
     -H "Authorization: Bearer $TOKEN" \
     https://www.googleapis.com/storage/v1/b?project=host-project-39
