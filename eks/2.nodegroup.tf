resource "aws_eks_node_group" "nodegroup" {
  node_group_name = "ndg-${var.tag_common}"
  cluster_name    = aws_eks_cluster.cluster.name
  
  # release_version = nonsensitive(data.aws_ssm_parameter.ami.value)
  node_role_arn = aws_iam_role.role_nodegroup.arn
  subnet_ids    = var.subnet_private_ids

  capacity_type  = lookup(var.eks, "capacity_type", "ON_DEMAND")
  # ami_type       = "AL2_x86_64"
  # instance_types = ["t3.medium"]
  # disk_size      = 30

  # remote_access {
  #   ec2_ssh_key = lookup(var.eks, "key", "")
  #   source_security_group_ids = [ aws_security_group.securitygroup_cluster.id ]
  # }

  launch_template {
    name    = aws_launch_template.launchtemplate.name
    version = aws_launch_template.launchtemplate.latest_version
  }
  
  scaling_config {
    desired_size = lookup(var.eks, "desired_size", 1)
    min_size     = lookup(var.eks, "min_size", 1)
    max_size     = lookup(var.eks, "max_size", 3)
  }

  update_config {
    max_unavailable = lookup(var.eks, "max_unavailable", 1) 
  }


  tags = {
    Name = "node-${var.tag_common}"
  }
}

resource "aws_launch_template" "launchtemplate" {
  name = "ltpl-${var.tag_common}"

  image_id      = lookup(var.eks, "image_id", data.aws_ssm_parameter.ami.value)
  instance_type = lookup(var.eks, "instance_type", "t3.medium")
  # key_name = 
  key_name = lookup(var.eks, "key", null)

  update_default_version = lookup(var.eks, "update_default_version", true)
  ebs_optimized          = lookup(var.eks, "ebs_optimized", true)
  vpc_security_group_ids = lookup(var.eks, "vpc_security_group_ids", [])
  # vpc_security_group_ids = [ aws_security_group.securitygroup_launchtemplate.id ]

  dynamic "block_device_mappings" {
    for_each = lookup(var.eks, "block_device_mappings", [])
    content {
      device_name = lookup(block_device_mappings.value, "device_name", null)
      dynamic "ebs" {
        for_each = lookup(block_device_mappings.value, "ebs", [])

        content {
          volume_size = lookup(ebs.value, "volume_size", null)
          volume_type = lookup(ebs.value, "volume_type", null)
          encrypted   = lookup(ebs.value, "block_device_encrypted", false)
          kms_key_id  = lookup(ebs.value, "block_device_kms_key_id", null)
        }
      }
    }
  }

  user_data = base64encode(templatefile(
    "${path.module}/files/launch_template.tpl", {
      apiserver-endpoint = "${aws_eks_cluster.cluster.endpoint}"
      b64-cluster-ca     = "${aws_eks_cluster.cluster.certificate_authority.0.data}"
      cluster-name       = "${aws_eks_cluster.cluster.name}"
    }
  ))

  tag_specifications {
    resource_type = "instance"
    tags = merge({
      Name                                                    = "node-${var.tag_common}"
      "kubernetes.io/cluster/${aws_eks_cluster.cluster.name}" = "owned"
      "aws:eks:cluster-name"                                  = aws_eks_cluster.cluster.name
    }, lookup(var.eks, "tags", null))
  }

  lifecycle {
    ignore_changes = [
      tag_specifications
    ]
  }
}

resource "aws_iam_role" "role_nodegroup" {
  name = "role-eksndg-${var.tag_common}"

  assume_role_policy = data.aws_iam_policy_document.policy_assume_role_nodegroup.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]
}
