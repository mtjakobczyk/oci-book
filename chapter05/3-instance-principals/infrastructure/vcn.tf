resource "oci_core_virtual_network" "app_vcn" {
  compartment_id = "${var.compartment_ocid}"
  cidr_block = "10.1.1.0/24"
  display_name = "app-vcn"
  dns_label = "vcn"
}
resource "oci_core_internet_gateway" "app_igw" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${oci_core_virtual_network.app_vcn.id}"
}
