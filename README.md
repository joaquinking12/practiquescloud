# practiquescloud

Repositori de pràctiques del mòdul **OPT · Cloud Computing** (ASIX2, INS Provençana).

## Contingut

| Pràctica | Carpeta | Descripció |
|---|---|---|
| **Pt1.4 · Exercici 1** | [`pt1-4-ex1/`](pt1-4-ex1/) | 2 instàncies EC2 `t3.micro` amb Amazon Linux 2023 a `us-east-1`, creades amb Terraform. |
| **Pt1.4 · Exercici 2** | [`pt1-4-ex2/`](pt1-4-ex2/) | VPC `10.0.0.0/16`, 3 subxarxes a `us-east-1a` i 6 instàncies EC2 (2 per subxarxa). Desplegament per consola i amb Terraform. |

```text
practiquescloud/
├── pt1-4-ex1/
│   ├── assets/
│   │   ├── topologia.drawio
│   │   ├── topologia.png
│   │   ├── aws_ec2_instances.png
│   │   └── aws_instance_details.png
│   ├── README.md
│   └── main.tf
└── pt1-4-ex2/
    ├── assets/
    │   ├── topologia.drawio
    │   ├── topologia.png
    │   ├── aws_vpc_list.png
    │   ├── aws_vpc_details.png
    │   ├── vpc_subnets.png
    │   ├── ec2_instances.png
    │   └── aws_instance_details.png
    ├── README.md
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

## Requisits

- Terraform `>= 1.5.0`.
- Compte d'**AWS Academy Learner Lab** actiu.
- Credencials temporals a `~/.aws/credentials` (amb `aws_session_token`).
- Opcionalment, AWS CLI v2.

## Execució ràpida

Cada exercici és un projecte Terraform independent. Cal entrar a la seva carpeta:

```bash
cd pt1-4-ex1
terraform init
terraform plan
terraform apply
```

```bash
cd pt1-4-ex2
terraform init
terraform plan
terraform apply
```

Per eliminar els recursos:

```bash
terraform destroy
```

> Les credencials del Learner Lab caduquen en aturar o reiniciar el laboratori. Si apareix `ExpiredToken`, torna a copiar-les a `~/.aws/credentials`.

## Evidències

Els README de cada exercici inclouen el pas a pas, els diagrames de topologia (draw.io + PNG) i **captures reals de la consola d'AWS** del desplegament:

- Exercici 1: llistat de les 2 instàncies i detall d'una instància.
- Exercici 2: VPC, mapa de recursos, les 3 subxarxes amb CIDR i AZ, les 6 instàncies en execució i detall d'una instància.

## Autor

Joaquim Richard Poma Mamani — ASIX2, curs 2026-2027.
