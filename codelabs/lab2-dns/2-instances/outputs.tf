output "instance" {
  value = {
    cloud = google_compute_instance.cloud_vm
  }
}

output "ip" {
  value = {
    onprem = {
      vm_ip            = local.onprem.vm_ip
      dns_proxy_fwd_ip = local.onprem.dns_proxy_fwd_ip
      dns_unbound_ip   = local.onprem.dns_unbound_ip
    }
    cloud = {
      vm_ip                 = local.cloud.vm_ip
      dns_proxy_fwd_ip      = local.cloud.dns_proxy_fwd_ip
      dns_policy_inbound_ip = local.cloud.dns_policy_inbound_ip
    }
  }
}
