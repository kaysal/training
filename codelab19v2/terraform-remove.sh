#!/bin/bash

LATEST_VERSION=$(curl -sL https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].version' | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n | egrep -v 'alpha|beta|rc' | tail -1)
DOWNLOAD_URL="https://releases.hashicorp.com/terraform/${LATEST_VERSION}/terraform_${LATEST_VERSION}_linux_amd64.zip"
INSTALL_DIR=${HOME}/bin
TERRAFORM_CMD=`which terraform`

# Check all prerequisites before removing Terraform
prerequisites() {
  if [ ! -z "${TERRAFORM_CMD}" ]; then
    echo "Terraform installed at ${TERRAFORM_CMD}"
  else
    echo "Terraform is not installed!"
    echo ""
  fi
}

function terraform_remove() {
  rm -rf ${TERRAFORM_CMD}
}

main() {
  prerequisites
  terraform_remove
}

main
