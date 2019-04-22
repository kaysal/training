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
4. Reload your bashrc to pick up the changes made
```
source ~/.bashrc
```

## Set up the environment

1. Set the project, replace `YOUR_PROJECT` with your project ID:

```
PROJECT=YOUR_PROJECT
```

```
gcloud config set project ${PROJECT}
```

2. Configure the environment for Terraform:

```
[[ $CLOUD_SHELL ]] || gcloud auth application-default login
export GOOGLE_PROJECT=$(gcloud config get-value project)
```


## Download the Lab base configuration from Github
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

These shows 2 labs (lab-security and lab-dns) together with modules and other relevant terraform scripts.

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
```
terraform destroy -var project_id=$project_id
```
NOTE: `terraform destroy` will not work if you make manual changes to your infrastructure outside terraform; and those changes have a dependency on initial infrastrcuture created by terraform. You will have to manually remove all additional infrastructure added outside terraform and then run `terraform destroy` again.


## Run Terraform for a Lab Scenario (Script Automation)

1. Run the `init.sh` script in the `~/training/codelab19` directory.
2. Select a lab and follow the script prompts to provision a lab base configuration scenario:
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
...
```
