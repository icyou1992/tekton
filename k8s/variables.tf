variable "tag_common" {}
variable "cluster" {}


variable "vpc_id" {}
variable "subnet_public_ids" {}
variable "subnet_private_ids" {}

variable "enable_aws_load_balancer_controller" {}
variable "enable_aws_ebs_csi_driver" {}
variable "encryption_key" {
  nullable = true
  default = null
}

variable "k8s" {
  default = {}
}