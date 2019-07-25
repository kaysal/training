
# local variables

locals {
  onprem = {
    prefix      = "lab2-onprem-"
    region      = "europe-west1"
    asn         = 65001
    router_vti1 = "169.254.100.1"
    router_vti2 = "169.254.100.5"
    subnet1     = "onprem-subnet1"
    vm_ip       = "172.16.1.2"
    unbound_ip  = "172.16.1.99"
  }

  cloud = {
    prefix      = "lab2-cloud-"
    region      = "europe-west1"
    asn         = 65002
    router_vti1 = "169.254.100.2"
    router_vti2 = "169.254.100.6"
    subnet1     = "cloud-subnet1"
    proxy_ip    = "10.10.1.100"
    dns_nat_ip  = "192.168.1.1"
  }
}
