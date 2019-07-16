# GCE VM instance with public IP

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| image | OS image | string | `"debian-cloud/debian-9"` | no |
| machine\_type | machine type | string | `"f1-micro"` | no |
| metadata\_startup\_script | metadata startup script | string | n/a | no |
| name | vm instance name | string | n/a | yes |
| nat\_ip | The IP address that will be 1:1 mapped to the instance's network ip | string | n/a | no |
| network | The VPC where the instance will be created | string | `"default"` | no |
| network\_ip | The private IP address to assign to the instance | string | n/a | no |
| network\_tier | The network tier of the VM | string | `"STANDARD"` | no |
| project\_id | project id where resources belong to | string | n/a | yes |
| public\_ptr\_domain\_name | The DNS domain name for the public PTR record | string | n/a | no |
| service\_account\_email | service account to attach to the instance | string | n/a | no |
| subnetwork | The VPC subnetwork where the instance will be created | string | `"default"` | yes |
| subnetwork\_project | the project that the vm's subnet belongs to | string | n/a | no |
| tags | network tags | list | n/a | yes |
| zone | GCE zone | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| instance | private ip of the instance |


## Example Usage

```hcl
module "vm" {
  source     = "../modules/gce-public"
  name       = "super-vm"
  zone       = "europe-west1-b"
  subnetwork = var.subnet
}
```
