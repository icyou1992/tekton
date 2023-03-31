output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "subnet_public_ids" {
  value = aws_subnet.subnet_public[*].id
}

output "subnet_private_ids" {
  value = aws_subnet.subnet_private[*].id
}