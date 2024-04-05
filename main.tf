locals {
  gcp_api_services_lists    = can(google_project_service.project) ? google_project_service.project[*] : []
  cors_allowed_default      = ["GET", "HEAD"]
  сreate_cors_configuration = var.cors_allowed_origins != null ? true : false
  cors_allowed_methods      = var.cors_allowed_methods_additional != null ? concat(local.cors_allowed_default, var.cors_allowed_methods_additional) : local.cors_allowed_default
}

resource "google_project_service" "project" {
  for_each = toset(var.gcp_api_services_list)
  project  = var.gcp_project_id
  service  = each.key

  timeouts {
    create = "10m"
    update = "10m"
  }

  disable_dependent_services = true
}

resource "google_storage_bucket" "website" {
  name     = var.name_prefix
  location = "US"
  website {
    main_page_suffix = "index.html"
    not_found_page   = "index.html"
  }
  dynamic "cors" {
    for_each = local.сreate_cors_configuration ? [1] : []
    content {
      origin          = var.cors_allowed_origins
      method          = local.cors_allowed_methods
      response_header = ["*"]
      max_age_seconds = 3600
    }
  }

  depends_on = [local.gcp_api_services_lists]
}

resource "google_compute_global_address" "website" {
  name = "${var.name_prefix}-lb-ip"
}

resource "google_storage_default_object_access_control" "website" {
  bucket = google_storage_bucket.website.name
  role   = "OWNER"
  entity = "allUsers"

  depends_on = [local.gcp_api_services_lists]
}

resource "google_compute_backend_bucket" "website" {
  name        = "${var.name_prefix}-backend"
  description = "Contains files needed by the website"
  bucket_name = google_storage_bucket.website.name
  enable_cdn  = true

  depends_on = [local.gcp_api_services_lists]
}

resource "google_compute_managed_ssl_certificate" "website" {
  name = "${var.name_prefix}-cert"
  managed {
    domains = [var.domain]
  }

  depends_on = [local.gcp_api_services_lists]
}

resource "google_compute_url_map" "website" {
  name = "${var.name_prefix}-url-map"
  default_url_redirect {
    host_redirect          = google_compute_backend_bucket.website.self_link
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT" // 301 redirect
    strip_query            = false
    https_redirect         = true
  }

  depends_on = [local.gcp_api_services_lists]
}

resource "google_compute_target_https_proxy" "website" {
  name             = "${var.name_prefix}-target-proxy"
  url_map          = google_compute_url_map.website.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.website.self_link]

  depends_on = [local.gcp_api_services_lists]
}

resource "google_compute_global_forwarding_rule" "rule" {
  name                  = "${var.name_prefix}-forwarding-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.website.address
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.website.self_link

  depends_on = [local.gcp_api_services_lists]
}

resource "google_dns_record_set" "record" {
  count = var.domain_zone_name != null ? 1 : 0

  project      = var.gcp_project_id
  name         = "${var.domain}."
  managed_zone = var.domain_zone_name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.website.address]
}
