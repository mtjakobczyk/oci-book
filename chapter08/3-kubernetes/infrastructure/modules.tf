# root module / modules

module "kubernetes" {
  source           = "./kube"
  compartment_ocid = var.compartment_ocid
  vcn_ocid         = oci_core_virtual_network.vcn.id
  vcn_nat_ocid     = oci_core_nat_gateway.natgw.id
  vcn_igw_ocid     = oci_core_internet_gateway.igw.id
  ads              = local.ads
}
