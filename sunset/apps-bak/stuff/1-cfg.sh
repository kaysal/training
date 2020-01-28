#!/bin/bash

export GKE_DIRECTORY=~/tf/gcp/cloudtuple/2-service/0-main/gke/clust-w1/apps/1-php
export PROJECT_ID=gke-service-project-1b
export UBUNTU_WEB=gcr.io/${PROJECT_ID}/php:v17

# Prepare GCR Container Images
#=============================
cd ${GKE_DIRECTORY}
docker build -t ${UBUNTU_WEB} .
docker push ${UBUNTU_WEB}
# docker run --rm -p 4000:8080 ${UBUNTU_WEB}
