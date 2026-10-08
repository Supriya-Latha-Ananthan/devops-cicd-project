pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                bat 'docker build -t devops-cicd-app:%BUILD_NUMBER% .'
            }
        }

    }
}