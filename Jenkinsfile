pipeline {
    agent any
    
    triggers {
        pollSCM('*/2 * * * *')  // Toutes les 2 minutes
    }
    
    environment {
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_USERNAME = 'wassimfrigui'
        DOCKER_IMAGE_NAME = 'wassimfrigui/wassim-frigui-app'
        BUILD_DATE = sh(script: 'date +"%Y-%m-%d %H:%M:%S"', returnStdout: true).trim()
        DOCKERHUB_CREDENTIALS = 'dockerhub-wassim'
    }
    
    stages {
        stage('Checkout Git') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[url: 'https://github.com/friguiwassim/wassim-frigui.git']]
                ])
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    // CORRECTION ICI : Séparer les tags correctement
                    def imageTag = "${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                    def latestTag = "${env.DOCKER_IMAGE_NAME}:latest"
                    
                    sh """
                        echo "Building Docker image..."
                        docker build -t ${imageTag} -t ${latestTag} .
                        echo "Images built: ${imageTag} and ${latestTag}"
                    """
                }
            }
        }
        
        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: env.DOCKERHUB_CREDENTIALS,
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "Logging in to Docker Hub..."
                        echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
                    '''
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    def imageTag = "${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                    def latestTag = "${env.DOCKER_IMAGE_NAME}:latest"
                    
                    sh """
                        echo "Pushing images to Docker Hub..."
                        docker push ${imageTag}
                        docker push ${latestTag}
                        echo "Images pushed successfully!"
                    """
                }
            }
        }
        
        stage('Notification') {
            steps {
                script {
                    def imageTag = "${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                    sh """
                        echo "✅ Pipeline CI/CD réussie !"
                        echo "================================="
                        echo "Build ID: ${env.BUILD_NUMBER}"
                        echo "Date: ${env.BUILD_DATE}"
                        echo "Image Docker: ${imageTag}"
                        echo "Docker Hub: https://hub.docker.com/r/wassimfrigui/wassim-frigui-app"
                        echo "Pour tester: docker run -p 5000:5000 ${imageTag}"
                        echo "================================="
                    """
                }
            }
        }
    }
    
    post {
        success {
            echo '� Pipeline r��ussie ! L image est sur Docker Hub.'
        }
        failure {
            echo 'é❌ Pipeline échouée. Vérifiez les logs.'
        }
    }
}
