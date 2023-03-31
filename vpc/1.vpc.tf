resource "aws_vpc" "vpc" {
  cidr_block = var.vpc.cidr

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-${var.tag_common}"
  }
}
