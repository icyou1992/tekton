data "aws_ssm_parameter" "ami" {
  name = "/aws/service/eks/optimized-ami/${aws_eks_cluster.cluster.version}/amazon-linux-2/recommended/image_id"
}

data "tls_certificate" "certificate" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

data "aws_eks_addon_version" "latest" {
  for_each = var.eks.addons

  addon_name         = each.key
  kubernetes_version = aws_eks_cluster.cluster.version
  most_recent        = true
}

data "aws_iam_policy_document" "policy_assume_role_cluster" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "policy_assume_role_nodegroup" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}


###################################

# data "aws_ami" "ubuntu" {
#   most_recent = true

#   filter {
#     name = "name"
#     values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
#   }

#   filter {
#     name = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["099720109477"]
# }

# data "aws_ami" "al2" {
#   most_recent = true

#   filter {
#     name = "name"
#     values = ["amzn2-ami-hvm-*-x86_64-ebs"]
#   }

#   owners = ["amazon"]
# }