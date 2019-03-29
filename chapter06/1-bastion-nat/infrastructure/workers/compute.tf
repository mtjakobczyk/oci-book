# workers / compute.tf
resource "oci_core_instance" "worker_vm" {
  compartment_id = "${var.compartment_ocid}"
  display_name = "worker-vm"
  availability_domain = "${var.ads[0]}"
  source_details {
    source_id = "${var.image_ocid}"
    source_type = "image"
  }
  shape = "VM.Standard2.1"
  create_vnic_details {
    subnet_id = "${oci_core_subnet.workers_net.id}"
    assign_public_ip = false
  }
  metadata {
    ssh_authorized_keys = "${file("~/.ssh/oci_id_rsa.pub")}"
  }
}
