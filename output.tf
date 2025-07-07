output "vm_external_ip" {
  value = google_compute_instance.vm.network_interface[0].access_config[0].nat_ip
}

output "state_bucket" {
  value = google_storage_bucket.tf_state.name
}

output "vpc_name" {
  value = google_compute_network.vpc.name
}
