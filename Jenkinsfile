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
        stage('Nettoyage Workspace') {
            steps {
                cleanWs()
                echo '✅ Workspace nettoyé'
            }
        }

        stage('Git Checkout') {
            steps {
                git branch: 'main', 
                    url: 'https://github.com/friguiwassim/wassim-frigui.git'
                echo '✅ Code récupéré depuis Git'
            }
        }

        stage('Nettoyage et Construction') {
            steps {
                sh '''
                    echo "=== Fichiers présents ==="
                    ls -la
                    echo "=== Contenu Dockerfile ==="
                    cat Dockerfile
                    echo "✅ Projet prêt pour le build"
                '''
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    echo "Construction de l'image Docker..."
                    docker build -t ${DOCKER_IMAGE}:v${BUILD_NUMBER} -t ${DOCKER_IMAGE}:latest .
                    echo "✅ Image Docker construite: ${DOCKER_IMAGE}:v${BUILD_NUMBER}"
                '''
            }
        }

        stage('Push to Docker Hub') {
            steps {
                sh '''
                    echo "Connexion à Docker Hub..."
                    echo "${DOCKER_CREDS_PSW}" | docker login -u "${DOCKER_CREDS_USR}" --password-stdin
                    
                    echo "Publication sur Docker Hub..."
                    docker push ${DOCKER_IMAGE}:v${BUILD_NUMBER}
                    docker push ${DOCKER_IMAGE}:latest
                    
                    echo "✅ Images publiées sur Docker Hub"
                '''
            }
        }
    }

    post {
        success {
            echo '� PIPELINE R��USSIE !'
            sh '''
                echo "========================================="
                echo "         PIPELINE CI/CD COMPLÉÈTE         "
                echo "========================================="
                echo "Build: #${BUILD_NUMBER}"
                echo "Image: ${DOCKER_IMAGE}:v${BUILD_NUMBER}"
                echo "Docker Hub: https://hub.docker.com/r/wassimfrigui/ci-cd-demo"
                echo "Test: docker run -p 8080:80 ${DOCKER_IMAGE}:latest"
                echo "========================================="
            '''
        }
        failure {
            echo '❌ Pipeline échouée - Vérifiez les logs'
        }
    }
}
