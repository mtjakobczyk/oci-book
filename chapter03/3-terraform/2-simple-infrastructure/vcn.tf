resource "oci_core_virtual_network" "web_vcn" {
  compartment_id = "${var.compartment_ocid}"
  cidr_block = "10.1.1.0/24"
  display_name = "web-vcn"
  dns_label = "vcn"
}
resource "oci_core_internet_gateway" "web_igw" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.web_vcn.id}"
}
