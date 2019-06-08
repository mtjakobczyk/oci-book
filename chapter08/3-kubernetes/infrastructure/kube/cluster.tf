# kube module / kubernetes cluster

resource "oci_containerengine_cluster" "k8s_cluster" {
  compartment_id = var.compartment_ocid
  kubernetes_version = var.oke_cluster["version"]
  name = "k8s-cluster"
  vcn_id = var.vcn_ocid
  options {
    kubernetes_network_config {
      pods_cidr = var.oke_cluster["pods_cidr"]
      services_cidr = var.oke_cluster["services_cidr"]
    }
    service_lb_subnet_ids = [ oci_core_subnet.oke_lb_ad1_net.id, oci_core_subnet.oke_lb_ad2_net.id ]
  }
}

resource "oci_containerengine_node_pool" "k8s_nodepool" {
  compartment_id = var.compartment_ocid
  cluster_id = oci_containerengine_cluster.k8s_cluster.id
  kubernetes_version = var.oke_cluster["version"]
  name = "k8s-nodepool"
  node_image_name = var.oke_cluster["worker_image"]
  node_shape = var.oke_cluster["worker_shape"]
  subnet_ids = [ oci_core_subnet.oke_workers_ad1_net.id, oci_core_subnet.oke_workers_ad2_net.id ]
  quantity_per_subnet = var.oke_cluster["worker_nodes_in_subnet"]
  ssh_public_key = file("~/.ssh/oci_id_rsa.pub")
}
