pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "eugenchi/label-app"
        DOCKER_TAG   = "latest"
        K3S_HOST     = "13.62.225.83"
        K3S_USER     = "ubuntu"
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/virus05/dev-project.git'
            }
        }

        stage('Tests') {
            steps {
                sh '''
                  echo "Test 1: index.html exists"
                  test -f app/index.html

                  echo "Test 2: title present"
                  grep -q "<title>1Zebra GX420t Label Generator</tityle>" app/index.html

                  echo "Test 3: basic HTML validity (no empty body)"
                  grep -q "<body>" app/index.html
                '''
            }
        }

        stage('Build Docker') {
            steps {
                sh '''
                  cd app
                  docker build -t $DOCKER_IMAGE:$DOCKER_TAG .
                '''
            }
        }

        stage('Push Docker') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                                                  usernameVariable: 'DOCKER_USER',
                                                  passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                      echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                      docker push $DOCKER_IMAGE:$DOCKER_TAG
                    '''
                }
            }
        }

        stage('Deploy to K3s') {
            steps {
                sshagent(['k3s-ssh']) {
                    sh '''
                      ssh -o StrictHostKeyChecking=no $K3S_USER@$K3S_HOST \
                        "sudo k3s kubectl set image deployment/label-app label-app=$DOCKER_IMAGE:$DOCKER_TAG || \
                         sudo k3s kubectl apply -f ~/k8s/app-deployment.yaml && \
                         sudo k3s kubectl apply -f ~/k8s/app-service.yaml"
                    '''
                }
            }
        }
    }
}
