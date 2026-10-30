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
# Variables
# ---------------------------------------------------------------------------

variable "aws_region" {
  description = "Regió d'AWS on es despleguen les instàncies"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nom del projecte utilitzat a les etiquetes"
  type        = string
  default     = "practiquescloud-pt1-4-ex1"
}

variable "environment" {
  description = "Entorn de desplegament"
  type        = string
  default     = "formacio"
}

variable "instance_type" {
  description = "Tipus d'instància EC2"
  type        = string
  default     = "t3.micro"
}

variable "instance_names" {
  description = "Noms de les instàncies EC2 que es crearan"
  type        = set(string)
  default     = ["pt1-4-ex1-ec2-01", "pt1-4-ex1-ec2-02"]
}

variable "ami_name_pattern" {
  description = "Patró del nom de l'AMI d'Amazon Linux 2023"
  type        = string
  default     = "al2023-ami-2023.*-x86_64"
}

# ---------------------------------------------------------------------------
# Etiquetes comunes
# ---------------------------------------------------------------------------

locals {
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    Exercise    = "pt1-4-ex1"
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
# Instàncies EC2 a la VPC per defecte
# ---------------------------------------------------------------------------

resource "aws_instance" "this" {
  for_each = var.instance_names

  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = var.instance_type

  tags = {
    Name = each.value
  }

  # L'AMI s'obté sempre amb el data source (most_recent), però no volem que
  # una AMI nova faci substituir les instàncies que ja estan en marxa.
  lifecycle {
    ignore_changes = [ami]
  }
}
