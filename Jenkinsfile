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

        stage('Login to GHCR') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'ghcr-credentials',
                    usernameVariable: 'GHCR_USER',
                    passwordVariable: 'GHCR_TOKEN'
                )]) {
                    bat 'echo %GHCR_TOKEN% | docker login ghcr.io -u %GHCR_USER% --password-stdin'
                }
            }
        }

        stage('Push to GHCR') {
            steps {
                bat 'docker tag devops-cicd-app:%BUILD_NUMBER% ghcr.io/supriya-latha-ananthan/devops-cicd-app:%BUILD_NUMBER%'
                bat 'docker push ghcr.io/supriya-latha-ananthan/devops-cicd-app:%BUILD_NUMBER%'
            }
        }

    }
}