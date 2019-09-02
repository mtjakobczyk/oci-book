# root module - provider.tf
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}
data "oci_core_images" "centos_image" {
  compartment_id = var.compartment_ocid
  operating_system = "CentOS"
  operating_system_version = 7
}
output "image_name" { value = data.oci_core_images.centos_image.images[0].display_name }
