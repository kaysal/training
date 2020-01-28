#!/bin/bash

export HOST_PROJECT_ID=host-project-39
export PROJECT_ID=gke-service-project-1b
export REGION=europe-west1
export CLUSTER='clust-w1'
export SERVICE_ACCOUNT=~/tf/credentials/gke-service-project.json
export GKE_DIRECTORY=~/tf/gcp/cloudtuple/2-service/0-main/gke/clust-w1/apps/5-hipster/microservices-demo

gcloud config set project $PROJECT_ID
gcloud auth configure-docker
gcloud config set compute/region ${REGION}
gcloud container clusters get-credentials ${CLUSTER} --region=${REGION}
kubectl config current-context
kubectl get nodes
gcloud beta container subnets list-usable --network-project ${HOST_PROJECT_ID}

kubectl label namespace default istio-injection=enabled

cd ${GKE_DIRECTORY}

kubectl apply -f ./istio-manifests
skaffold run --default-repo=gcr.io/${PROJECT_ID}
kubectl get pods
INGRESS_HOST="$(kubectl -n istio-system get service istio-ingressgateway \
   -o jsonpath='{.status.loadBalancer.ingress[0].ip}')"
echo "$INGRESS_HOST"
