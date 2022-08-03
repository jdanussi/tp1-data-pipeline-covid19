# Data pipeline Covid19 utilizando AWS ECS Fargate, RDS, Lambda, EventBridge, ECR, S3 y CloudWatch
<br>

## Resumen

Se adapto el data pipeline presentado en el TP final de foundations para que corra en AWS ECS, con tareas de tipo Fargate pero utilizando una RDS PostgreSQL como base de datos.
Se expone a continuación la topología de red utilizada.
<br><br>  

![diagrama](images/data-pipeline-covid19-topology.png)  

<br>

## Descripción de la aplicación

- Diariamente a las 22.00 hs se invoca una función **Lambda** desde **EventBridge** que hace el download de algunos datasets que publica el gobierno argentino sobre Covid19 y los almacena en un bucket **S3**. <br> 
- La función, luego de completar el download, corre una tarea de **ECS Fargate** que transforma los datasets de manera conveniente y los carga en tablas de una base **RDS** PostgreSQL. Tanto el cluster como la definición de la tarea ya existen en ECS, la función Lambda solo los invoca.<br>
- La tarea de ECS Fargate hace un upload del reporte generado en otro bucket S3.
- La definición de la tarea de Fargate incluye imágenes de contenedores almacenadas en **ECR**.
- Los logs de la tarea Fargate se almacenan en Log Groups de **CloudWatch**.
- Se agregó un bastion host en la capa pública para poder acceder de manera segura a la base de datos desde fuera de la VPC.

<br>

## Topología de red utilizada

- Se incluyen 2 zonas de disponibilidad para que la solución sea de alta disponibilidad.

- Se estructura la solución en 3 capas:
    - **Capa pública:** public-tier (sobre subnets públicas)<br>
        Bastion host sobre un grupo de auto escalado sin balanceador conpuesto por 1 sola instancia ec2 (Mínimo/Máximo/Deseado). El grupo de autoescalado esta seteado sobre 2 subnets / AZs.
    - **Capa de aplicación:** app-tier (sobre subnets privadas)<br>
        Cluster ECS Fargate sobre 2 subnets / AZs.
    - **Capa de base de datos:** db-tier (sobre subnets privadas)<br>
        RDS con la opción Multi-AZ habilitada.

- Se implementan varios VPC Endpoints (los mínimos necesarios) para que la capa de aplicación pueda correr con éxito:
    - S3 endpoint para bajar/subir archivos de/a los buckets.
    - ECR-dkr y ECR-api para poder consultar/obtener desde el registro las imágenes de los contenedores.
    - Cloudwatch-logs para poder subir los logs de la corrida a Cloudwatch.

<br>

## Algunas imágenes

### S3
Buckets que se utilizan:
![s3-buckets](images/s3-00-buckets.png)

<br>

Bucket donde Labmda almacena los datasets tras la descarga:
![s3-datasets](images/s3-01-datasets.png)

<br>

Bucket donde se guarda el archivo con las variables de entorno (el archivo que se ve en la imagen no esta en este repositorio. Se omite con .gitignore para no exponer credenciales):
![s3-envs](images/s3-02-envs.png)

<br>

Bucket donde ECS Fargate guarda los reportes generados:
![s3-reports](images/s3-03-reportes.png)

<br><br>

### Bastion Host
Acceso a base de datos desde equipo externo haciendo un Local Port Forwarding sobre ssh:
![ssh-01](images/ssh-forward-01.png)

![ssh-02](images/ssh-forward-02.png)

Nota: La IP Pública del bastión host hay que buscarla en la consola de AWS. Se puede resolver el inconveniente implementando un balancedor para el grupo de auto escalado ya que conserva siempre el mismo DNS name.

<br><br>

### Logs

Log de la última corrida de Lambda:
![logs-etl](images/log-00-lambda.png)

<br>

Log de la última corrida de la tarea de etl:
![logs-etl](images/log-01-etl.png)

<br>

Log de la última corrida de la tarea de reporte:
![logs-reports](images/log-02-report.png)

