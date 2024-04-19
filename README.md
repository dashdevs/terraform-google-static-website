# terraform-google-static-website
## Usage

**IMPORTANT:** We do not pin modules to versions in our examples because of the
difficulty of keeping the versions in the documentation in sync with the latest released versions.
We highly recommend that in your code you pin the version to the exact version you are
using so that your infrastructure remains stable, and update versions in a
systematic way so that they do not catch you by surprise.

### Example usage for website module:
```
module "gcp_website" {
  source                = "dashdevs/static-website/gcp"
  bucket_location       = "EU"
  name_prefix           = gcp-example
  domain                = gcp.example.com
  domain_zone_name      = google_dns_managed_zone.example.name
}
```

## Requirements
## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 3.34 |
| <a name="provider_google"></a> [google](#provider\_google) | >= 5.17.0 |


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix for the resources | `string` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_website\_domain) | Domain name of the website | `string` | n/a | yes |
| <a name="input_gcp_project_id"></a> [gcp\_project\_id](#input\_gcp\_project\_id) | ID of the GCP project | `string` | `null` | yes |
| <a name="input_bucket_location"></a> [bucket_location](#input\_bucket\_location) | Variable for the location of the bucket (https://cloud.google.com/storage/docs/locations)| `list(string)` | null | no |
| <a name="input_gcp_api_services_to_keep_upon_destroy"></a> [gcp\_api\_services\_to_keep_upon_destroy](#input\_gcp\_api\_services\_to_keep_upon_destroy) | List of GCP API services that should not be disabled during destruction . Available values in list are `storage.googleapis.com`, `compute.googleapis.com`, `cloudresourcemanager.googleapis.com`, `dns.googleapis.com` (https://console.cloud.google.com/apis/library)| `list(string)` | `[]` | no |
| <a name="input_domain_zone_name"></a> [domain\_zone\_name](#input\_domain\_zone\_name) | Domain zone name for CNAME record, if not empty then record will be created | `string` | `null` | no |
| <a name="input_cors"></a> [cors_allowed_origins](#input\_cors_\_allowed_origins) | Used to declare domains from which the site will be accessed as a storage of static resources | `list(string)` | null | no |
| <a name="input_cors"></a> [cors_allowed_methods_additional](#input\_cors\_allowed_methods_additional) |List of additional CORS methods in addition to `GET` and `HEAD` | `list(string)` | null | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_website_lb_ip_address"></a> [website\_lb\_ip\_address](#output\_website\_lb\_ip\_address) | IP address of the website Load Balancer to attach to a different DNS |
