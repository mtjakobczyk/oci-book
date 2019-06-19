# bastion module - vars.tf
resource "oci_core_route_table" "bastion_rt" {
  compartment_id = var.compartment_ocid
  vcn_id = var.vcn_ocid
  route_rules {
    network_entity_id = var.vcn_igw_ocid
    destination_type = "CIDR_BLOCK"
    destination = "0.0.0.0/0"
  }
  display_name = "bastion-rt"
}
resource "oci_core_security_list" "bastion_sl" {
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
    source=var.vcn_cidr
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
  display_name = "bastion-sl"
}
resource "oci_core_subnet" "bastion_net" {
  compartment_id = var.compartment_ocid
  vcn_id = var.vcn_ocid
  display_name = "bastion-net"
#  availability_domain = var.ads[0] # Uncomment to use AD-specific subnet
  cidr_block = var.vcn_subnet_cidr
  route_table_id = oci_core_route_table.bastion_rt.id
  security_list_ids = [ oci_core_security_list.bastion_sl.id ]
  prohibit_public_ip_on_vnic = "false"
  dns_label = "bastion"
}
