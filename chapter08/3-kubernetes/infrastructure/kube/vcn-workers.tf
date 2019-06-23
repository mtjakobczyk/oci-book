# kube module - vcn-workers.tf / networking for workers

resource "oci_core_route_table" "oke_workers_rt" {
  compartment_id = var.compartment_ocid
  vcn_id = var.vcn_ocid
  display_name = "oke-workers-rt"
  route_rules {
    destination = "0.0.0.0/0"
    network_entity_id = var.vcn_nat_ocid
  }
}

resource "oci_core_security_list" "oke_workers_sl" {
  compartment_id = var.compartment_ocid
  vcn_id = var.vcn_ocid
  display_name = "oke-workers-sl"
  # Allow all traffic within the VCN
  egress_security_rules {
    stateless = true
    destination = var.oke_cluster["cidr"]
    protocol = "all"
  }
  ingress_security_rules {
    stateless=true
    source = var.oke_cluster["cidr"]
    protocol="all"
  }
  # Allow all outbound traffic
  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol = "all"
  }
}

resource "oci_core_subnet" "oke_workers_ad1_net" {
  compartment_id = var.compartment_ocid
  vcn_id = var.vcn_ocid
  display_name = "oke-workers-ad1-net"
  availability_domain = var.ads[0]
  cidr_block = var.oke_wn_subnet_cidr[0]
  route_table_id = oci_core_route_table.oke_workers_rt.id
  security_list_ids = [ oci_core_security_list.oke_workers_sl.id ]
#  dhcp_options_id = var.vcn_dhcp_options_ocid
  prohibit_public_ip_on_vnic = true
  dns_label = "work1"
}

resource "oci_core_subnet" "oke_workers_ad2_net" {
  compartment_id = var.compartment_ocid
  vcn_id = var.vcn_ocid
  display_name = "oke-workers-ad2-net"
  availability_domain = var.ads[1]
  cidr_block = var.oke_wn_subnet_cidr[1]
  route_table_id = oci_core_route_table.oke_workers_rt.id
  security_list_ids = [ oci_core_security_list.oke_workers_sl.id ]
#  dhcp_options_id = var.vcn_dhcp_options_ocid
  prohibit_public_ip_on_vnic = true
  dns_label = "work2"
}
