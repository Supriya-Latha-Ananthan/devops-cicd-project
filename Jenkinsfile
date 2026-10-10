
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
                withCredentials([
                    usernamePassword(
                        credentialsId: 'ghcr-credentials',
                        usernameVariable: 'GHCR_USER',
                        passwordVariable: 'GHCR_TOKEN'
                    )
                ]) {
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

        stage('Deploy to EC2') {
            steps {
                withCredentials([
                    sshUserPrivateKey(
                        credentialsId: 'ec2-ssh-key',
                        keyFileVariable: 'SSH_KEY',
                        usernameVariable: 'SSH_USER'
                    )
                ]) {
                    bat '''
                    set "DEPLOY_KEY=%WORKSPACE%\\deploy_key.tmp"

                    copy /Y "%SSH_KEY%" "%DEPLOY_KEY%" >nul
                    if errorlevel 1 exit /b 1

                    icacls "%DEPLOY_KEY%" /inheritance:r
                    if errorlevel 1 goto deploy_failed

                    icacls "%DEPLOY_KEY%" /grant:r "SYSTEM:F"
                    if errorlevel 1 goto deploy_failed

                    ssh -i "%DEPLOY_KEY%" -o UserKnownHostsFile=C:/Windows/System32/config/systemprofile/.ssh/known_hosts -o StrictHostKeyChecking=yes %SSH_USER%@65.1.92.97 "TOKEN=$(aws ssm get-parameter --name /devops/ghcr/token --with-decryption --query Parameter.Value --output text --region ap-south-1) && echo \"$TOKEN\" | sudo docker login ghcr.io -u Supriya-Latha-Ananthan --password-stdin && unset TOKEN"
                    if errorlevel 1 goto deploy_failed

                    ssh -i "%DEPLOY_KEY%" -o UserKnownHostsFile=C:/Windows/System32/config/systemprofile/.ssh/known_hosts -o StrictHostKeyChecking=yes %SSH_USER%@65.1.92.97 "sudo docker pull ghcr.io/supriya-latha-ananthan/devops-cicd-app:%BUILD_NUMBER%"
                    if errorlevel 1 goto deploy_failed

                    ssh -i "%DEPLOY_KEY%" -o UserKnownHostsFile=C:/Windows/System32/config/systemprofile/.ssh/known_hosts -o StrictHostKeyChecking=yes %SSH_USER%@65.1.92.97 "sudo docker rm -f devops-app || true"
                    if errorlevel 1 goto deploy_failed

                    ssh -i "%DEPLOY_KEY%" -o UserKnownHostsFile=C:/Windows/System32/config/systemprofile/.ssh/known_hosts -o StrictHostKeyChecking=yes %SSH_USER%@65.1.92.97 "sudo docker run -d --name devops-app --restart unless-stopped -p 5000:5000 ghcr.io/supriya-latha-ananthan/devops-cicd-app:%BUILD_NUMBER%"
                    if errorlevel 1 goto deploy_failed

                    del /Q "%DEPLOY_KEY%"
                    exit /b 0

                    :deploy_failed
                    del /Q "%DEPLOY_KEY%"
                    exit /b 1
                    '''
                }
            }
        }
    }
}
