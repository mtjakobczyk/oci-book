# app module - vcn.tf
resource "oci_core_route_table" "app_rt" {
  compartment_id = var.compartment_ocid
  vcn_id = var.vcn_ocid
  route_rules {
    destination_type = "CIDR_BLOCK"
    destination = "0.0.0.0/0"
    network_entity_id = var.vcn_igw_ocid
  }
  display_name = "app-rt"
}
resource "oci_core_security_list" "app_sl" {
  compartment_id = var.compartment_ocid
  vcn_id = var.vcn_ocid
  egress_security_rules {
    stateless="false"
    destination="0.0.0.0/0"
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
  display_name = "app-sl"
}
# subnets
resource "oci_core_subnet" "app_subnet" {
  compartment_id = var.compartment_ocid
  vcn_id = var.vcn_ocid
  display_name = "app-subnet"
  availability_domain = var.ads[1]
  cidr_block = var.vcn_subnet_cidr
  route_table_id = oci_core_route_table.app_rt.id
  security_list_ids = [ oci_core_security_list.app_sl.id ]
  prohibit_public_ip_on_vnic = "false"
  dns_label = "appnet"
}
