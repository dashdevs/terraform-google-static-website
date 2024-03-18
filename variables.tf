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

variable "gcp_api_services_list" {
  type    = list(string)
  default = []
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
  type = string
}

variable "cors_allowed_methods_additional" {
  type    = string
  default = null
}
