# bastion / compute.tf
resource "oci_core_instance" "bastion_vm" {
  compartment_id = "${var.compartment_ocid}"
  display_name = "bastion-vm"
  availability_domain = "${var.ads[0]}"
  source_details {
    source_id = "${var.image_ocid}"
    source_type = "image"
  }
  shape = "VM.Standard2.1"
  create_vnic_details {
    subnet_id = "${oci_core_subnet.bastion_net.id}"
    assign_public_ip = true
  }
  metadata {
    ssh_authorized_keys = "${file("~/.ssh/oci_id_rsa.pub")}"
  }
}
#
data "oci_core_vnic_attachments" "bastion_vnic_attachment" {
  compartment_id = "${var.compartment_ocid}"
  instance_id = "${oci_core_instance.bastion_vm.id}"
}
data "oci_core_vnic" "bastion_vnic" {
  vnic_id = "${data.oci_core_vnic_attachments.bastion_vnic_attachment.vnic_attachments.0.vnic_id}"
}
output "bastion_public_ip" { value = "${data.oci_core_vnic.bastion_vnic.public_ip_address}" }
