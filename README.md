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
  domain                = var.website_domain
  name_prefix           = var.name_prefix
  domain_zone_name      = "exaple-domain-zone"
  gcp_api_services_to_keep_upon_destroy = ["storage.googleapis.com"]
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
| <a name="input_gcp_api_services_to_keep_upon_destroy"></a> [gcp\_api\_services\_to_keep_upon_destroy](#input\_gcp\_api\_services\_to_keep_upon_destroy) | List of GCP API services to not disable upon destruction | `list(string)` | `[]` | no |
| <a name="input_gcp_project_id"></a> [gcp\_project\_id](#input\_gcp\_project\_id) | ID of the GCP project | `string` | `null` | no |
| <a name="input_domain_zone_name"></a> [domain\_zone\_name](#input\_domain\_zone\_name) | Domain zone name for CNAME record, if not empty then record will be created | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix for the resources | `string` | n/a | yes |
| <a name="input_domain"></a> [domain](#input\_website\_domain) | Domain name of the website | `string` | n/a | yes |
| <a name="input_cors"></a> [cors_allowed_origins](#input\_website\_domain) | Used to declare domains from which the site will be accessed as a storage of static resources | `list(string)` | null | no |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_lb_ip_address"></a> [lb\_ip\_address](#output\_lb\_ip\_address) | IP address of the website Load Balancer to attach to a different DNS |
