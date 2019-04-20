This example configures the base template for various labs - security, DNS etc

## Change to the example directory

## Install Terraform

1. Clone the GitHub repo for the script to install terraform
```sh
git clone https://github.com/emanuelemazza/sme-academy-ny
```
2. Change to the directory of the cloned repository
```sh
cd sme-academy-ny/
```
3. Install Terraform if it is not already installed (visit [terraform.io](https://terraform.io) for other distributions):

```sh
./terraform-install.sh
```

## Run Terraform for a Lab Scenario
1. Clone the Git Repository for the Lab scenarios
```sh
git clone https://github.com/kaysal/training.git
```
2. Change to the directory of the cloned repository
```sh
cd training/codelab19/
```
The directory structure is as follows:
```
├── init.sh
├── labs
│   ├── lab-dns
│   │   ├── main.tf
│   │   ├── scripts
│   │   │   └── startup.sh
│   │   └── variables.tf
│   └── lab-security
│       ├── main.tf
│       ├── scripts
│       │   └── startup.sh
│       └── variables.tf
├── labs.txt
├── modules
│   ├── gce
│   │   ├── main.tf
│   │   ├── output.tf
│   │   └── variables.tf
│   ├── gke
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   ├── README.md
│   │   └── vars.tf
│   └── vpn
│       ├── main.tf
│       ├── outputs.tf
│       └── variables.tf
├── README.md
├── remove.sh
├── tf_apply.sh
└── tf_destroy.sh
```

This shows 2 labs (lab-security and lab-dns) together with modules and other relevant terraform scripts.

3. Run the following commands to launch a lab - for example; the security lab template in the *labs/lab-security* directory
```sh
cd labs/lab-security
export TF_VAR_project_id=$(gcloud config get-value project)
terraform init
terraform plan -var project_id=$project_id
terraform apply -var project_id=$project_id
```
4. To delete the lab template run
```
terraform destroy -var project_id=$project_id
```
