# web module - vcn.tf
resource "oci_core_route_table" "web_rt" {
  compartment_id = var.compartment_ocid
  vcn_id = var.vcn_ocid
  route_rules {
    destination_type = "CIDR_BLOCK"
    destination = "0.0.0.0/0"
    network_entity_id = var.vcn_igw_ocid
  }
  display_name = "web-rt"
}
resource "oci_core_security_list" "web_sl" {
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
  ingress_security_rules {
    stateless="false"
    source="0.0.0.0/0"
    protocol="6"
    tcp_options {
      min=80
      max=80
    }
  }
  display_name = "web-sl"
}
# subnets
resource "oci_core_subnet" "web_subnet" {
  compartment_id = var.compartment_ocid
  vcn_id = var.vcn_ocid
  display_name = "web-subnet"
  availability_domain = var.ads[0]
  cidr_block = var.vcn_subnet_cidr
  route_table_id = oci_core_route_table.web_rt.id
  security_list_ids = [ oci_core_security_list.web_sl.id ]
  prohibit_public_ip_on_vnic = "false"
  dns_label = "webnet"
}
