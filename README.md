# Data pipeline Covid19 con AWS ECS Fargate
<br>

## Resumen
Data pipeline organizado como una aplicación de alta disponibilidad en 3 capas - capa pública, capa de aplicación y capa de base de datos - que periódicamente extrae datos de una fuente pública, los transforma y los carga en un base PostgreSQL, dejando disponible un dashboard de análisis sobre Metabase que se utiliza como solución de reporting.<br>
Se implementa CI/CD con Github Actions para realizar el build y registro de la imágen docker del ETL en Elastic Container Registry (ECR), utilizada luego por el servicio de ECS fargate para ejecutar la tarea.<br>
Se utiliza Cloudformation para realizar gran parte del despliegue de la infraestructura.<br>
Se expone a continuación la topología de red utilizada.
<br><br>  

![diagrama](images/data-pipeline-covid19-topology.png)  

<br>

## Descripción de la aplicación

Capa Pública: 


- Periodicamente se invoca una función **Lambda** desde **EventBridge** que hace el download de algunos datasets que publica el gobierno argentino sobre Covid19 y los almacena en un bucket **S3**. La periodicidad dependerá de la frecuencia de actualización del dataset.<br> 
- La función, luego de completar el download, corre una tarea de **ECS Fargate** que transforma los datasets de manera conveniente y los carga en tablas de una base **RDS** PostgreSQL. Tanto el cluster como la definición de la tarea ya existen en ECS, la función Lambda solo los invoca y setea algunos parámetros necesarios para la corrida.<br>
- Se deplegaron 2 instancias RDS, una de tipo *master* que permite lectura/escritura y otra de tipo *replica* que solo permite operaciones de lectura (Analitics). La instancia master recibe los datos del proceso ETL y los registros necesarios para el backend de Metabase. La instancia tipo replica es la que está conectada a Metabase para exponer los análisis y dashboards generados.
- La definición de la tarea de Fargate incluye una imágen docker almacenada en **ECR**.
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

