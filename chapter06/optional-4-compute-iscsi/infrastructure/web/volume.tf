# web / volume.tf
resource "oci_core_volume" "web_volume" {
  compartment_id = "${var.compartment_ocid}"
  availability_domain = "${var.ad}"
  size_in_gbs = 50
  display_name = "web-volume"
}

resource "oci_core_volume_attachment" "web_volume_attachment" {
  attachment_type = "iscsi"
  instance_id = "${oci_core_instance.web_vm.id}"
  volume_id = "${oci_core_volume.web_volume.id}"
  use_chap = "false"
  display_name = "web-volume-iscsi-attachment"

  provisioner "remote-exec" {
    inline = [
      "sudo iscsiadm -m node -o new -T ${self.iqn} -p ${self.ipv4}:${self.port}",
      "sudo iscsiadm -m node -o update -T ${self.iqn} -n node.startup -v automatic",
      "sudo iscsiadm -m node -T ${self.iqn} -p ${self.ipv4}:${self.port} -l",
    ]
    connection {
      type = "ssh"
      host = "${oci_core_instance.web_vm.public_ip}"
      user = "opc"
      private_key = "${file("~/.ssh/oci_id_rsa")}"
    }
  }
  provisioner "remote-exec" {
    when       = "destroy"
    inline = [
      "sudo iscsiadm -m node -T ${self.iqn} -p ${self.ipv4}:${self.port} -u",
      "sudo iscsiadm -m node -o delete -T ${self.iqn} -p ${self.ipv4}:${self.port}",
    ]
    connection {
      type = "ssh"
      host = "${oci_core_instance.web_vm.public_ip}"
      user = "opc"
      private_key = "${file("~/.ssh/oci_id_rsa")}"
    }
  }
}

#
