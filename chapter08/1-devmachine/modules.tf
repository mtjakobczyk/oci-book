### Modules

module "devmachine" {
  source           = "./devmachine"
  compartment_ocid = var.compartment_ocid
  vcn_ocid         = oci_core_virtual_network.vcn.id
  vcn_igw_ocid     = oci_core_internet_gateway.igw.id
  vcn_cidr         = oci_core_virtual_network.vcn.cidr_block
  vcn_subnet_cidr  = "10.0.1.0/27"
  ads              = local.ads
  image_ocid       = local.image_ocid
}

### ADs and Compute Image evaluation
locals {
  ads = [
    data.oci_identity_availability_domains.ads.availability_domains[0]["name"],
    data.oci_identity_availability_domains.ads.availability_domains[1]["name"],
    data.oci_identity_availability_domains.ads.availability_domains[2]["name"],
  ]
  image_ocid = data.oci_core_images.compute_image.images[0].id
}

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "compute_image" {
  compartment_id           = var.tenancy_ocid
  operating_system         = "CentOS"
  operating_system_version = 7
}

output "dev_machine_public_ip" {
  value = module.devmachine.dev_public_ip
}

output "dev_machine_image_name" {
  value = data.oci_core_images.compute_image.images[0].display_name
}

