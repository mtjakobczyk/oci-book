# web / volume.tf
# https://www.terraform.io/docs/providers/oci/r/core_volume.html
# https://docs.cloud.oracle.com/iaas/api/#/en/iaas/20160918/Volume/
resource "oci_core_volume" "web_volume" {
  compartment_id = "${var.compartment_ocid}"
  availability_domain = "${var.ad}"
  size_in_gbs = 50
  display_name = "web-volume"
}

# https://www.terraform.io/docs/providers/oci/r/core_volume_attachment.html
# https://docs.cloud.oracle.com/iaas/api/#/en/iaas/20160918/VolumeAttachment/
resource "oci_core_volume_attachment" "web_volume_attachment" {
  attachment_type = "paravirtualized"
  instance_id = "${oci_core_instance.web_vm.id}"
  volume_id = "${oci_core_volume.web_volume.id}"
  is_pv_encryption_in_transit_enabled = "true"
  display_name = "web-volume-pv-attachment"
}

# Consistent Device Paths
# On Linux operating systems, the order in which volumes are attached is non-deterministic, so it can change with each reboot. To prevent this issue, specify the volume UUID in the /etc/fstab file instead of the device name OR use consistent device names feature. 
# https://docs.cloud.oracle.com/iaas/Content/Block/References/consistentdevicepaths.htm
# https://www.youtube.com/watch?v=-k2FYSDqgcA
# https://blogs.oracle.com/cloud-infrastructure/usability-improvement:-consistent-device-path-names-and-ordering-for-block-volume-attachments
