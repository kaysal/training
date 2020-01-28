#!/bin/bash -xe

export PROJECT_ID=gke-service-project-1b
export GKE_DIRECTORY=~/tf/gcp/cloudtuple/2-service/0-main/gke/clust-w1/scripts/hello
export GCR_IMAGE_REPO_1=gcr.io/${PROJECT_ID}/hello-app:v1
export GCR_IMAGE_REPO_2=gcr.io/${PROJECT_ID}/hello-app:v2
export GCR_IMAGE_REPO_3=gcr.io/${PROJECT_ID}/hello-app:v3
export GCR_IMAGE_REPO_4=gcr.io/${PROJECT_ID}/hello-app:v4
export GCR_IMAGE_REPO_test=gcr.io/${PROJECT_ID}/hello-app:test

cd ${GKE_DIRECTORY}
read -p 'press enter to nuke cluster...'
kubectl delete -f $GKE_DIRECTORY/hello-ilb.yaml || echo 'continue...'
kubectl delete -f $GKE_DIRECTORY/hello-lb.yaml || echo 'continue...'
kubectl delete -f $GKE_DIRECTORY/hello-ingress.yaml || echo 'continue...'
gcloud container images list
read -p 'press enter to nuke gcr images...'
gcloud container images delete $GCR_IMAGE_REPO_1 --quiet
gcloud container images delete $GCR_IMAGE_REPO_2 --quiet
gcloud container images delete $GCR_IMAGE_REPO_3 --quiet
gcloud container images delete $GCR_IMAGE_REPO_4 --quiet
docker rmi -f $(docker images -q)
