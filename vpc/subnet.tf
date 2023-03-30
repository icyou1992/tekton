resource "aws_subnet" "subnet_public" {
  count = length(var.subnet_public.cidr)
  vpc_id = aws_vpc.vpc.id

  # availability_zone = var.subnet_public.azs
  cidr_block = var.subnet_public.cidr[count.index]

  map_public_ip_on_launch = true
  tags = {
    Name = "sbn-pbl-${var.tag_common}"
  }
}

resource "aws_subnet" "subnet_private" {
  count = length(var.subnet_private.cidr)
  vpc_id = aws_vpc.vpc.id

  # availability_zone = var.subnet_private.azs
  cidr_block = var.subnet_private.cidr[count.index]

  map_public_ip_on_launch = true
  tags = {
    Name = "sbn-prv-${var.tag_common}"
  }
}