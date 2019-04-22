#!/bin/bash

export TF_WARN_OUTPUT_ERRORS=1
export GOOGLE_PROJECT=$(gcloud config get-value project)
export TF_VAR_project_id=$(gcloud config get-value project)

IFS=$'\n'
while getopts d:h: option
do
  case "${option}" in
    d) FOLDER=$OPTARG;;
    h) HELP=$OPTARG;;
esac
done

tf_apply() {
  pushd ${FOLDER}
  terraform init -input=false
  terraform plan -input=false -out tfplan -var project_id=$project_id
  terraform apply -input=false tfplan

  if [ -f tfplan ]; then
    rm tfplan
  fi
}

tf_apply
