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
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

# ---------------------------------------------------------------------------
# Etiquetes comunes
# ---------------------------------------------------------------------------

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Exercise    = "pt1-4-ex2"
    ManagedBy   = "Terraform"
  }
}

# ---------------------------------------------------------------------------
# AMI d'Amazon Linux 2023 (sempre la més recent)
# ---------------------------------------------------------------------------

data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = [var.ami_name_pattern]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# ---------------------------------------------------------------------------
# VPC
# ---------------------------------------------------------------------------

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# ---------------------------------------------------------------------------
# Subxarxes (totes a la mateixa AZ)
# ---------------------------------------------------------------------------

resource "aws_subnet" "this" {
  for_each = var.subnets

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value.cidr_block
  availability_zone       = var.availability_zone
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.project_name}-${each.value.name}"
  }
}

# ---------------------------------------------------------------------------
# Mapa d'instàncies: 2 per subxarxa, generat amb bucles
# ---------------------------------------------------------------------------

locals {
  instances = {
    for item in flatten([
      for subnet_key, subnet in var.subnets : [
        for index in range(var.instances_per_subnet) : {
          key        = "${subnet_key}-${format("%02d", index + 1)}"
          subnet_key = subnet_key
          name       = "${var.project_name}-ec2-${subnet.name}-${format("%02d", index + 1)}"
        }
      ]
    ]) : item.key => item
  }
}

# ---------------------------------------------------------------------------
# Instàncies EC2
# ---------------------------------------------------------------------------

resource "aws_instance" "this" {
  for_each = local.instances

  ami                         = data.aws_ami.amazon_linux_2023.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.this[each.value.subnet_key].id
  associate_public_ip_address = false

  tags = {
    Name = each.value.name
  }
}
