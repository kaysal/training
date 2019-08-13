## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| autoscaler\_cooldown\_period | autoscaler-cooldown-period | string | `"45"` | no |
| autoscaler\_cpu\_utilization\_target | autoscaler cpu utilization target | string | `"0.8"` | no |
| autoscaler\_max\_replicas | autoscaler maximum replicas | string | `"3"` | no |
| autoscaler\_min\_replicas | autoscaler minimum replicas | string | `"1"` | no |
| backend\_service\_name | backend service name | string | `"backend-service"` | no |
| forwarding\_rule\_name | forwarding rule name | string | `"proxy"` | no |
| health\_check\_name | health check name | string | n/a | yes |
| image | OS image | string | `"debian-cloud/debian-9"` | no |
| instance\_group\_name | instance group name | string | n/a | yes |
| instance\_template\_name | instance template name | string | n/a | yes |
| machine\_type | machine type | string | `"n1-standard-1"` | no |
| metadata\_startup\_script | metadata startup script | string | n/a | yes |
| named\_port | named port map | map | `<map>` | no |
| network | VPC name | string | `"default"` | no |
| prefix | Prefix appended before resource names | string | n/a | yes |
| project\_id | Project ID | string | n/a | yes |
| region | GCP region | string | n/a | yes |
| subnetwork | Subnetwork | string | `"default"` | no |
| subnetwork\_project | Subnetwork project | string | n/a | no |
| tags | network tags | list | `<list>` | no |
| target\_proxy\_name | target proxy name | string | `"proxy"` | no |
| target\_size | instance group zone | string | `"1"` | no |
| url\_map\_name | url map name | string | `"url-map"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cdn\_ip |  |
