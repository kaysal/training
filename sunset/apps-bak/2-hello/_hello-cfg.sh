#!/bin/bash -xe

cd
export GO_HELLO_MAIN=https://storage.googleapis.com/salawu-gcs/gcp/instances/gke/go/1tier/main.go
export GKE_DIRECTORY=~/tf/gcp/cloudtuple/2-service/0-main/gke/clust-w1/scripts/hello
export HELLO_APP_DIRECTORY=~/kubernetes-engine-samples/hello-app
export PROJECT_ID=gke-service-project-1b
export GCR_IMAGE_REPO_1=gcr.io/${PROJECT_ID}/hello-app:v1
export GCR_IMAGE_REPO_2=gcr.io/${PROJECT_ID}/hello-app:v2
export GCR_IMAGE_REPO_3=gcr.io/${PROJECT_ID}/hello-app:v3
export GCR_IMAGE_REPO_4=gcr.io/${PROJECT_ID}/hello-app:v4
export GCR_IMAGE_REPO_test=gcr.io/${PROJECT_ID}/hello-app:test
export REGION=europe-west1
export SERVICE_ACCOUNT=~/tf/credentials/gke-service-project.json
export CLUSTER='clust-w1'
gcloud config set compute/region ${REGION}
gcloud auth activate-service-account --key-file ${SERVICE_ACCOUNT}
gcloud auth configure-docker
gcloud container clusters get-credentials ${CLUSTER} --region=${REGION}
gcloud compute instances list
kubectl config current-context

# Prepare GCR Container Images
#=============================
#docker login -u ksalawu
#read -p 'press to continue...'
rm -rf kubernetes-engine-samples/
git clone https://github.com/GoogleCloudPlatform/kubernetes-engine-samples

# hello-world exposed on ILB
cd ${HELLO_APP_DIRECTORY}
rm main.go
wget $GO_HELLO_MAIN
sed -i 's/Hello, world!/Hello Internal Load Balancer!/' main.go
docker build -t ${GCR_IMAGE_REPO_1} .
docker push ${GCR_IMAGE_REPO_1}

# hello-front exposed on TCP LB
mv main.go main.go.ilb
wget $GO_HELLO_MAIN
sed -i 's/Hello, world!/Hello Network Load Balancer!/' main.go
docker build -t ${GCR_IMAGE_REPO_2} .
docker push ${GCR_IMAGE_REPO_2}

# hello-bye on Ingress
mv main.go main.go.lb
wget $GO_HELLO_MAIN
sed -i 's/Hello, world!/Hello Ingress!/' main.go
docker build -t ${GCR_IMAGE_REPO_3} .
docker push ${GCR_IMAGE_REPO_3}

# Make hello-front & hello-bye call the ILB
mv main.go main.go.ingress
wget $GO_HELLO_MAIN
sed -i 's/\[Put Your ILB Ingress IP Here\]/10.0.4.55/' main.go
docker build -t ${GCR_IMAGE_REPO_4} .
docker push ${GCR_IMAGE_REPO_4}
