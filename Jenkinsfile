pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out Git repository...'
                checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [],
                    userRemoteConfigs: [[
                        url: 'https://github.com/democloudarun/devops-azure-project.git',
                        credentialsId: '5bf7bda2-4d08-4a39-bf8d-fca9b54b5b66'
                    ]]
                ])
            }
        }

        stage('Terraform Apply') {
            steps {
                withCredentials([
                    string(credentialsId: 'AZURE_CLIENT_ID', variable: 'AZURE_CLIENT_ID'),
                    string(credentialsId: 'AZURE_CLIENT_SECRET', variable: 'AZURE_CLIENT_SECRET'),
                    string(credentialsId: 'AZURE_TENANT_ID', variable: 'AZURE_TENANT_ID'),
                    string(credentialsId: 'AZURE_SUBSCRIPTION_ID', variable: 'AZURE_SUBSCRIPTION_ID'),
                    string(credentialsId: 'SSH_PUBLIC_KEY', variable: 'SSH_PUBLIC_KEY')
                ]) {
                    sh '''
                        echo "Logging into Azure with Service Principal..."
                        az login --service-principal -u $AZURE_CLIENT_ID -p $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID

                        echo "Verifying tools..."
                        az version
                        terraform version
                        docker version

                        echo "Running Terraform..."
                        cd terraform
                        terraform init
                        terraform apply -auto-approve \
                            -var="azure_subscription_id=${AZURE_SUBSCRIPTION_ID}" \
                            -var="azure_client_id=${AZURE_CLIENT_ID}" \
                            -var="azure_client_secret=${AZURE_CLIENT_SECRET}" \
                            -var="azure_tenant_id=${AZURE_TENANT_ID}" \
                            -var="ssh_public_key=${SSH_PUBLIC_KEY}"
                    '''
                }
            }
        }

        stage('Deploy App') {
            steps {
                withCredentials([
                    string(credentialsId: 'SSH_PUBLIC_KEY', variable: 'SSH_PUBLIC_KEY')
                ]) {
                    sh '''
                        # 1. Get the VM IP from Terraform output
                        VM_IP=$(cd terraform && terraform output -raw vm_public_ip)
                        
                        # 2. Build and Run the Docker container on the VM
                        # Note: We map HOST 8080 to CONTAINER 5000
                        ssh -o StrictHostKeyChecking=no azureuser@${VM_IP} << EOF
                            # Stop any existing containers to avoid port conflicts
                            sudo docker stop my-website || true
                            sudo docker rm my-website || true
                            
                            # Pull and Run your image (replace with your image)
                            sudo docker run -d --name my-website -p 8080:5000 <your-dockerhub-username>/<image-name>:latest
                        EOF
                    '''
                }
            }
        }
    }
}
