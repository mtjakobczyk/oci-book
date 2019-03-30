# workers / compute.tf
resource "oci_core_instance_configuration" "worker_config" {
  compartment_id = "${var.compartment_ocid}"
  instance_details {
    instance_type = "compute"
    launch_details {
      compartment_id = "${var.compartment_ocid}"
      create_vnic_details {
        assign_public_ip = "false"
      }
      metadata {
        ssh_authorized_keys = "${file("~/.ssh/oci_id_rsa.pub")}"
      }
      shape = "VM.Standard2.1"
      source_details {
        source_type = "image"
        image_id = "${var.image_ocid}"
      }
    }
  }
  display_name = "instance-config"
}
resource "oci_core_instance_pool" "worker_pool" {
  compartment_id = "${var.compartment_ocid}"
  instance_configuration_id = "${oci_core_instance_configuration.worker_config.id}"
  placement_configurations = [
    {
      availability_domain = "${var.ads[0]}"
      primary_subnet_id = "${oci_core_subnet.workers_ad1_net.id}"
    },
    {
      availability_domain = "${var.ads[1]}"
      primary_subnet_id = "${oci_core_subnet.workers_ad2_net.id}"
    }
  ]
  size = "${var.pool_target_size}"
  display_name = "workers-pool"
}
resource "oci_autoscaling_auto_scaling_configuration" "workers_pool_autoscale" {
  compartment_id = "${var.compartment_ocid}"
  auto_scaling_resources {
      id = "${oci_core_instance_pool.worker_pool.id}"
      type = "instancePool"
  }
  cool_down_in_seconds = 300
  policies {
    capacity {
      initial = 2
      max = 4
      min = 1
    }
    policy_type = "threshold"
    rules = [
      {
      action {
        type = "CHANGE_COUNT_BY"
        value = 1
      }
      metric {
        metric_type = "CPU_UTILIZATION"
        threshold {
          operator = "GT"
          value = "70"
        }
      }
      display_name = "scale-out"
    },
    {
      action {
        type = "CHANGE_COUNT_BY"
        value = -1
      }
      metric {
        metric_type = "CPU_UTILIZATION"
        threshold {
          operator = "LT"
          value = "30"
        }
      }
      display_name = "scale-in"
    }
    ]
    display_name = "workers-pool-autoscale-policy"
  }
  display_name = "workers-pool-autoscale"
}
