output "vpc" {
  value = {
    onprem = module.onprem_vpc,
    cloud  = module.cloud_vpc
  }
}
