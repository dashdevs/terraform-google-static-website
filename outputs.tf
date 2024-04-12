# output "website_ip_address" {
#   value = google_compute_global_address.website.address
# }

# output "test1" {
#   value = local.gcp_existing_api_storage
# }

# output "test2" {
#   value = local.gcp_existing_api_compute
# }

output "gcp_dependend_api_services" {
  value = local.gcp_dependend_api_services
}
