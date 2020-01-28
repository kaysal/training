#!/bin/bash

export PROJECT_ID=gke-service-project-1b
export REGION=europe-west1
export CLUSTER='clust-w1'
export SERVICE_ACCOUNT=~/tf/credentials/gke-service-project.json
export GKE_DIRECTORY=~/tf/gcp/cloudtuple/2-service/0-main/gke/apps/5-hipster/microservices-demo

gcloud config set project $PROJECT_ID
gcloud auth activate-service-account --key-file ${SERVICE_ACCOUNT}
gcloud auth configure-docker
gcloud config set compute/region ${REGION}
gcloud container clusters get-credentials ${CLUSTER} --region=${REGION}
gcloud compute instances list
kubectl config current-context

pushd ${GKE_DIRECTORY} > /dev/null
skaffold run --default-repo=gcr.io/${PROJECT_ID}
kubectl get service frontend-external
popd > /dev/null
