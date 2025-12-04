pipeline {
    agent any
    
    triggers {
        // Poll SCM toutes les minutes
        pollSCM('* * * * *')
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
                    def imageTag = "${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                    def latestTag = "${env.DOCKER_IMAGE_NAME}:latest"
                    
                    // Build avec tags
                    dockerImage = docker.build("${imageTag} --tag ${latestTag}")
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry("https://${env.DOCKER_REGISTRY}", env.DOCKERHUB_CREDENTIALS) {
                        dockerImage.push()
                        dockerImage.push('latest')
                    }
                }
            }
        }
        
        stage('Notification') {
            steps {
                echo "✅ Pipeline réussie !"
                echo "Image: ${env.DOCKER_IMAGE_NAME}:${env.BUILD_NUMBER}"
                echo "Docker Hub: https://hub.docker.com/r/wassimfrigui/wassim-frigui-app"
            }
        }
    }
}
