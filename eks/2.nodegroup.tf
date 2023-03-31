resource "aws_eks_node_group" "nodegroup" {
  node_group_name = "ndg-${var.tag_common}"
  cluster_name = aws_eks_cluster.cluster.name

  node_role_arn = aws_iam_role.role_nodegroup.arn
  subnet_ids = var.subnet_ids

  launch_template {
    name = aws_launch_template.launchtemplate.name
    version = aws_launch_template.launchtemplate.latest_version
  }

  scaling_config {
    desired_size = lookup(var.eks, "desired_size", 1)
    min_size = lookup(var.eks, "min_size", 1)
    max_size = lookup(var.eks, "max_size", 3)
  }
}

resource "aws_iam_role" "role_nodegroup" {
  name = "role-eksndg-${var.tag_common}"

  assume_role_policy = data.aws_iam_policy_document.policy_assume_role_nodegroup
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
  ]
}

resource "aws_launch_template" "launchtemplate" {
  name = "ltpl-${var.tag_common}"

  image_id = lookup(var.eks, "image_id", data.aws_ami.ubuntu.id)
  instance_type = lookup(var.eks, "instance_type", "t3.medium")
  # key_name =

  update_default_version = lookup(var.eks, "update_default_version", true)
  ebs_optimized = lookup(var.eks, "ebs_optimized", true)

  dynamic "block_device_mappings" {
    for_each = lookup(var.eks.block_device_mappings, "block_device_mappings", [
      {
        device_name = "/dev/xvda"
        ebs = [{
          volume_size = 50
          volume_type = "gp3"
        }]
      }
    ])
    content {
      device_name = lookup(block_device_mappings.value, "device_name", null)
      dynamic "ebs" {
        for_each = lookup(block_device_mappings.value, "ebs", [])

        content {
          volume_size = lookup(ebs.value, "volume_size", null)
          volume_type = lookup(ebs.value, "volume_type", null)
          encrypted = lookup(ebs.value, "block_device_encrypted", false)
          kms_key_id = lookup(ebs.value, "block_device_kms_key_id", null)
        }
      }  
    }
  }
  
}