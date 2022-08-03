# importing necessary modules
import requests
import os
import boto3

def lambda_handler(event, context):   
    
    def upload_to_aws(local_file, bucket, s3_file):
        s3 = boto3.client('s3')
    
        try:
            s3.upload_file(local_file, bucket, s3_file)
            print("Upload Successful")
            return True
        except FileNotFoundError:
            print("The file was not found")
            return False
        except NoCredentialsError:
            print("Credentials not available")
            return False


    def getParameter(param_name):
        """
        This function reads a secure parameter from AWS' SSM service.
        The request must be passed a valid parameter name, as well as 
        temporary credentials which can be used to access the parameter.
        The parameter's value is returned.
        """
        # Create the SSM Client
        ssm = boto3.client('ssm',
            region_name = AWS_REGION
        )

        # Get the requested parameter
        response = ssm.get_parameters(
            Names=[
                param_name,
            ],
            WithDecryption=True
        )
        
        # Store the credentials in a variable
        credentials = response['Parameters'][0]['Value']

        return credentials


    def run_fargate_task():
        client = boto3.client('ecs')
        print("Running task.")
        response = client.run_task(
            cluster=ECS_CLUSTER, 
            launchType='FARGATE',
            taskDefinition=ECS_TASK_DEFINITION,  # <-- notice no revision number
            count=1,
            platformVersion='LATEST',
            networkConfiguration={
                'awsvpcConfiguration': {
                    'subnets': [
                        ECS_SUBNET1,
                        ECS_SUBNET2
                    ],
                    'securityGroups': [
                        ECS_SECURITY_GROUP
                    ],
                    'assignPublicIp': 'DISABLED'
                }
            })
        print("Finished invoking task.")
    
        return str(response)

    # Setting up variables
    print("Setting up environment variables")
    AWS_REGION = 'us-east-1'
    S3_BUCKET = getParameter('/cde/S3_BUCKET_DATASETS')
    ECS_CLUSTER = getParameter('/cde/ECS_CLUSTER')
    ECS_TASK_DEFINITION = getParameter('/cde/ECS_CLUSTER')
    ECS_SUBNET1 = getParameter('/cde/ECS_SUBNET1')
    ECS_SUBNET2 = getParameter('/cde/ECS_SUBNET2')
    ECS_SECURITY_GROUP = getParameter('/cde/ECS_SECURITY_GROUP')

    source_uris={
        'provincias':'https://infra.datos.gob.ar/catalog/modernizacion/dataset/7/distribution/7.7/download/provincias.csv',
        'departamentos':'https://infra.datos.gob.ar/catalog/modernizacion/dataset/7/distribution/7.8/download/departamentos.csv',
        'Covid19Casos':'https://sisa.msal.gov.ar/datos/descargas/covid-19/files/Covid19Casos.zip'
    }

    for key, url in source_uris.items():
        print(f'Downloading {key} ...')

        # Downloading the file by sending the request to the URL
        req = requests.get(url)
    
        # Split URL to get the file name
        filename = url.split('/')[-1]
        filepath = '/tmp/' + filename


        # Writing the file to the local file system
        with open(filepath,'wb') as output_file:
            output_file.write(req.content)
            print('Downloading Completed')

        local_file = filepath
        s3_file = filename

        uploaded = upload_to_aws(local_file, S3_BUCKET, s3_file)
    
    run_fargate_task()
        