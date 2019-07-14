
# local variables

locals {
  onprem = {
    prefix      = "onprem-"
    region      = "europe-west1"
    asn         = 65001
    router_vti1 = "169.254.100.1"
    router_vti2 = "169.254.100.5"
    subnet1     = "onprem-subnet1"
  }

  hub = {
    prefix      = "hub-"
    region      = "europe-west1"
    asn         = 65002
    router_vti1 = "169.254.100.2"
    router_vti2 = "169.254.100.6"
    subnet1     = "hub-subnet1"
  }
}
