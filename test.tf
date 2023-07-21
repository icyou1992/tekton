
###
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

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
  ami = data.aws_ami.ubuntu.id

  subnet_id = module.vpc.subnet_public_ids[0]
  vpc_security_group_ids = [ aws_security_group.securitygroup.id ]  

  key_name = local.key
  associate_public_ip_address = true

  root_block_device {
    volume_type = "gp3"
    volume_size = "30"
  }

  user_data = <<-EOF
  #!/bin/bash

  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
  sudo apt install unzip
  unzip awscliv2.zip
  sudo ./aws/install

  curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
  curl -LO "https://dl.k8s.io/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
  echo "$(cat kubectl.sha256)  kubectl" | sha256sum --check
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  
  sudo mkdir /home/ubuntu/.aws
  sudo touch /home/ubuntu/.aws/credentials
  sudo echo "[default]" >> /home/ubuntu/.aws/credentials
  sudo echo "aws_access_key_id = ${var.aws_access_key_id}" >> /home/ubuntu/.aws/credentials
  sudo echo "aws_secret_access_key = ${var.aws_secret_key_id}" >> /home/ubuntu/.aws/credentials

  sudo touch /home/ubuntu/.aws/config
  sudo echo "[default]" >> /home/ubuntu/.aws/config
  sudo echo "region = ap-northeast-2" >> /home/ubuntu/.aws/config
  sudo echo "output = json" >> /home/ubuntu/.aws/config

  sudo aws eks update-kubeconfig --name ${module.eks.cluster.name}

  curl -LO https://github.com/tektoncd/cli/releases/download/v0.30.1/tektoncd-cli-0.30.1_Linux-64bit.deb
  sudo dpkg -i ./tektoncd-cli-0.30.1_Linux-64bit.deb

  EOF

  tags = {
    Name = "ec2-${local.common}"
  }

  depends_on = [
    module.eks
  ]
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

output "ec2_ip" {
  value = aws_instance.bastion.public_ip
}