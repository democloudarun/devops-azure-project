pipeline {
    agent {
        docker {
            image 'mcr.microsoft.com/azure-cli'  // Azure CLI pre-installed
            args '-v /var/run/docker.sock:/var/run/docker.sock'  // access host Docker
        }
    }

    environment {
        // Use the Azure Service Principal credentials saved in Jenkins
        AZURE_CREDENTIALS = credentials('AZURE_CREDENTIALS')
    }

    stages {

        stage('Terraform Apply') {
            steps {
                withCredentials([
                    azureServicePrincipal(
                        credentialsId: 'AZURE_CREDENTIALS'
                    )
                ]) {
                    sh '''
                    echo "Logging into Azure with Service Principal..."
                    az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID

                    echo "Applying Terraform..."
                    cd terraform
                    terraform init
                    terraform plan -out=tfplan
                    terraform apply -auto-approve tfplan
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                echo "Building Docker image for the website..."
                docker build -t arunwebsite:latest ./docker
                '''
            }
        }

        stage('Test Application') {
            steps {
                sh '''
                echo "Running Python unit tests..."
                python3 -m unittest app/test_app.py
                '''
            }
        }

        stage('Deploy Application') {
            steps {
                sh '''
                echo "Deploying website container..."
                docker stop arunwebsite || true
                docker rm arunwebsite || true
                docker run -d --name arunwebsite -p 80:5000 arunwebsite:latest
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully! Visit http://<YOUR_WSL_IP>:80 to see the website."
        }
        failure {
            echo "Pipeline failed. Check the logs above for errors."
        }
    }
}
