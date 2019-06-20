# root module - provider.tf
resource "oci_core_instance" "vm" {
  compartment_id = var.compartment_ocid
  display_name = "vm-1-OCPU"
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  source_details {
    source_id = data.oci_core_images.centos_image.images[0].id
    source_type = "image"
  }
  shape = "VM.Standard2.1"
  create_vnic_details {
    subnet_id = oci_core_subnet.net.id
    assign_public_ip = true
  }
  metadata {
    ssh_authorized_keys = file("~/.ssh/oci_id_rsa.pub")
    user_data = base64encode(file("cloud-init/vm.config.yaml"))
  }
/*
   # 1. Stop the old instance
   state = "STOPPED"
   preserve_boot_volume = true
*/
}
/*
 output "vm_bootvolume_ocid" {
   value = oci_core_instance.vm.boot_volume_id
 }
*/
output "vm_public_ip" { value = oci_core_instance.vm.public_ip }
