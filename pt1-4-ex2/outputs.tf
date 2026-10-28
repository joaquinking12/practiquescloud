output "vpc_id" {
  description = "ID de la VPC creada"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "Bloc CIDR de la VPC"
  value       = aws_vpc.this.cidr_block
}

output "subnet_ids" {
  description = "IDs de les subxarxes, indexats per la clau del mapa de variables"
  value = {
    for key, subnet in aws_subnet.this : key => subnet.id
  }
}

output "subnet_cidr_blocks" {
  description = "Blocs CIDR de les subxarxes, indexats per la clau del mapa de variables"
  value = {
    for key, subnet in aws_subnet.this : key => subnet.cidr_block
  }
}

output "instance_ids" {
  description = "IDs de les instàncies EC2"
  value = {
    for key, instance in aws_instance.this : key => instance.id
  }
}

output "instance_private_ips" {
  description = "IPs privades de les instàncies EC2"
  value = {
    for key, instance in aws_instance.this : key => instance.private_ip
  }
}

output "instance_summary" {
  description = "Resum de cada instància: nom, IP privada i subxarxa"
  value = {
    for key, instance in aws_instance.this : key => {
      name       = instance.tags["Name"]
      private_ip = instance.private_ip
      subnet_id  = instance.subnet_id
    }
  }
}
