pipeline {
    agent any

    tools {
        jdk 'java17'
        maven 'maven3'
    }

    options {
        skipDefaultCheckout(true)
        disableConcurrentBuilds()
    }

    environment {
        GIT_CRED_ID = 'git-credential'
        APP_NAME = 'student-management'
        IMAGE_TAG = "v1.0.${BUILD_NUMBER}"
        CONTAINER_NAME = 'student-management-dev'
        DOCKER_NETWORK = 'studenthub-net'
    }

    stages {

        stage('Git Checkout') {
            steps {
                git branch: 'master',
                    credentialsId: "${GIT_CRED_ID}",
                    url: 'https://github.com/vivekbagde1203/student-management.git'
            }
        }

        stage('Compile Application') {
            steps {
                sh 'mvn clean compile'
            }
        }

        stage('Test Application') {
            steps {
                sh 'mvn test'
            }
        }

        stage('Package Application') {
            steps {
                sh 'mvn package -DskipTests'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t ${APP_NAME}:${IMAGE_TAG} .
                '''
            }
        }

        stage('Deploy Docker Container') {
            steps {
                withCredentials([
                    string(
                        credentialsId: 'studenthub-db-password',
                        variable: 'DB_PASSWORD'
                    )
                ]) {
                    sh '''
                        set -eu
                        set +x

                        docker network inspect ${DOCKER_NETWORK} >/dev/null
                        docker image inspect ${APP_NAME}:${IMAGE_TAG} >/dev/null

                        if docker container inspect ${CONTAINER_NAME} >/dev/null 2>&1; then
                            docker rm -f ${CONTAINER_NAME}
                        fi

                        docker run -d \
                            --name ${CONTAINER_NAME} \
                            --network ${DOCKER_NETWORK} \
                            -p 127.0.0.1:8082:8081 \
                            -e DB_URL=jdbc:postgresql://studenthub-db:5432/studenthub \
                            -e DB_USERNAME=studenthub \
                            -e DB_PASSWORD \
                            ${APP_NAME}:${IMAGE_TAG}
                    '''
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                sh '''
                    docker ps

                    curl --fail --show-error \
                        --retry 10 \
                        --retry-connrefused \
                        --retry-delay 3 \
                        --max-time 5 \
                        http://127.0.0.1:8082/
                '''
            }
        }
    }

    post {
        success {
            echo 'Application deployed successfully'
        }

        failure {
            echo 'Pipeline failed'
        }

        always {
            echo 'Pipeline execution completed'
        }
    }
}
