# Cloudnet19
### Prerequisites
1. Create a Google Cloud Project.
2. Activate `Compute Engine API` in your Project if you are using Compute Engine for the first time.
3. Launch a `Cloud Shell` terminal to be used for the remaining steps.
### Clone GitHub Repository for Codelabs
Open a Cloud Shell terminal and run the following command:
1. Clone the Git Repository for the Labs
```sh
git clone https://github.com/kaysal/training.git
```
The cloned repository contains the following scripts:
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
│   ├── DNS
│   ├── HA_VPN
│   ├── ILB
│   ├── NAT
│   ├── Security
│   └── VPC_Peering
├── labs.txt
├── modules
│   ├── bind
│   ├── gce-private
│   ├── gce-public
│   ├── gke
│   └── vpn
├── README.md
├── remove.sh
├── terraform-install.sh
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
Note: that the script above requires `jq` and `zip` applications already installed on your linux OS. If you get any errors
2. Run the following command to reload your `PATH` with terraform:
```sh
source ~/.bashrc
```
That's it! You've installed terraform.
Next step is to deploy a lab base configuration.
### Deploy a Lab
The `init.sh` script lets you select a given lab and then configures terraform with the `Project ID` of the Project where the Cloud Shell is launched.
1. Run the `init.sh` script in the `~/training/codelab19` directory.
```sh
./init.sh
```
2. Select a lab section and follow the instructions. The example below shows how to setup the ILB lab environment.
```
~$ . init.sh

List of Labs
-----------------------
1) NAT
2) VPC_Peering
3) HA_VPN
4) DNS
5) ILB
6) Security
7) GKE
Select a Lab template number [Press CRTL+C to exit]: 5

You selected ILB
Are you sure you want to load ILB? (Y/N | Yes/No):y

Setting up the base template for ILB ...
...
Apply complete! Resources: 7 added, 0 changed, 0 destroyed.

real    1m46.601s
user    0m3.803s
sys     0m0.754s
```
The timer value `real` displays the time taken to deploy the lab.

### Remove a deployed Lab
To delete the installed lab base configuration template, run the `remove.sh` script in the `~/training/codelab19` directory and follow the screen prompts:
```sh
./remove.sh
```
The example below shows how to remove the ILB lab deployed above.
```
~$ ./remove.sh

ILB lab is currently deployed

Are you sure you want to remove ILB lab? (Y/N | Yes/No):y

Removing base template for ILB ...
...
Running terraform destroy in directory labs/ILB/...
...
Destroy complete! Resources: 7 destroyed.

real    3m49.335s
user    0m1.885s
sys     0m0.495s

```
The timer value `real` displays the time taken to delete the lab - in this case, 3 mins 49s.

### Troubleshooting
1. `terraform destroy` command in the `remove.sh` script will generally not work after GCP resources are added to the lab base config deployed by terraform. To fix this, complete the lab cleanup section to remove all configuration deployed for the lab and then run the `remove.sh` script again.

2. Terraform API call error `googleapi: Error 403: Access Not Configured`.
If all required APIs are not activated, you might get an error similar to the following when running the labs using the terraform script:
```
* google_compute_network.network: Error creating Network: googleapi: Error 403: Access Not Configured.
Compute Engine API has not been used in project [PROJECT_ID] before or it is disabled...
```
In this case, the Compute API was not enabled during step 2 of the prerequisites section. Not to worry! Just enable the Compute API (in this example) and re-rerun the `init.sh` script. Depending on the GCP cloud services tested in the labs, you might need to enable other APIs in your project.

3. The `terraform-install.sh` script requires that `jq` and `unzip` applications are already installed on your linux OS. If not installed it might give any of the following errors:
```
$ ./terraform-install.sh
./terraform-install.sh: line 5: jq: command not found
```
```
$ ./terraform-install.sh
./terraform-install.sh: line 9: unzip: command not found
```
The applications should already be available in GCP Cloudshell. In case you are using a different linux distribution, or for some reason, your Cloudshell throws any of the above errors, then just install the applications:
```
$ sudo apt install jq unzip -y
```
