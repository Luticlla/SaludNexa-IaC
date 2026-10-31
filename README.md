# SaludNexa Perú - Terraform Core
## Diagrama de AWS 


## Estructura

```text
.
├── envs/dev/
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   ├── versions.tf
│   ├── providers.tf
│   ├── terraform.tfvars.example
│   └── .terraform.lock.hcl
├── modules/
│   ├── network/
│   ├── security/
│   ├── iam/
│   ├── ecr/
│   ├── ecs/
│   └── alb/
├── README.md
├── .gitignore
└── .terraform-docs.yml
```

## Servicios

| Servicio | Ruta ALB | Puerto | CPU | Memoria | Mínimo | Máximo |
| --- | --- | --- | --- | --- | --- | --- |
| `citas-svc` | `/api/citas/*` | 80 | 512 | 1024 | 1 | 6 |
| `usuarios-svc` | `/api/usuarios/*` | 80 | 512 | 1024 | 1 | 4 |
| `pagos-svc` | `/api/pagos/*` | 80 | 512 | 1024 | 1 | 4 |
| `teleconsulta-svc` | `/api/teleconsulta/*` | 80 | 512 | 1024 | 1 | 4 |

Los cuatro servicios usan la imagen `public.ecr.aws/nginx/nginx:1.27-alpine` y el puerto `80`.

## Variables

| Variable | Tipo | Default | Descripción |
| --- | --- | --- | --- |
| `aws_region` | `string` | `"sa-east-1"` | Región AWS del core. |
| `project` | `string` | `"SaludNexa"` | Nombre del proyecto usado como prefijo y en tags. |
| `environment` | `string` | `"dev"` | Nombre del entorno. |
| `vpc_cidr` | `string` | `"10.0.0.0/16"` | CIDR de la VPC. |
| `availability_zones` | `object` | `{ primary = "sa-east-1a", secondary = "sa-east-1b" }` | AZ primaria y AZ secundaria requerida por el ALB. |
| `public_subnet_cidrs` | `object` | `{ a = "10.0.1.0/24", b = "10.0.2.0/24" }` | CIDR de las dos subredes públicas. |
| `app_subnet_cidr` | `string` | `"10.0.11.0/24"` | CIDR de la subred privada de aplicación. |
| `services` | `map(object)` | 4 servicios | Puerto, ruta, CPU, memoria y límites de autoescalado por servicio. |
| `container_image` | `string` | `"public.ecr.aws/nginx/nginx:1.27-alpine"` | Imagen usada por todas las task definitions. |
| `certificate_arn` | `string` | `""` | ARN ACM para HTTPS; si está vacío se crea HTTP 80 solo para pruebas. |
| `health_check_path` | `string` | `"/"` | Ruta de health check del ALB. |
| `health_check_matcher` | `string` | `"200-399"` | Códigos HTTP considerados sanos. |
| `log_retention_days` | `number` | `14` | Retención de los log groups de CloudWatch. |
| `ecr_image_retention_count` | `number` | `10` | Imágenes conservadas por el lifecycle de ECR. |
| `deployment_minimum_healthy_percent` | `number` | `100` | Porcentaje mínimo sano durante despliegues ECS. |
| `deployment_maximum_percent` | `number` | `200` | Porcentaje máximo de tareas durante despliegues ECS. |
| `cpu_target_value` | `number` | `60` | CPU objetivo del Target Tracking. |
| `scale_out_cooldown` | `number` | `60` | Cooldown de escala hacia arriba en segundos. |
| `scale_in_cooldown` | `number` | `300` | Cooldown de escala hacia abajo en segundos. |
| `cpu_alarm_threshold` | `number` | `80` | Umbral de CPU para la alarma sostenida. |
| `cpu_alarm_evaluation_periods` | `number` | `5` | Periodos de 60 segundos para disparar la alarma de CPU. |
| `alb_5xx_threshold_percent` | `number` | `0.1` | Porcentaje de errores 5xx del ALB que dispara la alarma. |
| `alb_5xx_evaluation_periods` | `number` | `2` | Periodos de 300 segundos para disparar la alarma 5xx. |
| `alarm_actions` | `list(string)` | `[]` | ARNs opcionales notificados por las alarmas. |
| `tags` | `map(string)` | `{}` | Tags adicionales fusionados con los tags comunes. |

## Despliegue

```bash
cd /ruta/al/repositorio
terraform fmt -check -recursive

cd envs/dev
cp terraform.tfvars.example terraform.tfvars
terraform init
terraform validate
terraform plan
terraform apply
```

Revisa el plan antes de aplicar.

## Costo y limpieza

- Mantener el stack encendido cuesta aproximadamente 0,40 USD por hora en `sa-east-1`; de ese monto, el NAT representa unos 0,093 USD por hora.
- Ejecuta `terraform destroy` al terminar y crea un presupuesto de 1 USD en AWS Budgets para detectar consumos inesperados.
- Se requiere una cuenta con permiso para crear roles IAM y con acceso a `sa-east-1`. AWS Academy Learner Lab no sirve para este despliegue.
- El estado es local, así que solo una persona debe ejecutar `apply` y `destroy`; nadie más debe trabajar en paralelo sobre el mismo entorno.

## Alarmas

- Cada servicio tiene una alarma de CPU al 80 % sostenida durante 5 periodos de 60 segundos.
- El ALB tiene una alarma de tasa de errores 5xx (ALB y target) al 0,1 % durante 2 periodos de 300 segundos.
- Las alarmas no tienen acciones por defecto. La variable `alarm_actions` permite conectar ARNs de SNS existentes.
