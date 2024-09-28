pipeline {
    agent any

    parameters {
        string(name: 'action', defaultValue: 'plan', description: 'Terraform action to execute (e.g., plan, apply, destroy)')
    }
	
    environment {
        AWS_ACCESS_KEY_ID = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
    }

    stages {
        stage('Checkout') {
            steps {
                // Checkout code from GitHub repository
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/setor2211/frans1.git',
                    ]]
                ])
            }
        }
        stage('Terraform Init') {
            steps {
                // Initialize Terraform
                sh 'terraform init'
            }
        }
        stage('Terraform Action') {
            steps {
                echo "Terraform action is --> ${action}"
                sh "terraform ${action} -auto-approve"
            }
        }
    }
}
