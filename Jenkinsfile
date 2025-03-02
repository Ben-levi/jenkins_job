pipeline {
    agent any
    environment {
        LINODE_IP = '172.233.32.56' // Replace with your Linode's public IP
        SSH_KEY = credentials('linode-ssh-key') // Private key from Jenkins credentials
        LINODE_USER = 'automation-user' // Adjust to 'root' if your key is for root
    }
    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/Ben-levi/jenkins_job.git', branch: 'main'
            }
        }
        stage('Copy Files to Linode') {
            steps {
                sh """
                    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${LINODE_USER}@${LINODE_IP} 'mkdir -p ~/terraform ~/ansible'
                    scp -i ${SSH_KEY} -o StrictHostKeyChecking=no *.tf ${LINODE_USER}@${LINODE_IP}:~/terraform/
                    scp -i ${SSH_KEY} -o StrictHostKeyChecking=no -r ansible/* ${LINODE_USER}@${LINODE_IP}:~/ansible/
                """
            }
        }
        stage('Terraform Version') {
            steps {
                sh """
                    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${LINODE_USER}@${LINODE_IP} 'terraform --version'
                """
            }
        }
        stage('Terraform Init') {
            steps {
                sh """
                    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${LINODE_USER}@${LINODE_IP} 'cd ~/terraform && terraform init'
                """
            }
        }
        stage('Terraform Plan') {
            steps {
                sh """
                    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${LINODE_USER}@${LINODE_IP} 'cd ~/terraform && terraform plan -out=tfplan'
                """
                sh """
                    scp -i ${SSH_KEY} -o StrictHostKeyChecking=no ${LINODE_USER}@${LINODE_IP}:~/terraform/tfplan .
                    archiveArtifacts artifacts: 'tfplan', allowEmptyArchive: true
                """
            }
        }
        stage('Approve Terraform Apply') {
            steps {
                input message: 'Approve Terraform Apply?', ok: 'Apply'
            }
        }
        stage('Terraform Apply') {
            steps {
                sh """
                    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${LINODE_USER}@${LINODE_IP} 'cd ~/terraform && terraform apply -auto-approve tfplan'
                """
            }
        }
        stage('Ansible Version') {
            steps {
                sh """
                    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${LINODE_USER}@${LINODE_IP} 'ansible --version'
                """
            }
        }
        stage('Ansible Configuration') {
            steps {
                sh """
                    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no ${LINODE_USER}@${LINODE_IP} 'cd ~/ansible && ansible-playbook -i inventory playbook.yml'
                """
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
