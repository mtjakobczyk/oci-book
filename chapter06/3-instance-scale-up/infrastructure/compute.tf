
resource "oci_core_instance" "vm" {
  compartment_id = "${var.compartment_ocid}"
  display_name = "vm-1-OCPU"
  availability_domain = "${local.ad}"
  source_details {
    source_id = "${local.image_ocid}"
    source_type = "image"
  }
  shape = "VM.Standard2.1"
  create_vnic_details {
    subnet_id = "${oci_core_subnet.net.id}"
    assign_public_ip = true
  }
  metadata {
    ssh_authorized_keys = "${file("~/.ssh/oci_id_rsa.pub")}"
    user_data = "${base64encode(file("cloud-init/vm.config.yaml"))}"
  }
/*
   # 1. Stop the old instance
   state = "STOPPED"
   preserve_boot_volume = true
*/
}
/*
 output "3 - VM bootvolume OCID" {
   value = "${oci_core_instance.vm.boot_volume_id}"
 }
*/
 output "1 - VM public IP" { value = "${oci_core_instance.vm.public_ip}" }
