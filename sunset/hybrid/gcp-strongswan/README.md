# Policy-based IPsec VPN - GCP (Strongswan) and AWS (VPN)

This example illustrates how to setup a BGP dynamic-routing VPN between GCP and AWS. See the diagram for the example on this [blog].

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
Create an external IP address on GCP in `europe-west2` region with the following name:
- `strongswan-vpn-gw-ip`

The IP address will be the value of a variable `peer_vpn_ip_address` in the AWS Terraform script.

## Step 2
Run Terraform for the AWS side in the directory `./aws-gcp-strongswan-policy-based/aws-vpn/` as follows:
```sh
terraform plan
terraform apply
```
You will be prompted to enter the `peer_vpn_ip_address` you created on GCP earlier in Step 1.

When Terraform completes, it will print out the output variables. An example is shown below:
```sh
$ terraform output
vpn_connection_tunnel1_address = 35.176.13.226
vpn_connection_tunnel2_address = 35.178.75.76
```
All the output values will be used as input in GCP Terraform scripts automatically, so no need to manually copy or transfer these values.

## Step 3
Run Terraform for the GCP side in directory `./aws-gcp-strongswan-policy-based/gcp-strongswan/` as follows
```sh
terraform plan
terraform apply
```

## Step 4
Configure the Strongswan configuration files to setup the tunnel.
1. SSH into the Strongswan VPN gateway `strongswan-gateway`
2. In the file `/etc/ipsec.secrets`, replace the string `[secret-key]` with the IPsec PSK - which is the simple passphrase `password123` in this case
3. In the file `/etc/ipsec.conf`, replace the following strings:
    - `[VPN_GATEWAY_EXTERNAL_IP_ADDRESS]` with the GCP VPN external IP address created in Step 1
    - `[ON_PREM_ADDRESS_SPACE]` with 10.0.1.0/24 - which represents the AWS subnet
    - `[ON_PREM_EXTERNAL_IP_ADDRESS1]` with any one of the two VPN tunnel IP addresses on AWS
4. Run `sudo ipsec restart`

For more information on the IPsec configuration see the Google cloud documentation [Special Configurations for VM Instances]
## Step 5
Test connectivity from the GCP instance `gcp-instance`to AWS instance `aws-instance`.

[blog]: <http://www.cloudnetworkstuff.com/index.php/2018/06/24/policy-based-vpn-gcp-strongswan-to-aws/>
[Special Configurations for VM Instances]: https://cloud.google.com/vpc/docs/special-configurations
