# LAB 1: HA VPN from GCP to GCP
This terraform code deploys:
1. On-premises environment simulated in GCP
2. A GCP Cloud environment
3. HA VPN between on-premises and GCP

![Alt Text](image.png)

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

## Deploy Lab using Script
To deploy the infrastructure, run the following commands:
```sh
./apply.sh
```
To destroy the infrastructure, run the following commands:
```sh
./destroy.sh
```

## Deploy Lab Manually

Rename the `sample.tfvars` file to `terraform.tfvars` and fill the values of all variables in the file.

To deploy manually, terraform must be run in the directories in the following order:
1. `1-vpc`
2. `2-instances`
3. `3-router`
4. `4-vpn`

In each directory, run the following commands to deploy the infrastructure:
```hcl
terraform init
terraform plan
terraform apply
```
To manually destroy the infrastructure, terraform must be run in the directories in the following order:
1. `4-vpn`
2. `3-router`
3. `2-instances`
4. `1-vpc`

In each directory, run the following command to deploy the infrastructure:
```hcl
terraform destroy
```

## Requirements
- Terraform 0.12 required.
- Activate `Compute Engine API`
