variable "name_prefix" {
  type = string
}

variable "domain" {
  type = string
}

variable "gcp_project_id" {
  type = string
}

variable "domain_zone_name" {
  type    = string
  default = null
}

variable "cors_allowed_origins" {
  type    = list(string)
  default = null
}

variable "cors_allowed_methods_additional" {
  type    = list(string)
  default = null
}

variable "bucket_location" {
  type = string
}

variable "gcp_api_services_to_keep_upon_destroy" {
  type    = list(string)
  default = []
}

variable "redirects" {
  type    = list(string)
  default = ["www"]
}
