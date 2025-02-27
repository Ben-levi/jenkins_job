pipeline {
    agent any
    environment {
        LINODE_TOKEN = credentials('linode-api-token') // API token
        SSH_KEY = credentials('linode-ssh-key')       // Private key file
        SSH_PUB_KEY = credentials('linode-ssh-key')   // Public key (adjust ID if separate)
    }
    stages {
        stage('Deploy Linode') {
            steps {
                script {
                    // Deploy Linode and capture IP
                    def linodeOutput = sh(script: """
                        linode-cli linodes create \\
                            --region us-east \\
                            --type g6-standard-1 \\
                            --image linode/ubuntu22.04 \\
                            --user-data "\$(cat user-data.yml)" \\
                            --authorized-keys "\$(cat ${SSH_PUB_KEY}.pub)" \\
                            --text --no-headers --delimiter=","
                    """, returnStdout: true).trim()
                    env.LINODE_IP = linodeOutput.split(',')[3] // 4th field is IP
                    echo "Linode IP: ${env.LINODE_IP}"
                }
            }
        }
        stage('Wait for Linode Boot') {
            steps {
                sleep time: 60, unit: 'SECONDS' // Give cloud-init time to finish
            }
        }
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/Ben-levi/jenkins_job.git', branch: 'main'
            }
        }
        stage('Copy Files to Linode') {
            steps {
                sh """
                    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no automation-user@${LINODE_IP} 'mkdir -p ~/terraform ~/ansible'
                    scp -i ${SSH_KEY} -o StrictHostKeyChecking=no *.tf automation-user@${LINODE_IP}:~/terraform/
                    scp -i ${SSH_KEY} -o StrictHostKeyChecking=no -r ansible/* automation-user@${LINODE_IP}:~/ansible/
                """
            }
        }
        stage('Terraform Version') {
            steps {
                sh """
                    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no automation-user@${LINODE_IP} 'terraform --version'
                """
            }
        }
        stage('Terraform Init') {
            steps {
                sh """
                    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no automation-user@${LINODE_IP} 'cd ~/terraform && terraform init'
                """
            }
        }
        stage('Terraform Plan') {
            steps {
                sh """
                    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no automation-user@${LINODE_IP} 'cd ~/terraform && terraform plan -out=tfplan'
                """
                // Optionally copy tfplan back to Jenkins for archiving
                sh """
                    scp -i ${SSH_KEY} -o StrictHostKeyChecking=no automation-user@${LINODE_IP}:~/terraform/tfplan .
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
                    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no automation-user@${LINODE_IP} 'cd ~/terraform && terraform apply -auto-approve tfplan'
                """
            }
        }
        stage('Ansible Version') {
            steps {
                sh """
                    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no automation-user@${LINODE_IP} 'ansible --version'
                """
            }
        }
        stage('Ansible Configuration') {
            steps {
                sh """
                    ssh -i ${SSH_KEY} -o StrictHostKeyChecking=no automation-user@${LINODE_IP} 'cd ~/ansible && ansible-playbook -i inventory playbook.yml'
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
