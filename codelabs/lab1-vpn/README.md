# LAB 1: HA VPN from GCP to GCP
This terraform code deploys:
1. On-premises environment simulated in GCP
2. A GCP Cloud environment
3. HA VPN between on-premises and GCP

![Alt Text](image.png)
---

## Prerequisite
- Terraform 0.12 required.
- Activate `Compute Engine API`

### Clone Lab
Open a Cloud Shell terminal and run the following command:
1. Clone the Git Repository for the labs
```sh
git clone https://github.com/kaysal/training.git
```

2. Change to the directory of the cloned repository
```sh
cd ~/training/codelabs/lab1-vpn
```
3. Open the file `variables.txt` and locate the environment variable `export TF_VAR_project_id`. Replace the text `Paste your project ID here` with your Project ID. This configures the terraform environment variable `export TF_VAR_project_id` (`var.project_id`) with your project ID.

## Deploy Lab using Script
To deploy the infrastructure, run the following commands:
```sh
./apply.sh
```
To destroy the infrastructure, run the following commands:
```sh
./destroy.sh
```

## Deploy Lab Manually (Optional)

1. Load the environment variables:
```sh
source variables.txt
```

2. Navigate, in the following order, into the directories to run terraform:
- `1-vpc`
- `2-instances`
- `3-router`
- `4-vpn`

In each directory, run the following commands to deploy the infrastructure:
```hcl
terraform init
terraform plan
terraform apply
```
3. To manually destroy the infrastructure, terraform must be run in the directories in the following order:
- `4-vpn`
- `3-router`
- `2-instances`
- `1-vpc`

In each directory, run the following command to deploy the infrastructure:
```hcl
terraform destroy
```
