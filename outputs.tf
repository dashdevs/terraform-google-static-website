output "website_lb_ip_address" {
  value = google_compute_global_address.lb_ip.address
}
