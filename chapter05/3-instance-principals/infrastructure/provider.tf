# root module - provider.tf
provider "oci" {
  tenancy_ocid = var.tenancy_ocid
  user_ocid = var.user_ocid
  region = var.region
  fingerprint = var.fingerprint
  private_key_path = var.private_key_path
  private_key_password = var.private_key_password
}
