# root module - vcn.tf
resource "oci_core_virtual_network" "vcn" {
  compartment_id = var.compartment_ocid
  cidr_block = var.vcn_cidr
  display_name = "bastionnat-vcn"
  dns_label = "a"
}
resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_virtual_network.vcn.id
  display_name = "internet-gateway"
}
resource "oci_core_nat_gateway" "natgw" {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_virtual_network.vcn.id
  display_name = "nat-gateway"
  block_traffic = false
}
