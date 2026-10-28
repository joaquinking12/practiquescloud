variable "aws_region" {
  description = "Regió d'AWS on es desplega la infraestructura"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nom del projecte utilitzat a les etiquetes i als noms dels recursos"
  type        = string
  default     = "practiquescloud-pt1-4-ex2"
}

variable "environment" {
  description = "Entorn de desplegament"
  type        = string
  default     = "formacio"
}

variable "vpc_cidr" {
  description = "Bloc CIDR de la VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "El valor de vpc_cidr ha de ser un bloc CIDR IPv4 vàlid."
  }
}

variable "availability_zone" {
  description = "Zona de disponibilitat on es creen totes les subxarxes"
  type        = string
  default     = "us-east-1a"
}

variable "instance_type" {
  description = "Tipus d'instància EC2"
  type        = string
  default     = "t3.micro"
}

variable "instances_per_subnet" {
  description = "Nombre d'instàncies EC2 que es creen a cada subxarxa"
  type        = number
  default     = 2

  validation {
    condition     = var.instances_per_subnet > 0 && var.instances_per_subnet <= 10
    error_message = "instances_per_subnet ha d'estar entre 1 i 10."
  }
}

variable "ami_name_pattern" {
  description = "Patró del nom de l'AMI d'Amazon Linux 2023"
  type        = string
  default     = "al2023-ami-2023.*-x86_64"
}

variable "subnets" {
  description = "Mapa de subxarxes: clau => nom i bloc CIDR"
  type = map(object({
    name       = string
    cidr_block = string
  }))

  default = {
    a = {
      name       = "subnet-a"
      cidr_block = "10.0.32.0/25"
    }
    b = {
      name       = "subnet-b"
      cidr_block = "10.0.30.0/23"
    }
    c = {
      name       = "subnet-c"
      cidr_block = "10.0.33.0/28"
    }
  }

  validation {
    condition = alltrue([
      for subnet in values(var.subnets) : can(cidrhost(subnet.cidr_block, 0))
    ])
    error_message = "Totes les subxarxes han de tenir un bloc CIDR IPv4 vàlid."
  }
}
