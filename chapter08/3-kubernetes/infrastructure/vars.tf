# root module / variables
## Global Variables
variable "tenancy_ocid" { }
variable "user_ocid" { }
variable "fingerprint" { }
variable "private_key_path" { }
variable "private_key_password" { }
variable "region" { }

## Compartment
variable "compartment_ocid" { }

# root module variables
variable "vcn_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

### ADs and Compute Image evaluation
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}
locals {
  ads = [
    data.oci_identity_availability_domains.ads.availability_domains[0]["name"],
    data.oci_identity_availability_domains.ads.availability_domains[1]["name"],
    data.oci_identity_availability_domains.ads.availability_domains[2]["name"],
  ]
}
