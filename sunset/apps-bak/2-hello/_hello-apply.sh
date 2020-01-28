#!/bin/bash -xe

export GKE_DIRECTORY=~/tf/gcp/cloudtuple/2-service/0-main/gke/apps/hello

cd ~/tf/credentials

kubectl create secret generic app-key \
  --from-file=key.json='gke-service-project-k8sapp.json' || true

kubectl get secret

cd ${GKE_DIRECTORY}
kubectl apply -f hello-ilb.yaml
kubectl apply -f hello-lb.yaml
kubectl apply -f hello-ingress.yaml
