resource "google_project_service" "project" {
  for_each = local.gcp_api_services
  project  = var.google_project_id
  service  = each.key

  timeouts {
    create = "10m"
    update = "10m"
  }

  disable_dependent_services = true
}

# Bucket to store website
resource "google_storage_bucket" "website" {
  name     = var.name_prefix
  location = "US"
  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }
}

# Make new objects public
resource "google_storage_default_object_access_control" "website_read" {
  bucket = google_storage_bucket.website.name
  role   = "READER"
  entity = "allUsers"
}

# Reserve an external IP
resource "google_compute_global_address" "website" {
  name = "${var.name_prefix}-lb-ip"
}

# Add the bucket as a CDN backend
resource "google_compute_backend_bucket" "website" {
  name        = "${var.name_prefix}-backend"
  description = "Contains files needed by the website"
  bucket_name = google_storage_bucket.website.name
  enable_cdn  = true
}

# Create HTTPS certificate
resource "google_compute_managed_ssl_certificate" "website" {
  name = "${var.name_prefix}-cert"
  managed {
    domains = [var.website_domain]
  }
}

# GCP URL MAP
resource "google_compute_url_map" "website" {
  name            = "${var.name_prefix}-url-map"
  default_service = google_compute_backend_bucket.website.self_link
}

# GCP target proxy
resource "google_compute_target_https_proxy" "website" {
  name             = "${var.name_prefix}-target-proxy"
  url_map          = google_compute_url_map.website.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.website.self_link]
}

# GCP forwarding rule
resource "google_compute_global_forwarding_rule" "default" {
  name                  = "${var.name_prefix}-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.website.address
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.website.self_link
}
