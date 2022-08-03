#!/usr/bin/env bash

# Put parameters into Parameter Store

aws ssm put-parameter \
  --name /cde/POSTGRES_USER \
  --type String \
  --value "postgres" \
  --description "Master Username for database" \
  --overwrite \
  --profile cde

aws ssm put-parameter \
  --name /cde/POSTGRES_PASSWORD \
  --type SecureString \
  --value "postgres123" \
  --description "Master Password for database" \
  --overwrite \
  --profile cde
  
aws ssm put-parameter \
  --name /cde/DB_DATABASE \
  --type String \
  --value "covid19" \
  --description "Database to use" \
  --overwrite \
  --profile cde

aws ssm put-parameter \
  --name /cde/DB_USER \
  --type String \
  --value "covid19_user" \
  --description "Database user" \
  --overwrite \
  --profile cde

aws ssm put-parameter \
  --name /cde/DB_PASS \
  --type SecureString \
  --value "covid19_pass" \
  --description "Database password" \
  --overwrite \
  --profile cde

aws ssm put-parameter \
  --name /cde/S3_BUCKET_DATASETS \
  --type String \
  --value "pipeline-covid19-datasets" \
  --description "S3 bucket to store datasets download from internet" \
  --overwrite \
  --profile cde

aws ssm put-parameter \
  --name /cde/S3_BUCKET_REPORT \
  --type String \
  --value "pipeline-covid19-reports" \
  --description "S3 bucket to store data pipeline reports" \
  --overwrite \
  --profile cde

aws ssm put-parameter \
  --name /cde/S3_BUCKET_LAMBDA \
  --type String \
  --value "pipeline-covid19-lambda-functions" \
  --description "S3 bucket Bucket to store the lambda function that runs the ECS task" \
  --overwrite \
  --profile cde

aws ssm put-parameter \
  --name /cde/ECS_CLUSTER \
  --type String \
  --value "data-pipeline-cluster" \
  --description "ECS Fargate Cluster" \
  --overwrite \
  --profile cde

  aws ssm put-parameter \
  --name /cde/ECS_TASK_DEFINITION \
  --type String \
  --value "data-pipeline-cluster" \
  --description "ECS Task Definition" \
  --overwrite \
  --profile cde
