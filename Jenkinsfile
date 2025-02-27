pipeline {
    agent any
    environment {
        LINODE_TOKEN = credentials('linode-api-token') // Store in Jenkins credentials
        SSH_KEY = credentials('linode-ssh-key')       // Store private key
    }
    stages {
        stage('Deploy Linode') {
            steps {
                sh '''
                    linode-cli linodes create \
                        --region us-east \
                        --type g6-standard-1 \
                        --image linode/ubuntu22.04 \
                        --user-data "$(cat user-data.yml)" \
                        --authorized-keys "$(cat $SSH_KEY.pub)" \
                        --text --no-headers
                '''
                // Capture the IP from output if needed
            }
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/Ben-levi/jenkins_job.git', branch: 'main'
            }
        
        
        stage('Install Terraform') {
            steps {
                sh '''
                    curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo tee /etc/apt/trusted.gpg.d/hashicorp.gpg > /dev/null
                    sudo chmod 644 /etc/apt/trusted.gpg.d/hashicorp.gpg
                    apt-get update && apt-get install -y terraform
                '''
            }
        }
        
        stage('Terraform Version') {
            steps {
                sh 'terraform --version'
            }
        }
        
        stage('Terraform Init') {
            steps {
                sh 'terraform init'
            }
        }
        
        stage('Terraform Plan') {
            steps {
                sh 'terraform plan -out=tfplan'
                archiveArtifacts artifacts: 'tfplan', allowEmptyArchive: true
            }
        }
        
        stage('Approve Terraform Apply') {
            steps {
                input message: 'Approve Terraform Apply?', ok: 'Apply'
            }
        }
        
        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -auto-approve tfplan'
            }
        }
        
        stage('Install Ansible') {
            steps {
                sh '''
                    apt-get update
                    apt-get install -y software-properties-common
                    add-apt-repository --yes --update ppa:ansible/ansible
                    apt-get install -y ansible
                '''
            }
        }
        
        stage('Ansible Version') {
            steps {
                sh 'ansible --version'
            }
        }
        
        stage('Ansible Configuration') {
            steps {
                dir('ansible') {
                    sh 'ansible-playbook -i inventory playbook.yml'
                }
            }
        }
    }
    post {
        always {
            cleanWs() // Clean workspace after run
        }
        success {
            echo 'Infrastructure deployed and configured successfully!'
        }
        failure {
            echo 'Pipeline failed. Check logs for details.'
        }
    }
}
