# bastion module - vars.tf
resource "oci_core_instance" "bastion_vm" {
  compartment_id = var.compartment_ocid
  display_name = "bastion-vm"
  availability_domain = var.ads[0]
  source_details {
    source_id = var.image_ocid
    source_type = "image"
  }
  shape = "VM.Standard2.1"
  create_vnic_details {
    subnet_id = oci_core_subnet.bastion_net.id
    assign_public_ip = true
  }
  metadata = {
    ssh_authorized_keys = file("~/.ssh/oci_id_rsa.pub")
  }
}
output "bastion_public_ip" { value = oci_core_instance.bastion_vm.public_ip }
