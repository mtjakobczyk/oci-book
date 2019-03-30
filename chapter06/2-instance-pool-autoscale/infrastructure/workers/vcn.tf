# workers / vcn.tf
resource "oci_core_route_table" "workers_rt" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${var.vcn_ocid}"
  route_rules {
    network_entity_id = "${var.vcn_nat_ocid}"
    destination_type = "CIDR_BLOCK"
    destination = "0.0.0.0/0"
  }
  display_name = "workers-rt"
}
resource "oci_core_security_list" "workers_sl" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${var.vcn_ocid}"
  egress_security_rules = [
    { stateless="true" destination="${var.vcn_cidr}" protocol="all" },
    { stateless="false" destination="0.0.0.0/0" protocol="all" }
  ]
  ingress_security_rules = [
    { stateless="true" source="${var.vcn_cidr}" protocol="all" }
  ]
  display_name = "workers-sl"
}
resource "oci_core_subnet" "workers_ad1_net" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${var.vcn_ocid}"
  display_name = "workers-ad1-net"
  availability_domain = "${var.ads[0]}"
  cidr_block = "${var.vcn_subnet_cidrs[0]}"
  route_table_id = "${oci_core_route_table.workers_rt.id}"
  security_list_ids = [ "${oci_core_security_list.workers_sl.id}" ]
  prohibit_public_ip_on_vnic = "true"
  dns_label = "w1"
}
resource "oci_core_subnet" "workers_ad2_net" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${var.vcn_ocid}"
  display_name = "workers-ad2-net"
  availability_domain = "${var.ads[1]}"
  cidr_block = "${var.vcn_subnet_cidrs[1]}"
  route_table_id = "${oci_core_route_table.workers_rt.id}"
  security_list_ids = [ "${oci_core_security_list.workers_sl.id}" ]
  prohibit_public_ip_on_vnic = "true"
  dns_label = "w2"
}
