#!/bin/bash

export PROJECT_ID=gke-service-project-1b
export REGION=europe-west1
export CLUSTER='clust-w1'
export SERVICE_ACCOUNT=~/tf/credentials/gke-service-project.json

gcloud config set project $PROJECT_ID
gcloud auth activate-service-account --key-file ${SERVICE_ACCOUNT}
gcloud auth configure-docker
gcloud config set compute/region ${REGION}
gcloud container clusters get-credentials ${CLUSTER} --region=${REGION}
gcloud compute instances list
kubectl config current-context
