# devmachine module - compute.tf
resource "oci_core_instance" "dev_vm" {
  compartment_id = var.compartment_ocid
  display_name = "dev-vm"
  availability_domain = var.ads[2]
  source_details {
    source_id = var.image_ocid
    source_type = "image"
  }
  shape = "VM.Standard2.1"
  create_vnic_details {
    subnet_id = oci_core_subnet.dev_net.id
    assign_public_ip = true
  }
  metadata = {
    ssh_authorized_keys = file("~/.ssh/oci_id_rsa.pub"),
    user_data = base64encode(file("devmachine/cloud-init/devvm.config.yaml"))
  }
}
output "dev_public_ip" { value = oci_core_instance.dev_vm.public_ip }
