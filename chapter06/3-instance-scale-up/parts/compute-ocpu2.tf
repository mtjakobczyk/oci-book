
variable "bootvolume_ocid" { }

 # 2. Add the new instance
resource "oci_core_instance" "vm-v2" {
  compartment_id = "${var.compartment_ocid}"
  display_name = "vm-2-OCPU"
  availability_domain = "${local.ad}"
  source_details {
    source_id = "${var.bootvolume_ocid}"
    source_type = "bootVolume"
  }
  shape = "VM.Standard2.2"
  create_vnic_details {
    subnet_id = "${oci_core_subnet.net.id}"
    assign_public_ip = true
  }
  metadata {
    ssh_authorized_keys = "${file("~/.ssh/oci_id_rsa.pub")}"
    user_data = "${base64encode(file("cloud-init/vm.config.yaml"))}"
  }
}
