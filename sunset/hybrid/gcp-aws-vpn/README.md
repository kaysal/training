# IPsec VPN Between GCP and AWS

This example creates an IPsec VPN tunnel between AWS and GCP cloud platforms based on the architecture [diagram].

### GCP Subnets
In GCP, we will create two subnets. One subnet for our bastion instance, *subnet_bastion*, with the IP address range 172.16.1.0/24. And one subnet, *subnet_lb* in the IP address range 172.16.10.0/24, for our web server instances that will be deployed behind a load balancer.

The loadbalancer is used to terminate IPv6 HTTP traffic and proxy the traffic to the backend web servers using IPv4 addresses in subnet_lb subnet. This allows, IPv6 clients outside the Google cloud to connect to our cloud instances. The loadbalancer was created using the template provided on Github - [Content Based Load Balancing in Google Cloud].

### AWS Subnets
 In AWS, we will create one VPC, vpc-demo with CIDR range 10.0.0.0/16. We will also create one private subnet, vpc-private-subnet with IP address range 10.0.1.0/24. The private subnet contains one instance tagged vpc-instance. This represents our Oracle DB in the scenario diagram but is just a Linux instance we are testing ICMP reachability to.

### IPsec VPN Connection
The IPsec VPN tunnels has the following features:
- IKEv1
-  Pre-shared keys for authentication
- Route-based VPN
-  Static routing
-  Single VPN headend on GCP connecting to two VPN headends on AWS

### Deploying This Example on Terraform
There are 2 environments *prod* and *stage*. This example only uses *stage*.

1. Create an external IP address on GCP and save the value as *vpn_ip_address* in your aws-vpn/terraform.tfvars file or equivalent environment variable.

2. Run the AWS Terraform script in the directory *../gcp-aws-vpn/aws-vpn*. This will create output variables for the AWS VPN tunnel headend IP addresses that will be used as terraform_remote_state input for configuring the GCP IPsec tunnel.
    ```sh
    terraform plan
    terraform apply
    ```

3. Run the GCP Terraform script in the directory *../gcp-aws-vpn/gcp-ipv6_lb-vpn*.
    ```sh
    terraform plan
    terraform apply
    ```

4. Grab the IPv6 address of the GCP loadbalancer and paste it into a web browser to view the *www* backend web server content. Add *"/video"* to the URL to view the *www-video* backend web server content.

5. SSH into the GCP bastion using bastion instance public IP address

6. From the bastion server, SSH into the *www* and *www-video* backend server instances.

7. Test the ping connectivity from the web servers to the AWS instance. You should not be able to ping from the bastion instance to the AWS instance because of the security rules in place.

[diagram]: http://storage.googleapis.com/cloud-network-things/multi-cloud/ipsec/gcp-aws/aws-gcp-vpn.PNG
[Content Based Load Balancing in Google Cloud]: https://github.com/terraform-providers/terraform-provider-google/tree/master/examples/content-based-load-balancing
