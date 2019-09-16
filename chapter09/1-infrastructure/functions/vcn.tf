# functions module - vcn.tf
resource "oci_core_route_table" "fn_rt" {
  compartment_id = var.compartment_ocid
  vcn_id = var.vcn_ocid
  route_rules {
    network_entity_id = var.vcn_natgw_ocid
    destination_type = "CIDR_BLOCK"
    destination = "0.0.0.0/0"
  }
  display_name = "fn-rt"
}
resource "oci_core_security_list" "fn_sl" {
  compartment_id = var.compartment_ocid
  vcn_id = var.vcn_ocid
  egress_security_rules {
    stateless=true
    destination=var.vcn_cidr
    protocol="all"
  }
  egress_security_rules {
    stateless=false
    destination="0.0.0.0/0"
    protocol="all"
  }
  ingress_security_rules {
    stateless=true
    source=var.vcn_cidr
    protocol="all"
  }
  display_name = "fn-sl"
}
resource "oci_core_subnet" "fn_net" {
  compartment_id = var.compartment_ocid
  vcn_id = var.vcn_ocid
  display_name = "functions-subnet"
  cidr_block = var.vcn_subnet_cidr
  route_table_id = oci_core_route_table.fn_rt.id
  security_list_ids = [ oci_core_security_list.fn_sl.id ]
  prohibit_public_ip_on_vnic = true
  dns_label = "functions"
}
output "functions_subnet_ocid" { value = oci_core_subnet.fn_net.id }
