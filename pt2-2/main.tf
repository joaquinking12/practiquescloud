# 1. PROVEEDOR Y REGION
terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# 2. VPC
resource "aws_vpc" "vpc03" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "VPC-03"
  }
}

# 3. SUBREDES PUBLICAS
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.vpc03.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet A"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.vpc03.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet B"
  }
}

# 4. INTERNET GATEWAY Y TABLA DE RUTAS
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc03.id

  tags = {
    Name = "IGW-VPC-03"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.vpc03.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "public_a_assoc" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b_assoc" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

# 5. GRUPO DE SEGURIDAD
resource "aws_security_group" "sg_pt22" {
  name        = "SG-PT2-2"
  description = "SSH desde cualquier lugar, ICMP solo desde la VPC"
  vpc_id      = aws_vpc.vpc03.id

  ingress {
    description = "SSH desde cualquier lugar"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "ICMP solo desde la VPC"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = [aws_vpc.vpc03.cidr_block]
  }

  egress {
    description = "Todo el trafico saliente"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SG-PT2-2"
  }
}

# 6. INSTANCIAS EC2
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

resource "aws_instance" "ec2_a" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_a.id
  key_name               = "vockey"
  vpc_security_group_ids = [aws_security_group.sg_pt22.id]

  tags = {
    Name = "ec2-a"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}

resource "aws_instance" "ec2_b" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public_b.id
  key_name               = "vockey"
  vpc_security_group_ids = [aws_security_group.sg_pt22.id]

  tags = {
    Name = "ec2-b"
  }

  lifecycle {
    ignore_changes = [ami]
  }
}

# SALIDAS: muestra las IPs al terminar el apply
output "ec2_a_public_ip" {
  value = aws_instance.ec2_a.public_ip
}

output "ec2_a_private_ip" {
  value = aws_instance.ec2_a.private_ip
}

output "ec2_b_public_ip" {
  value = aws_instance.ec2_b.public_ip
}

output "ec2_b_private_ip" {
  value = aws_instance.ec2_b.private_ip
}