# GCE VM instance with private IP

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| image | OS image | string | `"debian-cloud/debian-9"` | no |
| machine\_type | machine type | string | `"f1-micro"` | no |
| metadata\_startup\_script | metadata startup script | string | n/a | yes |
| name | vm instance name | string | n/a | yes |
| network | The VPC where the instance will be created | string | `"default"` | no |
| project\_id | project id where resources belong to | string | n/a | yes |
| subnetwork | The VPC subnetwork where the instance will be created | string | `"default"` | no |
| subnetwork\_project | the project that the vm's subnet belongs to | string | n/a | yes |
| tags | network tags | list | n/a | yes |
| zone | GCE zone | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| instance | instance resource complete with all attributes |


## Example Usage

```hcl
module "vm" {
  source     = "../modules/gce-public"
  name       = "super-vm"
  zone       = "europe-west1-b"
  subnetwork = var.subnet
}
```
