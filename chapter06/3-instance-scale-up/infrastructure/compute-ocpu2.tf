/* # 2. Scale up and boot the new instance
variable "vm_2_ocpu_bootvolume_ocid" { }

 # 2. Add the new instance
resource "oci_core_instance" "vm_2_ocpu" {
  compartment_id = var.compartment_ocid
  display_name = "vm-2-OCPU"
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  source_details {
    source_id = var.vm_2_ocpu_bootvolume_ocid
    source_type = "bootVolume"
  }
  shape = "VM.Standard2.2"
  create_vnic_details {
    subnet_id = oci_core_subnet.net.id
    assign_public_ip = true
  }
  metadata = {
    ssh_authorized_keys = file("~/.ssh/oci_id_rsa.pub")
  }
}
 output "new_vm_public_ip" { value = oci_core_instance.vm_2_ocpu.public_ip }
*/
