pipeline {
    agent { label 'agent1' }   

    // This is the code repository where the pipeline will pull the Jenkinsfile
    environment {
        REPO_URL = 'https://github.com/Ben-levi/jenkins_job.git'
        BRANCH_NAME = 'main' // specify the branch name here
    }

    stages {
        stage('GitOps - Checkout Pipeline from Git') {
            steps {
                // Check out the Jenkinsfile from the specified Git repo
                git branch: "${BRANCH_NAME}", url: "${REPO_URL}"
            }
        }
        
        stage('Run Python Code') {
            when {
                expression { return params.DRY_RUN == false }
            }
            steps {
                // Execute the Python code and store the output in output.txt
                sh 'python3 main.py > output.txt'
            }
        }
    }
}
