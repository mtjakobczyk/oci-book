resource "oci_core_instance" "app_vm" {
  compartment_id = "${var.compartment_ocid}"
  display_name = "app-vm"
  availability_domain = "${var.ads[1]}"
  source_details {
    source_id = "${var.compute_image_ocid}"
    source_type = "image"
  }
  shape = "VM.Standard2.1"
  create_vnic_details {
    subnet_id = "${oci_core_subnet.app_subnet.id}"
    assign_public_ip = true
  }
  metadata {
    ssh_authorized_keys = "${file("~/.ssh/oci_id_rsa.pub")}"
    user_data = "${base64encode(file("app/cloud-init/appvm.config.yaml"))}"
  }
  defined_tags {
    test-projects.realestate = "true"
  }
}
data "oci_core_vnic_attachments" "app_vnic_attachment" {
  compartment_id = "${var.compartment_ocid}"
  instance_id = "${oci_core_instance.app_vm.id}"
}
data "oci_core_vnic" "app_vnic" {
  vnic_id = "${data.oci_core_vnic_attachments.app_vnic_attachment.vnic_attachments.0.vnic_id}"
}
output "host_public_ip" { value = "${data.oci_core_vnic.app_vnic.public_ip_address}" }
