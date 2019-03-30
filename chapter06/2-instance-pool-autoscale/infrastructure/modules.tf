### Modules

module "bastion" {
  source = "bastion"
  compartment_ocid = "${var.compartment_ocid}"
  vcn_ocid = "${oci_core_virtual_network.vcn.id}"
  vcn_igw_ocid = "${oci_core_internet_gateway.igw.id}"
  vcn_cidr = "${oci_core_virtual_network.vcn.cidr_block}"
  vcn_subnet_cidr = "10.0.1.0/27"
  ads = "${local.ads}"
  image_ocid = "${local.image_ocid}"
}

module "workers" {
  source = "workers"
  compartment_ocid = "${var.compartment_ocid}"
  vcn_ocid = "${oci_core_virtual_network.vcn.id}"
  vcn_nat_ocid = "${oci_core_nat_gateway.natgw.id}"
  vcn_cidr = "${oci_core_virtual_network.vcn.cidr_block}"
  vcn_subnet_cidrs = [ "10.0.1.128/27", "10.0.1.160/27", "10.0.1.192/27" ]
  ads = "${local.ads}"
  image_ocid = "${local.image_ocid}"
  pool_target_size = 2
}

### ADs and Compute Image evaluation
locals {
  ads = [
    "${lookup(data.oci_identity_availability_domains.ads.availability_domains[0], "name")}",
    "${lookup(data.oci_identity_availability_domains.ads.availability_domains[1], "name")}",
    "${lookup(data.oci_identity_availability_domains.ads.availability_domains[2], "name")}"
  ]
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
output "Bastion public IP" { value = "${module.bastion.bastion_public_ip}" }
