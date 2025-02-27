pipeline {
    agent any
    environment {
        LINODE_TOKEN = credentials('jenkins') // Stored in Jenkins credentials
    }
    stages {
        stage('Checkout Code') {
            steps {
                git url: 'https://github.com/Ben-levi/jenkins_job.git', branch: 'main'
            }
        }
        
        stage('Terraform Init') {
            steps {
                dir('terraform') {
                    sh 'terraform init'
                }
            }
        }
        
        stage('Terraform Plan') {
            steps {
                dir('terraform') {
                    sh 'terraform plan -out=tfplan'
                    archiveArtifacts artifacts: 'terraform/tfplan', allowEmptyArchive: true
                }
            }
        }
        
        stage('Approve Terraform Apply') {
            steps {
                input message: 'Approve Terraform Apply?', ok: 'Apply'
            }
        }
        
        stage('Terraform Apply') {
            steps {
                dir('terraform') {
                    sh 'terraform apply -auto-approve tfplan'
                }
            }
        }
        
        stage('Ansible Configuration') {
            steps {
                dir('ansible') {
                    // Dynamically generate inventory from Terraform outputs if needed
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
