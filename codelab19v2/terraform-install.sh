#!/bin/bash

LATEST_VERSION=$(curl -sL https://releases.hashicorp.com/terraform/index.json | jq -r '.versions[].version' | sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n | egrep -v 'alpha|beta|rc' | tail -1)
DOWNLOAD_URL="https://releases.hashicorp.com/terraform/${LATEST_VERSION}/terraform_${LATEST_VERSION}_linux_amd64.zip"
DOWNLOAD_DIR=/tmp
INSTALL_DIR=${HOME}/bin
TERRAFORM_CMD=`which terraform`

# Check all prerequisites before installing Terraform
prerequisites() {
  local curl_cmd=`which curl`
  local unzip_cmd=`which unzip`
  local jq_cmd=`which jq`

  if [ ! -z "${TERRAFORM_CMD}" ]; then
    echo "INFO: `${INSTALL_DIR}/terraform version` already installed at ${TERRAFORM_CMD}"
    echo "INFO: Latest version is Terraform v${LATEST_VERSION}"
    echo "INFO: To install latest version, run 'terraform-remove.sh' and then 'terraform-install.sh'"
    exit 1
  fi

  if [ -z "$curl_cmd" ]; then
    echo "Please install curl and re-run this script:"
    echo "  sudo apt-get install curl"
    exit 1
  fi

  if [ -z "$unzip_cmd" ]; then
    echo "Please install unzip and re-run this script:"
    echo "  sudo apt-get install unzip"
    exit 1
  fi

  if [ -z "$jq_cmd" ]; then
    echo "Please install jq and re-run this script:"
    echo "  sudo apt-get install jq"
    exit 1
  fi
}

function terraform_install() {
  curl ${DOWNLOAD_URL} > ${DOWNLOAD_DIR}/terraform.zip
  mkdir -p ${HOME}/bin
  echo ""
  (cd ${INSTALL_DIR} && unzip ${DOWNLOAD_DIR}/terraform.zip)

  if [[ -z $(grep 'export PATH=${HOME}/bin:${PATH}' ~/.bashrc 2>/dev/null) ]]; then
        echo 'export PATH=${HOME}/bin:${PATH}' >> ~/.bashrc
  fi

  echo ""
  echo "Installed: `${INSTALL_DIR}/terraform version`"

  cat - << EOF

Run the following to reload your PATH with terraform:
  source ~/.profile

EOF
}

main() {
  prerequisites
  terraform_install
}

main
