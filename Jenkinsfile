pipeline {
    agent any

    environment {
        // Define Docker image name
        IMAGE_NAME = "arun/flask-devops:latest"
    }

    stages {

        stage('Checkout') {
            steps {
                git url: 'https://github.com/democloudarun/devops-azure-project.git', credentialsId: 'GITHUB_CREDENTIALS'
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([azureServicePrincipal(credentialsId: 'AZURE_CREDENTIALS')]) {
                    sh '''
                    # Login to Azure using Service Principal
                    az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID

                    # Go to terraform folder
                    cd terraform

                    # Initialize Terraform
                    terraform init

                    # Create a plan
                    terraform plan -out=tfplan

                    # Apply the plan automatically
                    terraform apply -auto-approve tfplan

                    # Return to project root
                    cd ..
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "docker build -t $IMAGE_NAME -f docker/Dockerfile ."
            }
        }

        stage('Test Application') {
            steps {
                sh '''
                    # Install Python test dependencies
                    pip install flask pytest

                    # Run automated tests
                    pytest app/test_app.py
                '''
            }
        }

        stage('Deploy Application') {
            when {
                expression { currentBuild.currentResult == 'SUCCESS' }
            }
            steps {
                sh '''
                    # Run Ansible playbook to deploy Docker container on Azure VM
                    ansible-playbook -i ansible/inventory ansible/playbook.yml
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully! Website deployed."
        }
        failure {
            echo "Pipeline failed. Check logs to debug."
        }
    }
}

