# GCE VM Instance with Public IP

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| image | OS image | string | `"debian-cloud/debian-9"` | no |
| machine\_type | machine type | string | `"f1-micro"` | no |
| metadata\_startup\_script | metadata startup script | string | n/a | yes |
| name | vm instance name | string | n/a | yes |
| network | The VPC where the instance will be created | string | `"default"` | no |
| subnetwork | The VPC subnetwork where the instance will be created | string | `"default"` | no |
| subnetwork\_project | the project that the vm's subnet belongs to | string | n/a | yes |
| tags | network tags | list | n/a | yes |
| zone | GCE zone | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| instance\_private\_ip | private ip of the instance |
| instance\_public\_ip | public ip of the instance |
