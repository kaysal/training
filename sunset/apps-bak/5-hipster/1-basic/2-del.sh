#!/bin/bash

export PROJECT_ID=gke-service-project-1b
export REGION=europe-west1
export CLUSTER='clust-w1'
export SERVICE_ACCOUNT=~/tf/credentials/gke-service-project.json
export GKE_DIRECTORY=~/tf/gcp/cloudtuple/2-service/0-main/gke/apps/5-hipster/microservices-demo

pushd ${GKE_DIRECTORY} > /dev/null
skaffold delete
popd > /dev/null
