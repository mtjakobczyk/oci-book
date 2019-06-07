# devmachine / vcn.tf
resource "oci_core_route_table" "dev_rt" {
  compartment_id = var.compartment_ocid
  vcn_id = var.vcn_ocid
  route_rules {
    network_entity_id = var.vcn_igw_ocid
    destination_type = "CIDR_BLOCK"
    destination = "0.0.0.0/0"
  }
  display_name = "dev-rt"
}
resource "oci_core_security_list" "dev_sl" {
  compartment_id = var.compartment_ocid
  vcn_id = var.vcn_ocid
  egress_security_rules {
    stateless="true"
    destination=var.vcn_cidr
    protocol="all"
  }
  egress_security_rules {
    stateless="false"
    destination="0.0.0.0/0"
    protocol="all"
  }
  ingress_security_rules {
    stateless="true"
    source="${var.vcn_cidr}"
    protocol="all"
  }
  ingress_security_rules {
    stateless="false"
    source="0.0.0.0/0"
    protocol="6"
    tcp_options {
      min=22
      max=22 
     }
  }
  display_name = "dev-sl"
}
resource "oci_core_subnet" "dev_net" {
  compartment_id = "${var.compartment_ocid}"
  vcn_id = "${var.vcn_ocid}"
  display_name = "dev-net"
  cidr_block = "${var.vcn_subnet_cidr}"
  route_table_id = "${oci_core_route_table.dev_rt.id}"
  security_list_ids = [ "${oci_core_security_list.dev_sl.id}" ]
  prohibit_public_ip_on_vnic = "false"
  dns_label = "dev"
}
