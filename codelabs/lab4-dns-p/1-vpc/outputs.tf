output "vpc" {
  value = {
    onprem = module.onprem_vpc,
    cloud1 = module.cloud1_vpc
    cloud2 = module.cloud2_vpc
    cloud3 = module.cloud3_vpc
  }
}
