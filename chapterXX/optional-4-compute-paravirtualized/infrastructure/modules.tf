### Modules

module "web" {
  source = "web"
  compartment_ocid = "${var.compartment_ocid}"
  vcn_ocid = "${oci_core_virtual_network.vcn.id}"
  vcn_igw_ocid = "${oci_core_internet_gateway.igw.id}"
  vcn_cidr = "${oci_core_virtual_network.vcn.cidr_block}"
  vcn_subnet_cidr = "10.0.3.0/27"
  ad = "${local.ad}"
  image_ocid = "${local.image_ocid}"
}

### ADs and Compute Image evaluation
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

output "Image name " { value = "${data.oci_core_images.compute_image.images.0.display_name}" }
output "Web VM public IP" { value = "${module.web.web_public_ip}" }
