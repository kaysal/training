# Cloudnet19v3

### Prerequisites
1. Create a Google Cloud Project.
2. Activate `Compute Engine API` and `Kubernetes Engine API` if not already enabled.
3. Launch a `Cloud Shell` terminal to be used for the remaining steps.

### Clone GitHub Repository for Codelabs
Open a Cloud Shell terminal and run the following command:
1. Clone the Git Repository for the Labs
```sh
git clone https://github.com/kaysal/training.git
```

2. Change to the directory of the cloned repository
```sh
cd ~/training/codelab19v3/
```

### Install Terraform
1. Install Terraform if it is not already installed

```sh
cd ~/training/codelab19v3
./terraform-install.sh
```
Note: The script above requires curl, jq and zip applications already installed on your linux OS.

2. Run the following command to reload your `PATH` with terraform:
```sh
source ~/.bashrc
```
That's it! You've installed terraform.
Next step is to deploy a lab base configuration.

### Deploy a Lab
To deploy the base configuration for a lab, navigate into the directory and run the `apply.sh` script. For example, to deploy the CDN Lab:
```sh
cd ~/training/codelab19v3/labs/CDN/
./apply.sh
```
Wait for terraform to finish creating the resources:
```sh
Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

Outputs:

cdn-ip = 35.241.15.116
[CDN]: deployed!

real    1m33.137s
user    0m6.565s
sys     0m0.896s
```
### Remove a Deployed Lab
To remove the base configuration for a lab, ensure you have followed the lab instructions to remove all other resources created in your Project's VPC; outside of the resources created by Terraform earlier. Then navigate into the directory and run the `destroy.sh` script. For example, to destroy the CDN Lab:
```sh
cd ~/training/codelab19v3/labs/CDN/
./destroy.sh
```
Wait for Terraform to delete all resources:
```sh
Destroy complete! Resources: 13 destroyed.
[CDN]: destroyed!

real    2m40.553s
user    0m6.213s
sys     0m0.849s
```
