variable "name_prefix" {
  type = string
}

variable "domain" {
  type = string
}

variable "gcp_project_id" {
  type    = string
  default = null
}

variable "domain_zone_name" {
  type    = string
  default = null
}

variable "google_project_id" {
  type    = string
  default = null
}

variable "cors_allowed_origins" {
  type    = list(string)
  default = null
}

variable "cors_allowed_methods_additional" {
  type    = string
  default = null
}

variable "bucket_location" {
  type    = string
  default = "US"
}

variable "disable_created_services_on_destroy" {
  type    = string
  default = true
}

variable "region" {
  type = string
}
