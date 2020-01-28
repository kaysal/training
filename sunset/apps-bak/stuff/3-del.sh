#!/bin/bash -xe

export PROJECT_ID=gke-service-project-1b
export GKE_DIRECTORY=~/tf/gcp/cloudtuple/2-service/0-main/gke/clust-w1/apps/1-php
export UBUNTU_WEB=gcr.io/${PROJECT_ID}/php:v17

cd ${GKE_DIRECTORY}
read -p '-------- press enter to nuke cluster --------'
kubectl delete -f $GKE_DIRECTORY/php.yaml || true
gcloud container images list
read -p '-------- press enter to nuke gcr images --------'
gcloud container images delete ${UBUNTU_WEB} --quiet
docker rmi -f $(docker images ${UBUNTU_WEB} -q)
