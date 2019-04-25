# Cloudnet 19 SME Academy
### Prerequisites
1. Create a Google Cloud Project.
2. Activate `Compute Engine API` in your Project if you are using Compute Engine for the first time.
If the API is not activated, you might get an error similar to the following when running the labs using the terraform script:
```sh
* google_compute_network.network: Error creating Network: googleapi: Error 403: Access Not Configured. Compute Engine API has not been used in project [PROJECT_ID] before or it is disabled...
```
Not to worry! Just enable the Compute API and re-rerun the script.
Depending on the GCP cloud services tested in the labs, you might need to enable other APIs in your project.
3. [Launch a Cloud Shell](https://cloud.google.com/shell/docs/starting-cloud-shell) terminal to be used for the remaining steps.
### Clone GitHub Repository for Codelabs
1. Clone the Git Repository for the Labs
```sh
git clone https://github.com/kaysal/training.git
```
This repository contains the following scripts:
- `terraform-install.sh` - taken from https://github.com/emanuelemazza/sme-academy-ny
- `init.sh` script for installing lab base configuration
- `remove.sh` script for removing installed lab templates

The directory structure is as follows:
```
.
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
├── terraform-install.sh
├── tf_apply.sh
└── tf_destroy.sh
```
2. Change to the directory of the cloned repository
```sh
cd training/codelab19/
```
The `labs/` directory lists the base configs for the labs; `lab-security` and `lab-dns`. The directory tree also shows the modules and other relevant terraform scripts.

## Install Terraform
1. Install Terraform if it is not already installed (visit [terraform.io](https://terraform.io) for other distributions). In the `training/codelab19/` directory, run the following script:

```sh
./terraform-install.sh
```
2. Run the following to reload your `PATH` with terraform:
```sh
source ~/.bashrc
```
That's it! You now have terraform installed.
Next step is to deploy a lab base configuration.
## Run Terraform for a Lab Scenario
The `init.sh` script lets yo select a given lab and then configures terraform with the Project ID of the Project where the Cloud Shell is launched.
1. Run the `init.sh` script in the `~/training/codelab19` directory.
2. Select a lab and follow the script prompts to provision a lab base configuration scenario.
An example is shown below:
```sh
$ . init.sh
List of Labs
-----------------------
1) lab-security
2) lab-dns
Select a Lab template [Press CRTL+C to exit]: 1

You selected [lab-security]

Are you sure you want to load [lab-security]? (Y/N | Yes/No):y

Configuring the base template for [lab-security]...

Your active configuration is: [cloudshell-7660]
Your active configuration is: [cloudshell-7660]
Initializing modules...
- module.vpc_demo
  Found version 0.6.0 of terraform-google-modules/network/google on registry.terraform.io
  Getting source "terraform-google-modules/network/google"
- module.vpc_demo_vm_10_1_1
  Getting source "../../modules/gce"
- module.vpc_demo_vm_10_2_1
  Getting source "../../modules/gce"

... [Truncated for brevity]

Terraform has been successfully initialized!

... [Truncated for brevity]

Apply complete! Resources: 40 added, 0 changed, 0 destroyed.

3. To delete the lab template, run the following command:
```sh
terraform destroy -var project_id=$project_id
```
NOTE:
`terraform destroy` will not work if you make manual changes to your infrastructure outside terraform; and those changes have a dependency on initial infrastructure created by terraform. You will have to manually remove all additional infrastructure added outside terraform; and then run `terraform destroy` again.


## Run Terraform for a Lab Scenario (Manual Deployment)
1. Run the following commands to launch a lab - for example; the security lab template in the `labs/lab-security` directory
```sh
cd labs/lab-security
export TF_VAR_project_id=$(gcloud config get-value project)
terraform init
terraform plan -var project_id=$project_id
terraform apply -var project_id=$project_id
```
2. To delete the lab template, run the following command:
```sh
terraform destroy -var project_id=$project_id
```
NOTE: `terraform destroy` will not work if you make manual changes to your infrastructure outside terraform; and those changes have a dependency on initial infrastrcuture created by terraform. You will have to manually remove all additional infrastructure added outside terraform and then run `terraform destroy` again.
