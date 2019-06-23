# kube module - vars.tf
variable "compartment_ocid" {}
variable "vcn_ocid" {}
variable "vcn_igw_ocid" {}
variable "vcn_nat_ocid" {}
variable "ads" {
  type=list(string)
  default = []
}

variable "oke_cluster" {
  type = "map"
  default = {
    cidr = "10.0.2.0/25"
    version = "v1.12.7"
    worker_image = "Oracle-Linux-7.6"
    worker_shape = "VM.Standard2.1"
    worker_nodes_in_subnet = 1
    pods_cidr = "10.244.0.0/16"
    services_cidr = "10.96.0.0/16"
  }
}

variable "oke_wn_subnet_cidr" {
  type = list(string)
  default = [ "10.0.2.0/27", "10.0.2.32/27" ]
}
variable "oke_lb_subnet_cidr" {
  type = list(string)
  default = [ "10.0.2.128/28", "10.0.2.144/28" ]
}
variable "oke_engine_cidr" {
  type = list(string)
  default = [ "130.35.0.0/16", "138.1.0.0/17"]
}
