pipeline {
    agent any

    triggers {
        pollSCM('*/2 * * * *')
    }

    environment {
        DOCKER_IMAGE = 'wassimfrigui/ci-cd-demo'
        DOCKER_CREDS = credentials('dockerhub-wassim')
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
                echo 'Workspace cleaned'
            }
        }

        stage('Git Checkout') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/friguiwassim/wassim-frigui.git'
                echo 'Code retrieved from Git'
            }
        }

        stage('Clean and Build') {
            steps {
                sh '''
                    echo "=== Files in project ==="
                    ls -la
                    echo "Project ready for build"
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                    echo "Building Docker image..."
                    docker build -t ${DOCKER_IMAGE}:v${BUILD_NUMBER} -t ${DOCKER_IMAGE}:latest .
                    echo "Docker image built: ${DOCKER_IMAGE}:v${BUILD_NUMBER}"
                '''
            }
        }

        stage('Docker Push') {
            steps {
                sh '''
                    echo "Logging to Docker Hub..."
                    echo "${DOCKER_CREDS_PSW}" | docker login -u "${DOCKER_CREDS_USR}" --password-stdin
                    
                    echo "Pushing to Docker Hub..."
                    docker push ${DOCKER_IMAGE}:v${BUILD_NUMBER}
                    docker push ${DOCKER_IMAGE}:latest
                    
                    echo "Images pushed to Docker Hub"
                '''
            }
        }
    }

    post {
        success {
            echo 'PIPELINE SUCCESS!'
            sh '''
                echo "========================================"
                echo "        CI/CD PIPELINE COMPLETE         "
                echo "========================================"
                echo "Build: #${BUILD_NUMBER}"
                echo "Image: ${DOCKER_IMAGE}:v${BUILD_NUMBER}"
                echo "Docker Hub: https://hub.docker.com/r/wassimfrigui/ci-cd-demo"
                echo "Test: docker run -p 8080:80 ${DOCKER_IMAGE}:latest"
                echo "========================================"
            '''
        }
        failure {
            echo 'Pipeline failed - Check logs'
        }
    }
}
