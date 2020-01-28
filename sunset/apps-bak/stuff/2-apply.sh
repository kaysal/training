#!/bin/bash -xe

export GKE_DIRECTORY=~/tf/gcp/cloudtuple/2-service/0-main/gke/clust-w1/apps/1-php
export APP_KEY='gke-service-project-app-php.json'
export CREDENTIAL_DIR=~/tf/credentials

cd ${CREDENTIAL_DIR}
kubectl create secret generic phpkey --from-file=key.json=${APP_KEY} || true
kubectl get secret

cd ${GKE_DIRECTORY}
kubectl apply -f php.yaml
