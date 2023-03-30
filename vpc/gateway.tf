resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw-${var.tag_common}"
  }
}

resource "aws_nat_gateway" "ngw" {
  count = length(aws_subnet.subnet_public)

  subnet_id = aws_subnet.subnet_private[count.index].id
  allocation_id = aws_eip.eip_ngw[count.index].id
  connectivity_type = try(var.subnet_private.connectivity_type, "public")

  tags = {
    Name = "ngw-${var.tag_common}"
  }
}

resource "aws_eip" "eip_ngw" {
  count = length(aws_subnet.subnet_public)
  
  vpc = true
  tags = {
    Name = "eip-ngw-${var.tag_common}"
  }
}