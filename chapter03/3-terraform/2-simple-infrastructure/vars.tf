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
