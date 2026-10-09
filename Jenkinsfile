```groovy
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
                    if errorlevel 1 exit /b 1

                    icacls "%DEPLOY_KEY%" /grant:r "%USERNAME%:R"
                    if errorlevel 1 exit /b 1

                    ssh -i "%DEPLOY_KEY%" -o UserKnownHostsFile=C:/Windows/System32/config/systemprofile/.ssh/known_hosts -o StrictHostKeyChecking=yes %SSH_USER%@65.1.92.97 "sudo docker pull ghcr.io/supriya-latha-ananthan/devops-cicd-app:%BUILD_NUMBER%"
                    if errorlevel 1 exit /b 1

                    ssh -i "%DEPLOY_KEY%" -o UserKnownHostsFile=C:/Windows/System32/config/systemprofile/.ssh/known_hosts -o StrictHostKeyChecking=yes %SSH_USER%@65.1.92.97 "sudo docker rm -f devops-app || true"
                    if errorlevel 1 exit /b 1

                    ssh -i "%DEPLOY_KEY%" -o UserKnownHostsFile=C:/Windows/System32/config/systemprofile/.ssh/known_hosts -o StrictHostKeyChecking=yes %SSH_USER%@65.1.92.97 "sudo docker run -d --name devops-app --restart unless-stopped -p 5000:5000 ghcr.io/supriya-latha-ananthan/devops-cicd-app:%BUILD_NUMBER%"
                    if errorlevel 1 exit /b 1

                    del /Q "%DEPLOY_KEY%"
                    '''
                }
            }
        }
```