# GCE VM Instance with only Privte IP

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| image | os image | string | `"debian-cloud/debian-9"` | no |
| machine\_type | machine type | string | `"f1-micro"` | no |
| metadata\_startup\_script | metadata startup script | string | n/a | yes |
| name | vm instance name | string | n/a | yes |
| network | the vpc where the instance will be created | string | `"default"` | no |
| subnetwork | the vpc subnetwork where the instance will be created | string | `"default"` | no |
| subnetwork\_project | the project that the vm's subnet belongs to | string | n/a | yes |
| tags | network tags | list | n/a | yes |
| zone | gce zone | string | n/a | yes |

## outputs

| name | description |
|------|-------------|
| instance\_private\_ip | private ip of the instance |

## Example Usage

```hcl
module "vm" {
  source     = "../modules/gce-private"
  name       = "super-vm"
  zone       = "europe-west1-b"
  subnetwork = var.subnet
}
```
