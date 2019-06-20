# root module - vars.tf
resource "oci_core_virtual_network" "vcn" {
  compartment_id = var.compartment_ocid
  cidr_block = var.vcn_cidr
  display_name = "solution-C-vcn"
  dns_label = "c"
}
resource "oci_core_internet_gateway" "igw" {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_virtual_network.vcn.id
  display_name = "igw"
}
resource "oci_core_route_table" "rt" {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_virtual_network.vcn.id
  route_rules {
    network_entity_id = oci_core_internet_gateway.igw.id
    destination_type = "CIDR_BLOCK"
    destination = "0.0.0.0/0"
  }
  display_name = "rt"
}
resource "oci_core_security_list" "sl" {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_virtual_network.vcn.id
  egress_security_rules {
    stateless=false
    destination="0.0.0.0/0"
    protocol="all"
  }
  ingress_security_rules {
    stateless=false
    source="0.0.0.0/0"
    protocol="6"
    tcp_options {
      min=22
      max=22
    }
  }
  display_name = "sl"
}
resource "oci_core_subnet" "net" {
  compartment_id = var.compartment_ocid
  vcn_id = oci_core_virtual_network.vcn.id
  display_name = "net"
  cidr_block = var.vcn_subnet_cidr
  route_table_id = oci_core_route_table.rt.id
  security_list_ids = [ oci_core_security_list.sl.id ]
  prohibit_public_ip_on_vnic = false
  dns_label = "net"
}
