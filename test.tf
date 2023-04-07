
###

data "aws_ami" "al2" {
  most_recent = true

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }

  owners = ["amazon"]
}

resource "aws_instance" "bastion" {
  instance_type = "t3.small"
  ami = data.aws_ami.al2.id

  subnet_id = module.vpc.subnet_public_ids[0]
  vpc_security_group_ids = [ aws_security_group.securitygroup.id ]  

  key_name = "pfe"
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = "30"
  }

  tags = {
    Name = "ec2-${local.common}"
  }
}

resource "aws_security_group" "securitygroup" {
  name = "sg_${local.common}"

  vpc_id = module.vpc.vpc_id

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["27.122.140.10/32"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "sg-${local.common}"
    # "kubernetes.io/cluster/${aws_eks_cluster.cluster.name}" = "owned"
    # "aws:eks:cluster-name" = "${aws_eks_cluster.cluster.name}"
  }
}