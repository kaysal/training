## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| image | OS image | string | `"debian-cloud/debian-9"` | no |
| machine\_type | machine type | string | `"f1-micro"` | no |
| metadata\_startup\_script | metadata startup script | string | n/a | yes |
| name | vm instance host name | string | n/a | yes |
| network | The VPC where the instance will be created | string | `"default"` | no |
| project | Project where the instance will be created | string | n/a | yes |
| subnetwork | The VPC subnetwork where the instance will be created | string | `"default"` | no |
| subnetwork\_project | Project where the subnetwork will be created | string | `"null"` | no |
| zone | vm instance zone | string | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| instance | instance resource with all attributes |
