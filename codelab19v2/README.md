# Cloudnet19v2
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
cd ~/training/codelab19v2/
```

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
### Deploy a Lab
To deploy the base configuration for a lab, navigate into the directory and run the `apply.sh` script. For example, to deploy the Security Lab:
```sh
cd ~/training/codelab19v2/labs/Security/
./apply.sh
```
You will get a notification similar to the following once the lab has been deployed completely:
```sh
Apply complete! Resources: 44 added, 0 changed, 0 destroyed.
[Security]: deployed!

real	2m1.590s
user	0m5.305s
sys	0m1.831s
./apply.sh
```
### Remove a Deployed Lab
To remove the base configuration for a lab, ensure you have followed the lab instructions to remove all other resources created in your Project's VPC; outside of the resources created by Terraform earlier. Then navigate into the directory and run the `destroy.sh` script. For example, to destroy the Security Lab:
```sh
cd ~/training/codelab19v2/labs/Security/
./destroy.sh
```
You will get a notification similar to the following once the lab has been destroyed completely:
```sh
Destroy complete! Resources: 44 destroyed.
[Security]: destroyed!

real	4m38.225s
user	0m6.529s
sys	0m1.813s

```
