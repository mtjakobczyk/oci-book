data "oci_identity_availability_domains" "ads" {
  compartment_id = "${var.tenancy_ocid}"
}
data "oci_core_images" "centos_image" {
  compartment_id = "${var.tenancy_ocid}"
  operating_system = "CentOS"
  operating_system_version = 7
}
module "app" {
  source = "app"
  compartment_ocid = "${var.compartment_ocid}"
  vcn_ocid = "${oci_core_virtual_network.app_vcn.id}"
  vcn_igw_ocid = "${oci_core_internet_gateway.app_igw.id}"
  vcn_subnet_cidr = "10.1.1.0/30"
  ads = [
    "${lookup(data.oci_identity_availability_domains.ads.availability_domains[0], "name")}",
    "${lookup(data.oci_identity_availability_domains.ads.availability_domains[1], "name")}"
  ]
  compute_image_ocid = "${data.oci_core_images.centos_image.images.0.id}"
}
output "App server " { value = "${module.app.host_public_ip}" }
