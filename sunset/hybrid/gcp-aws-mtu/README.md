# IPsec VPN Between GCP and AWS

This example creates an IPsec VPN tunnel between AWS and GCP cloud platforms based on the architecture [diagram].

### GCP Subnet
In GCP, we will create a subnet with the IP address range 172.16.10.0/24. Two instances are created in this subnet.

### AWS Subnet
 In AWS, we will create one VPC, with CIDR range 10.0.0.0/16. We will then create one public subnet with IP address range 10.0.1.0/24. Two instances are created in this subnet.

### IPsec VPN Connection
The IPsec VPN tunnels has the following features:
- IKEv1
-  Pre-shared keys for authentication
- Route-based VPN
-  Static routing
-  Single VPN headend on GCP connecting to two VPN headends on AWS

### Deploying This Example on Terraform

1. Create an external IP address on GCP and save the value as *vpn_ip_address* in your aws-vpn/terraform.tfvars file or equivalent environment variable.

2. Run the AWS Terraform script in the directory *../gcp-aws-mtu/aws-vpn*. This will create output variables for the AWS VPN tunnel headend IP addresses that will be used as terraform_remote_state input for configuring the GCP IPsec tunnel.
    ```sh
    terraform plan
    terraform apply
    ```

3. Run the GCP Terraform script in the directory *../gcp-aws-mtu/gcp-vpn*.
    ```sh
    terraform plan
    terraform apply
    ```

4. Test ping connectivity from GCP instances to the AWS instances.

[diagram]: https://storage.googleapis.com/cloud-network-things/multi-cloud/mtu/gcp-aws-mtu3.PNG
