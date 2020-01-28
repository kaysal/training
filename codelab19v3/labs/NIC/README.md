
# LAB: Network Intelligence Centre

This terraform code deploys the architecture shown in the image below:
![alt text](image.png)

## Prerequisite
- Terraform 0.12 required.
- Activate `Compute Engine API` and other required APIs.

### Clone Lab
Open a Cloud Shell terminal and run the following command:

Clone the Git Repository for the labs
```sh
git clone https://gitvpc2.com/kaysal/training.git
```

## Deploy Lab

Set your project ID as an environment variable. Replace `[PROJECT_ID_HERE]` with your Project ID in the command below:
```sh
export TF_VAR_project_id_vpc1=[PROJECT_ID_HERE]
export TF_VAR_project_id_vpc2=[PROJECT_ID_HERE]
```
To deploy the infrastructure, run the following command:
```sh
cd ~/training/codelabs/lab9-nic
./apply.sh
```

## Delete Lab
To destroy the infrastructure, run the following command:
```sh
cd ~/training/codelabs/lab9-nic
./destroy.sh
```
