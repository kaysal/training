#!/bin/bash

export TF_WARN_OUTPUT_ERRORS=1
export GOOGLE_PROJECT=$(gcloud config get-value project)
echo "GOOGLE_PROJECT variable set as active project [$GOOGLE_PROJECT] "
echo ""

export TF_VAR_project_id=$(gcloud config get-value project)
echo "TF_VAR_project_id variable set as active project [$TF_VAR_project_id] "
echo ""

while getopts d:h: option
do
  case "${option}" in
    d) FOLDER=$OPTARG;;
    h) HELP=$OPTARG;;
esac
done

tf_destroy() {
  cd $FOLDER
  terraform destroy -var project_id=$project_id
}

tf_destroy
