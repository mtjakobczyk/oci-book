resource "oci_core_virtual_network" "vcn" {
  compartment_id = "${var.compartment_ocid}"
  cidr_block = "${var.vcn_cidr}"
  display_name = "solution-C-vcn"
  dns_label = "c"
}
resource "oci_core_internet_gateway" "igw" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.vcn.id}"
  display_name = "internet-gateway"
}
