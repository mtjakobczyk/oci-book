# root module - vars.tf
## Provider-specific Variables
variable "tenancy_ocid" {}
variable "user_ocid" {}
variable "region" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "private_key_password" {}

## Project-specific input variables
variable "compartment_ocid" {}

# root module variables
variable "vcn_cidr" {
  type = string
  default = "10.1.0.0/16"
}
