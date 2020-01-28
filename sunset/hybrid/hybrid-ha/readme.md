# Dynamic VPN between GCP and AWS

This example illustrates how to setup a BGP dynamic-routing VPN between GCP and AWS. See this [diagram] for the scenario setup.

### Running the Script
---
To run, configure your Google Cloud provider as described in https://www.terraform.io/docs/providers/google/index.html

The variables are located in the `variables.tf` file. You can add a `terraform.tfvars` file to hold your account credentials and secret keys.
Or you can declare the variables when running *terraform apply* as follows:
```sh
terraform apply \
	-var="region=us-central1" \
	-var="region_zone=us-central1-f" \
	-var="project_name=my-project-id-123" \
	-var="credentials_file_path=~/.gcloud/Terraform.json" \
```

## Step 1
Create external IP addresses on GCP with the following names:
- `gcp-eu-w1-vpn-gw1-ip` (region = europe-west1)
- `gcp-eu-w1-vpn-gw2-ip` (region = europe-west1)
- `gcp-us-e1-vpn-gw1-ip` (region = us-east1)
- `gcp-us-e1-vpn-gw2-ip` (region = us-east1)

## Step 2
Run Terraform in the directory `./aws/eu-west1/vpc1/eu-west1` as follows:
```sh
terraform plan
terraform apply
```
You will be prompted to enter the values of the external IP addresses created in Step 1.

When Terraform completes, it will print out the output variables. An example is shown below:
```sh
salawu@salawu:~/Terraform/Multicloud/hybrid-gcp-aws/aws/eu-west1/vpc1$ terraform output
--- eu-w1-vpc1-ubuntu --- = [
    az:        eu-west-1a ,
    priv ip:   172.16.10.208 ,
    pub ip:    54.154.225.139 ,
    priv dns:  ip-172-16-10-208.eu-west-1.compute.internal ,
    key name:  kayode-ec2-ireland
]
--- eu-w1-vpc1-windows --- = [
    az:        eu-west-1b ,
    priv ip:   172.16.11.221 ,
    pub ip:    54.229.73.211 ,
    priv dns:  ip-172-16-11-221.eu-west-1.compute.internal ,
    key name:  kayode-ec2-ireland
]
aws_eu_w1_vpc1_cgw1_tunnel1_address = 52.18.195.2
aws_eu_w1_vpc1_cgw1_tunnel1_vgw_inside_address = 169.254.20.81
aws_eu_w1_vpc1_cgw1_tunnel2_address = 54.194.74.164
aws_eu_w1_vpc1_cgw1_tunnel2_vgw_inside_address = 169.254.22.125
aws_eu_w1_vpc1_cgw2_tunnel1_address = 34.242.198.77
aws_eu_w1_vpc1_cgw2_tunnel1_vgw_inside_address = 169.254.21.29
aws_eu_w1_vpc1_cgw2_tunnel2_address = 52.30.191.142
aws_eu_w1_vpc1_cgw2_tunnel2_vgw_inside_address = 169.254.20.105
gcp_eu_w1_vpc1_cgw1_tunnel1_cgw_inside_address = 169.254.20.82
gcp_eu_w1_vpc1_cgw1_tunnel2_cgw_inside_address = 169.254.22.126
gcp_eu_w1_vpc1_cgw2_tunnel1_cgw_inside_address = 169.254.21.30
gcp_eu_w1_vpc1_cgw2_tunnel2_cgw_inside_address = 169.254.20.106
```
All the output values will be used as input in GCP Terraform scripts automatically, so no need to manually copy or transfer these values.

## Step 3
Next run Terraform for second AWS region`./aws/eu-west1/vpc1/us-east1` as described in Step 1.

## Step 4
And then run Terraform in directory `./gcp/vpc/` to create the GCP networks, subnets and security rules

## Step 5
Then run Terraform in the following GCP directories to create resources in the 3 regions:
- `./gcp/eu-west1/`
- `./gcp/us-east1/`

## Step 6
Test for ping connectivity from any GCP node in region `europe-west-1` to AWS `eu-west1`. And also test for connectivity from the instance in GCP `us-east-1` to AWS `us-east1`.

[diagram]: <https://storage.googleapis.com/cloud-network-things/multi-cloud/ipsec/gcp-aws-dynamic-vpn/hybrid-gcp-aws.jpg>
