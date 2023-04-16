variable "tag_common" {}
variable "cluster" {}


variable "vpc_id" {}
variable "subnet_public_ids" {}
variable "subnet_private_ids" {}

variable "enable_aws_load_balancer_controller" {}
variable "enable_aws_ebs_csi_driver" {}
variable "encryption_key" {
  default = null
  nullable = true
}

variable "k8s" {}