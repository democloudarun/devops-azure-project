pipeline {
    agent any

    stages {
        stage('Declarative: Checkout SCM') {
            steps {
                echo 'Checking out code from SCM...'
                checkout scm
            }
        }

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
    }
}
