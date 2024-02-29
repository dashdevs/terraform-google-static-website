# terraform-google-static-website

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_cloudflare) | >= 1.6.3 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.17.0 |

## Resources

| Name | Type | Description|
|------|------|------------|
| [google_compute_backend_bucket.website](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_backend_bucket) | resource | Bucket to store website |
| [google_compute_global_address.website](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_address) | resource | Reserve an external IP |
| [google_compute_global_forwarding_rule.default](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_global_forwarding_rule) | resource | GCP forwarding rule |
| [google_compute_managed_ssl_certificate.website](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_managed_ssl_certificate) | resource | Create HTTPS certificate |
| [google_compute_target_https_proxy.website](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_target_https_proxy) | resource | GCP target proxy |
| [google_compute_url_map.website](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/compute_url_map) | resource | GCP URL MAP |
| [google_project_service.project](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/project_service) | resource | Enable GCP APIs for deployment |
| [google_storage_bucket.website](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket) | resource | Add the bucket as a CDN backend |
| [google_storage_default_object_access_control.website_read](https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_default_object_access_control) | resource | Make new objects in bucket public |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_gcp_api_services_list"></a> [gcp\_api\_services\_list](#input\_gcp\_api\_services\_list) | list of GCP API services to turn on | `list(string)` | `[""]` | no |
| <a name="input_gcp_project_id"></a> [gcp\_project\_id](#input\_gcp\_project\_id) | ID of the GCP project | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix for the resources | `string` | n/a | yes |
| <a name="input_website_domain"></a> [website\_domain](#input\_website\_domain) | Domain name of the website | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lb_ip_address"></a> [lb\_ip\_address](#output\_lb\_ip\_address) | IP address of the website Load Balancer |
