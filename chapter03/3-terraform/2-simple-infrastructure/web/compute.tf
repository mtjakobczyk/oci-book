# web module - compute.tf
resource "oci_core_instance" "web_vm" {
  compartment_id = var.compartment_ocid
  display_name = "web-vm"
  availability_domain = var.ads[0]
  source_details {
    source_id = var.compute_image_ocid
    source_type = "image"
  }
  shape = "VM.Standard2.1"
  create_vnic_details {
    subnet_id = oci_core_subnet.web_subnet.id
    assign_public_ip = true
  }
  metadata = {
    ssh_authorized_keys = file("~/.ssh/oci_id_rsa.pub")
    user_data = base64encode(file("web/cloud-init/webvm.config.yaml"))
  }
}
data "oci_core_vnic_attachments" "web_vnic_attachment" {
  compartment_id = var.compartment_ocid
  instance_id = oci_core_instance.web_vm.id
}
data "oci_core_vnic" "web_vnic" {
  vnic_id = data.oci_core_vnic_attachments.web_vnic_attachment.vnic_attachments[0].vnic_id
}
output "web_public_ip" {
  value = data.oci_core_vnic.web_vnic.public_ip_address
}
