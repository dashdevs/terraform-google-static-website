variable "name_prefix" {
  type = string
}

variable "website_domain" {
  type = string
}

variable "gcp_project_id" {
  type    = string
  default = null
}

variable "gcp_api_services_list" {
  type    = list(string)
  default = ["storage.googleapis.com", "compute.googleapis.com"]
}
