locals {
  ad = "${lookup(data.oci_identity_availability_domains.ads.availability_domains[0], "name")}"
  image_ocid = "${data.oci_core_images.compute_image.images.0.id}"
}
data "oci_identity_availability_domains" "ads" {
  compartment_id = "${var.tenancy_ocid}"
}
data "oci_core_images" "compute_image" {
  compartment_id = "${var.tenancy_ocid}"
  operating_system = "CentOS"
  operating_system_version = 7
}
output "1 - VM public IP" { value = "${oci_core_instance.vm.public_ip}" }
output "2 - VM image" { value = "${data.oci_core_images.compute_image.images.0.display_name}" }
