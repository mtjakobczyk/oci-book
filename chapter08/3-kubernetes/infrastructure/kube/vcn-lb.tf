# kube module - vcn-lb.tf  / networking for load balancer

resource "oci_core_route_table" "oke_lb_rt" {
  compartment_id = var.compartment_ocid
  vcn_id = var.vcn_ocid
  display_name = "oke-lb-rt"
  route_rules {
    destination = "0.0.0.0/0"
    network_entity_id = var.vcn_igw_ocid
  }
}

resource "oci_core_security_list" "oke_lb_sl" {
  compartment_id = var.compartment_ocid
  vcn_id = var.vcn_ocid
  display_name = "oke-lb-sl"
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
  # Allow all inbound traffic on ports 30000-32767
  egress_security_rules {
    stateless = true
    destination = "0.0.0.0/0"
    protocol = "all"
  }
  ingress_security_rules {
    stateless=true
    source = "0.0.0.0/0"
    protocol="6"
    tcp_options {
      min = 30000
      max = 32767
    }
  }
}

resource "oci_core_subnet" "oke_lb_ad1_net" {
  compartment_id = var.compartment_ocid
  vcn_id = var.vcn_ocid
  display_name = "oke-lb-ad1-net"
  availability_domain = var.ads[0]
  cidr_block = var.oke_lb_subnet_cidr[0]
  route_table_id = oci_core_route_table.oke_lb_rt.id
  security_list_ids = [ oci_core_security_list.oke_lb_sl.id ]
#  dhcp_options_id = var.vcn_dhcp_options_ocid
  dns_label = "lb1"
}

resource "oci_core_subnet" "oke_lb_ad2_net" {
  compartment_id = var.compartment_ocid
  vcn_id = var.vcn_ocid
  display_name = "oke-lb-ad2-net"
  availability_domain = var.ads[1]
  cidr_block = var.oke_lb_subnet_cidr[1]
  route_table_id = oci_core_route_table.oke_lb_rt.id
  security_list_ids = [ oci_core_security_list.oke_lb_sl.id ]
#  dhcp_options_id = var.vcn_dhcp_options_ocid
  dns_label = "lb2"
}
