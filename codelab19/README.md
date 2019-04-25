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
3. Launch a `Cloud Shell` terminal to be used for the remaining steps.
### Clone GitHub Repository for Codelabs
1. Clone the Git Repository for the Labs
```sh
git clone https://github.com/kaysal/training.git
```
This repository contains the following scripts:
- `terraform-install.sh` - taken from https://github.com/emanuelemazza/sme-academy-ny
- `init.sh` script for installing lab base configuration
- `remove.sh` script for removing installed lab templates

2. Change to the directory of the cloned repository
```sh
cd training/codelab19/
```
The directory structure is as follows:
```
.
├── init.sh
├── labs
│   ├── labs_1-5_vpc
│   ├── labs_11-15_ilb_&_istio
│   ├── labs_21-26_security
│   └── labs_31-32_gke
├── labs.txt
├── modules
│   ├── bind
│   ├── gce
│   ├── gke
│   └── vpn
├── README.md
├── remove.sh
├── terraform-install.sh
├── terraform.tfstate
├── tf_apply.sh
└── tf_destroy.sh

```
The `labs/` directory lists the base configs for the various lab sections. The directory tree also shows the `modules/` folder and other relevant terraform scripts.

### Install Terraform
1. Install Terraform if it is not already installed (visit [terraform.io](https://terraform.io) for other distributions).
In the `training/codelab19/` directory, run the following script:

```sh
./terraform-install.sh
```
2. Run the following command to reload your `PATH` with terraform:
```sh
source ~/.bashrc
```
That's it! You've installed terraform.
Next step is to deploy a lab base configuration.
### Deploy a Lab Base Configuration
The `init.sh` script lets you select a given lab and then configures terraform with the `Project ID` of the Project where the Cloud Shell is launched.
1. Run the `init.sh` script in the `~/training/codelab19` directory.
2. Select a lab section and follow the script prompts to provision a lab base configuration.
An example for how to run the lab section VPC:
```
$ ./init.sh
List of Labs
-----------------------
1) labs_1-5_vpc            3) labs_21-26_security
2) labs_11-15_ilb_&_istio  4) labs_31-32_gke
Select a Lab template [Press CRTL+C to exit]: 1

You selected labs_1-5_vpc

Are you sure you want to load labs_1-5_vpc? (Y/N | Yes/No):y

Configuring the base template for labs_1-5_vpc...

Running terraform init in labs/labs_1-5_vpc/...
...
[output truncated for brevity]
...
Apply complete! Resources: 26 added, 0 changed, 0 destroyed.
```

### Remove a Lab Base Configuration
To delete the installed lab base configuration template, run the `remove.sh` in the `~/training/codelab19` directory and follow the screen prompts:
```
$ ./remove.sh
List of Labs
-----------------------
1) labs_1-5_vpc            3) labs_21-26_security
2) labs_11-15_ilb_&_istio  4) labs_31-32_gke
Select a Lab template [Press CRTL+C to exit]: 1

You selected labs_1-5_vpc

Are you sure you want to remove labs_1-5_vpc? (Y/N | Yes/No):y

Removing the base template for labs_1-5_vpc...
...
[output truncated for brevity]
Plan: 0 to add, 0 to change, 26 to destroy.

Do you really want to destroy all resources?
  Terraform will destroy all your managed infrastructure, as shown above.
  There is no undo. Only 'yes' will be accepted to confirm.

  Enter a value: yes
  ...
[output truncated for brevity]
Destroy complete! Resources: 26 destroyed.
```
NOTE:
`terraform destroy` command in the `remove.sh` script might not work if you make manual changes to your infrastructure outside terraform; and those changes have a dependency on initial infrastructure created by terraform. You will have to manually remove all additional infrastructure added outside terraform; and then run the `remove.sh` script again.
