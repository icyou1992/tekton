resource "aws_route_table" "rt_public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
    Name = "rt-pbl-${var.tag_common}"
  }
}

resource "aws_route_table" "rt_private" {
  count  = length(aws_subnet.subnet_private)
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw[count.index % length(aws_subnet.subnet_public)].id
  }
  tags = {
    Name = "rt-prv-${var.tag_common}-${count.index}"
  }
}

resource "aws_route_table_association" "rta_public" {
  count          = length(aws_subnet.subnet_public)
  subnet_id      = aws_subnet.subnet_public[count.index].id
  route_table_id = aws_route_table.rt_public.id
}

resource "aws_route_table_association" "rta_private" {
  count          = length(aws_subnet.subnet_private)
  subnet_id      = aws_subnet.subnet_private[count.index].id
  route_table_id = aws_route_table.rt_private[count.index % length(aws_subnet.subnet_public)].id
}
