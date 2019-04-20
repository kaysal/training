# GKE cluster

GKE cluster creation.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| name | Cluster name. | string | n/a | yes |
| network | Cluster network. | string | n/a | yes |
| pods\_range | Name of the alias IP range for pods. | string | n/a | yes |
| project\_id | Cluster project. | string | n/a | yes |
| region | Cluster region. | string | n/a | yes |
| services\_range | Name of the alias IP range for services. | string | n/a | yes |
| subnetwork | Cluster subnetwork. | string | n/a | yes |
| zones | Cluster zones. | list | n/a | yes |
| cluster\_labels | Labels to be attached to the cluster. | map | `<map>` | no |
| maintenance\_window\_utc | Maintenance window of the cluster itself, in UTC time. | string | `"04:00"` | no |
| min\_master\_version | Minimum version for master. | string | `"1.10.5-gke.3"` | no |
| network\_policy | Enable network policy. | string | `"false"` | no |
| network\_tags | Network tags to be attached to the cluster VMs, for firewall rules. | list | `<list>` | no |
| node\_count | Initial node count. | string | `"1"` | no |
| node\_taints | Taints applied to default nodes. List of maps. | list | `<list>` | no |
| oauth\_scopes | Scopes for the nodes service account. | list | `<list>` | no |
| service\_account | The service account to use for the default nodes in the cluster. | string | `"default"` | no |

## Outputs

| Name | Description |
|------|-------------|
| cluster\_ca\_certificate |  |
| endpoint |  |
| master\_version |  |
| name |  |
| region |  |
| unique\_id |  |

## Example Usage

TODO: add example here

## Sample Output

TODO: add sample output here

