# root module - modules.tf
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}
data "oci_core_images" "centos_image" {
  compartment_id = var.tenancy_ocid
  operating_system = "CentOS"
  operating_system_version = 7
}
module "bastion" {
  source = "./bastion"
  compartment_ocid = var.compartment_ocid
  vcn_ocid = oci_core_virtual_network.vcn.id
  vcn_igw_ocid = oci_core_internet_gateway.igw.id
  vcn_cidr = oci_core_virtual_network.vcn.cidr_block
  vcn_subnet_cidr = "10.0.1.0/27"
  ads = data.oci_identity_availability_domains.ads.availability_domains[*].name
  image_ocid = data.oci_core_images.centos_image.images[0].id
}
module "workers" {
  source = "./workers"
  compartment_ocid = var.compartment_ocid
  vcn_ocid = oci_core_virtual_network.vcn.id
  vcn_nat_ocid = oci_core_nat_gateway.natgw.id
  vcn_cidr = oci_core_virtual_network.vcn.cidr_block
  vcn_subnet_cidr = "10.0.1.128/27"
  ads = data.oci_identity_availability_domains.ads.availability_domains[*].name
  image_ocid = data.oci_core_images.centos_image.images[0].id
}
output "bastion_public_ip" { value = "${module.bastion.bastion_public_ip}" }
output "worker_public_ip" { value = "${module.workers.worker_private_ip}" }
output "image_name" { value = "${data.oci_core_images.compute_image.images[0].display_name}" }
