# root module - modules.tf
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.compartment_ocid
}
data "oci_core_images" "centos_image" {
  compartment_id = var.compartment_ocid
  operating_system = "CentOS"
  operating_system_version = 7
  shape = "VM.Standard2.1"
}
module "app" {
  source = "./app"
  compartment_ocid = var.compartment_ocid
  vcn_ocid = oci_core_virtual_network.app_vcn.id
  vcn_igw_ocid = oci_core_internet_gateway.app_igw.id
  vcn_subnet_cidr = "10.1.1.0/30"
  ads = data.oci_identity_availability_domains.ads.availability_domains[*].name
  compute_image_ocid = data.oci_core_images.centos_image.images[0].id
}
output "app_instance_public_ip" { value = module.app.host_public_ip }
