locals {
  gcp_required_api_services = merge(
    {
      "storage.googleapis.com"              = contains(var.gcp_api_services_to_keep_upon_destroy, "storage.googleapis.com")
      "compute.googleapis.com"              = contains(var.gcp_api_services_to_keep_upon_destroy, "compute.googleapis.com")
      "cloudresourcemanager.googleapis.com" = contains(var.gcp_api_services_to_keep_upon_destroy, "cloudresourcemanager.googleapis.com")
    },
    var.domain_zone_name != null ? {
      "dns.googleapis.com" = contains(var.gcp_api_services_to_keep_upon_destroy, "dns.googleapis.com")
    } : {}
  )

  gcp_dependend_api_services = can(google_project_service.service) ? google_project_service.service[*] : []
  cors_allowed_default       = ["GET", "HEAD"]
  create_cors_configuration  = var.cors_allowed_origins != null ? true : false
  cors_allowed_methods       = var.cors_allowed_methods_additional != null ? concat(local.cors_allowed_default, var.cors_allowed_methods_additional) : local.cors_allowed_default

  redirects = [for subdomain in var.subdomain_redirects : "${subdomain}.${var.domain}"]
}

resource "google_project_service" "service" {
  for_each = local.gcp_required_api_services
  project  = var.gcp_project_id
  service  = each.key

  timeouts {
    create = "10m"
    update = "10m"
  }

  disable_dependent_services = true
  disable_on_destroy         = each.value
}

resource "google_storage_bucket" "static_content" {
  name     = var.name_prefix
  location = var.bucket_location
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

  depends_on = [local.gcp_dependend_api_services]
}

resource "google_compute_global_address" "lb_ip" {
  name = "${var.name_prefix}-lb-ip"

  depends_on = [local.gcp_dependend_api_services]
}

resource "google_storage_default_object_access_control" "reader_access" {
  bucket = google_storage_bucket.static_content.name
  role   = "READER"
  entity = "allUsers"

  depends_on = [local.gcp_dependend_api_services]
}

resource "google_compute_backend_bucket" "backend_cdn" {
  name        = "${var.name_prefix}-backend"
  description = "Contains files needed by the website"
  bucket_name = google_storage_bucket.static_content.name
  enable_cdn  = true

  depends_on = [local.gcp_dependend_api_services]
}

resource "google_compute_managed_ssl_certificate" "domain_ssl" {
  name = "${var.name_prefix}-ssl-certificate"
  managed {
    domains = [var.domain]
  }

  depends_on = [local.gcp_dependend_api_services]
}

resource "google_compute_url_map" "https_map" {
  name = "${var.name_prefix}-https-url-map"
  default_url_redirect {
    host_redirect = google_compute_backend_bucket.backend_cdn.self_link
    strip_query   = false
  }
  host_rule {
    path_matcher = "primary"
    hosts        = [var.domain]
  }
  path_matcher {
    name            = "primary"
    default_service = google_compute_backend_bucket.backend_cdn.self_link
  }
  dynamic "host_rule" {
    for_each = var.subdomain_redirects != null ? [1] : []
    content {
      path_matcher = "secondary"
      hosts        = toset(local.redirects)
    }
  }
  dynamic "path_matcher" {
    for_each = var.subdomain_redirects != null ? [1] : []
    content {
      name = "secondary"
      default_url_redirect {
        host_redirect = var.domain
        strip_query   = false
      }
    }
  }
}

resource "google_compute_url_map" "http_map" {
  name = "http-redirect"

  default_url_redirect {
    redirect_response_code = "MOVED_PERMANENTLY_DEFAULT" // 301 redirect
    strip_query            = false
    https_redirect         = true
  }
}

resource "google_compute_target_https_proxy" "https_target" {
  name             = "${var.name_prefix}-https-proxy"
  url_map          = google_compute_url_map.https_map.self_link
  ssl_certificates = [google_compute_managed_ssl_certificate.domain_ssl.self_link]

  depends_on = [local.gcp_dependend_api_services]
}

resource "google_compute_target_http_proxy" "http_target" {
  name    = "${var.name_prefix}-http-proxy"
  url_map = google_compute_url_map.http_map.self_link
}


resource "google_compute_global_forwarding_rule" "https_rule" {
  name                  = "${var.name_prefix}-https-rule"
  load_balancing_scheme = "EXTERNAL"
  ip_address            = google_compute_global_address.lb_ip.address
  ip_protocol           = "TCP"
  port_range            = "443"
  target                = google_compute_target_https_proxy.https_target.self_link

  depends_on = [local.gcp_dependend_api_services]
}

resource "google_compute_global_forwarding_rule" "http_rule" {
  name        = "${var.name_prefix}-http-rule"
  ip_address  = google_compute_global_address.lb_ip.address
  ip_protocol = "TCP"
  port_range  = "80"
  target      = google_compute_target_http_proxy.http_target.self_link

  depends_on = [local.gcp_dependend_api_services]
}

resource "google_dns_record_set" "record" {
  count = var.domain_zone_name != null ? 1 : 0

  project      = var.gcp_project_id
  name         = "${var.domain}."
  managed_zone = var.domain_zone_name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.lb_ip.address]
}

resource "google_dns_record_set" "www_record" {
  count = var.domain_zone_name != null && var.subdomain_redirects != null ? 1 : 0

  project      = var.gcp_project_id
  name         = "www.${var.domain}."
  managed_zone = var.domain_zone_name
  type         = "A"
  ttl          = 300
  rrdatas      = [google_compute_global_address.lb_ip.address]
}
