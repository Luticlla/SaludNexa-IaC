# SaludNexa Perú - Terraform Core
## Diagrama de AWSS


## Estructura

```text
.
├── .github/
│   └── workflows/
│       ├── validacion-pull-requests.yml
│       └── despliegue-development.yml
├── envs/dev/
│   ├── main.tf
│   ├── outputs.tf
│   ├── variables.tf
│   ├── versions.tf
│   ├── providers.tf
│   ├── terraform.tfvars.example
│   ├── backend.hcl.example
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
| `aws_region` | `string` | `"us-east-2"` | Región AWS del core. |
| `project` | `string` | `"SaludNexa"` | Nombre del proyecto usado como prefijo y en tags. |
| `environment` | `string` | `"dev"` | Nombre del entorno. |
| `vpc_cidr` | `string` | `"10.0.0.0/16"` | CIDR de la VPC. |
| `availability_zones` | `object` | `{ primary = "us-east-2a", secondary = "us-east-2b" }` | AZ primaria y AZ secundaria requerida por el ALB. |
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

## Estado remoto (backend S3)

El entorno `dev` usa un backend S3 con configuración parcial: `envs/dev/versions.tf` declara `backend "s3" {}` y los valores se pasan al inicializar. El estado se guarda en el bucket `saludnexa-bucket`, con la clave `saludnexa/dev/terraform.tfstate`, en la región `us-east-2`, cifrado y con bloqueo nativo de S3 (`use_lockfile = true`), que evita dos `apply` simultáneos.

- `envs/dev/backend.hcl.example` es la plantilla versionada. `backend.hcl` está en `.gitignore` y no debe subirse.
- La clave está fijada por la política del rol de IAM de despliegue: no la cambies.

Para trabajar en local:

```bash
cd envs/dev
cp backend.hcl.example backend.hcl
# edita backend.hcl y coloca tu bucket en el marcador REEMPLAZAR_POR_TU_BUCKET
terraform init -backend-config=backend.hcl
```

## Despliegue

```bash
cd /ruta/al/repositorio
terraform fmt -check -recursive

cd envs/dev
cp terraform.tfvars.example terraform.tfvars
cp backend.hcl.example backend.hcl
terraform init -backend-config=backend.hcl
terraform validate
terraform plan
terraform apply
```

Revisa el plan antes de aplicar.

## Despliegue con GitHub Actions y OIDC

El repositorio se despliega con GitHub Actions usando OpenID Connect: el workflow intercambia un token efímero por credenciales temporales del rol de IAM. No hay access keys ni secretos de AWS en el repositorio.

- Rama de despliegue: `development`. El ambiente `dev` de GitHub solo acepta esa rama.
- Ambiente de GitHub: `dev`, con el workflow de despliegue asociado.
- Variables del ambiente `dev` (se leen con `vars.`):

| Variable | Valor |
| --- | --- |
| `AWS_REGION` | `us-east-2` |
| `AWS_ROLE_ARN` | ARN del rol de IAM que confía en el proveedor OIDC |
| `TF_STATE_BUCKET` | `saludnexa-bucket` |

Flujo de trabajo:

1. Un pull request hacia `development` ejecuta `validacion-pull-requests.yml`: `terraform fmt -check -recursive`, `terraform init -backend=false` y `terraform validate`. No asume ningún rol de AWS.
2. Un push a `development` ejecuta `despliegue-development.yml`: asume el rol con OIDC, inicializa el backend S3 con `TF_STATE_BUCKET`, valida, genera el plan y lo aplica. `concurrency` impide que dos despliegues corran a la vez.

## Costo y limpieza

- El costo de mantener el stack encendido es aproximado y depende de la región y del uso: NAT Gateway, ALB, tareas Fargate y almacenamiento del estado son los conceptos que más pesan. No hay cifras fijas en este documento.
- Ejecuta `terraform destroy` al terminar y crea un presupuesto de 1 USD en AWS Budgets para detectar consumos inesperados.
- Se requiere una cuenta con permiso para crear roles IAM y con acceso a `us-east-2`. AWS Academy Learner Lab no sirve para este despliegue.
- El estado vive en S3, así que cualquiera con el rol y el `backend.hcl` puede operar; el bloqueo nativo evita ejecuciones simultáneas. Aun así, coordina quién aplica y quién destruye.

## Alarmas

- Cada servicio tiene una alarma de CPU al 80 % sostenida durante 5 periodos de 60 segundos.
- El ALB tiene una alarma de tasa de errores 5xx (ALB y target) al 0,1 % durante 2 periodos de 300 segundos.
- Las alarmas no tienen acciones por defecto. La variable `alarm_actions` permite conectar ARNs de SNS existentes.
