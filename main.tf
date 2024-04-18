locals {
  gcp_required_api_services = ["storage.googleapis.com", "compute.googleapis.com", "cloudresourcemanager.googleapis.com"]
  # gcp_dependend_api_services = can(google_project_service.service) ? google_project_service.service[*] : []
  cors_allowed_default      = ["GET", "HEAD"]
  create_cors_configuration = var.cors_allowed_origins != null ? true : false
  cors_allowed_methods      = var.cors_allowed_methods_additional != null ? concat(local.cors_allowed_default, var.cors_allowed_methods_additional) : local.cors_allowed_default
  region_parts              = split("-", var.region)
  location_map = {
    "europe"       = "EU"
    "me"           = "EU"
    "us"           = "US"
    "northamerica" = "US"
    "asia"         = "ASIA"
  }
  bucket_location = local.location_map[local.region_parts[0]]
}

check "gcp_storage_api_service" {
  data "google_project_service" "existing_services" {
    service = "storage.googleapis.com"
  }
  assert {
    condition     = data.google_project_service.existing_services == "403"
    error_message = "It's 403"
  }
}

# resource "google_project_service" "service" {
#   for_each = toset(local.gcp_required_api_services)
#   project  = var.gcp_project_id
#   service  = each.key

#   timeouts {
#     create = "10m"
#     update = "10m"
#   }

#   disable_dependent_services = var.disable_created_services_on_destroy
#   disable_on_destroy         = var.disable_created_services_on_destroy
# }

resource "google_storage_bucket" "website" {
  name     = var.name_prefix
  location = local.bucket_location
  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }

  dynamic "cors" {
    for_each = local.create_cors_configuration ? [1] : []
    content {
      origin          = var.cors_allowed_origins
      method          = local.cors_allowed_methods
      response_header = ["*"]
      max_age_seconds = 3600
    }
  }

  # depends_on = [local.gcp_dependend_api_services]
}

# resource "google_compute_global_address" "website" {
#   name = "${var.name_prefix}-lb-ip"

#   depends_on = [local.gcp_dependend_api_services]
# }

# resource "google_storage_default_object_access_control" "website" {
#   bucket = google_storage_bucket.website.name
#   role   = "READER"
#   entity = "allUsers"

#   depends_on = [local.gcp_dependend_api_services]
# }

# resource "google_compute_backend_bucket" "website" {
#   name        = "${var.name_prefix}-backend"
#   description = "Contains files needed by the website"
#   bucket_name = google_storage_bucket.website.name
#   enable_cdn  = true

#   depends_on = [local.gcp_dependend_api_services]
# }

# resource "google_compute_managed_ssl_certificate" "website" {
#   name = "${var.name_prefix}-cert"
#   managed {
#     domains = [var.domain]
#   }

#   depends_on = [local.gcp_dependend_api_services]
# }

# resource "google_compute_url_map" "website" {
#   name = "${var.name_prefix}-url-map"
#   default_url_redirect {
#     host_redirect          = google_compute_backend_bucket.website.self_link
#     redirect_response_code = "MOVED_PERMANENTLY_DEFAULT" // 301 redirect
#     strip_query            = false
#     https_redirect         = true
#   }

#   depends_on = [local.gcp_dependend_api_services]
# }

# resource "google_compute_target_https_proxy" "website" {
#   name             = "${var.name_prefix}-target-proxy"
#   url_map          = google_compute_url_map.website.self_link
#   ssl_certificates = [google_compute_managed_ssl_certificate.website.self_link]

#   depends_on = [local.gcp_dependend_api_services]
# }

# resource "google_compute_global_forwarding_rule" "rule" {
#   name                  = "${var.name_prefix}-forwarding-rule"
#   load_balancing_scheme = "EXTERNAL"
#   ip_address            = google_compute_global_address.website.address
#   ip_protocol           = "TCP"
#   port_range            = "443"
#   target                = google_compute_target_https_proxy.website.self_link

#   depends_on = [local.gcp_dependend_api_services]
# }

# resource "google_dns_record_set" "record" {
#   count = var.domain_zone_name != null ? 1 : 0

#   project      = var.gcp_project_id
#   name         = "${var.domain}."
#   managed_zone = var.domain_zone_name
#   type         = "A"
#   ttl          = 300
#   rrdatas      = [google_compute_global_address.website.address]
# }
