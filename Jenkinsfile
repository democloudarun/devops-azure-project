pipeline {
    agent any

    environment {
        TF_IN_AUTOMATION = "true"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([
                    azureServicePrincipal(credentialsId: 'AZURE_CREDENTIALS')
                ]) {
                    sh '''
                        echo "Logging into Azure with Service Principal..."
                        az login --service-principal \
                          -u "$AZURE_CLIENT_ID" \
                          -p "$AZURE_CLIENT_SECRET" \
                          --tenant "$AZURE_TENANT_ID"

                        echo "Verifying tools..."
                        az version
                        terraform version
                        docker version

                        echo "Running Terraform..."
                        cd terraform
                        terraform init
                        terraform apply -auto-approve \
                            -var="ssh_public_key=${SSH_PUBLIC_KEY}"
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "Building Docker image..."
                    docker build -t arunwebsite:latest ./docker
                '''
            }
        }

        stage('Test Application') {
            steps {
                sh '''
                    echo "Running unit tests..."
                    python3 -m unittest app/test_app.py
                '''
            }
        }

        stage('Deploy Application') {
            steps {
                sh '''
                    echo "Deploying application..."
                    docker stop arunwebsite || true
                    docker rm arunwebsite || true
                    docker run -d \
                      --name arunwebsite \
                      -p 80:5000 \
                      arunwebsite:latest
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline completed successfully"
        }
        failure {
            echo "Pipeline failed. Check logs above."
        }
    }
}

