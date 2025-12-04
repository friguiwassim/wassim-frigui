pipeline {
    agent any
    
    environment {
        // Configuration Docker
        DOCKER_REGISTRY = 'docker.io'
        DOCKER_USERNAME = 'wassimfrigui'
        DOCKER_IMAGE_NAME = 'wassimfrigui/wassim-frigui-app'
        
        // Variables de build
        BUILD_DATE = sh(script: 'date +"%Y-%m-%d %H:%M:%S"', returnStdout: true).trim()
        
        // Credentials (à configurer dans Jenkins)
        DOCKERHUB_CREDENTIALS = 'dockerhub-wassim'
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
        disableConcurrentBuilds()
    }
    
    triggers {
        // Déclenchement automatique sur push GitHub
        githubPush()
        
        // OU Poll SCM toutes les minutes
        pollSCM('* * * * *')
    }
    
    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()  // Nettoyer l'espace de travail
                echo "Workspace cleaned at: ${env.WORKSPACE}"
            }
        }
        
        stage('Checkout Git') {
            steps {
                git(
                    branch: 'main',
                    url: 'https://github.com/wassimfrigui/wassim-frigui.git',
                    credentialsId: 'github-credentials'  // À configurer dans Jenkins
                )
                echo "Code récupéré depuis Git"
            }
        }
        
        stage('Verify Files') {
            steps {
                sh '''
                    echo "=== Vérification des fichiers ==="
                    ls -la
                    echo "=== Contenu de app.py ==="
                    head -20 app.py
                    echo "=== Dockerfile ==="
                    cat Dockerfile
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    echo "Construction de l'image Docker..."
                    
                    // Tag avec BUILD_ID pour traçabilité
                    def imageTag = "${env.DOCKER_IMAGE_NAME}:${env.BUILD_ID}"
                    def latestTag = "${env.DOCKER_IMAGE_NAME}:latest"
                    
                    // Construire l'image
                    dockerImage = docker.build(
                        imageTag,
                        "--build-arg BUILD_ID=${env.BUILD_ID} " +
                        "--build-arg BUILD_DATE='${env.BUILD_DATE}' " +
                        "-f Dockerfile ."
                    )
                    
                    // Tagger aussi comme latest
                    dockerImage.tag(latestTag)
                    
                    echo "Image construite: ${imageTag}"
                    echo "Tagged as latest: ${latestTag}"
                }
            }
        }
        
        stage('Test Docker Image') {
            steps {
                script {
                    echo "Test de l'image Docker..."
                    
                    // Lancer un conteneur de test
                    docker.image("${env.DOCKER_IMAGE_NAME}:${env.BUILD_ID}").inside('-e BUILD_ID=${env.BUILD_ID}') {
                        sh '''
                            echo "=== Test dans le conteneur ==="
                            python --version
                            pip list | grep Flask
                            echo "Application prête"
                        '''
                    }
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    echo "Publication sur Docker Hub..."
                    
                    // Se connecter à Docker Hub
                    docker.withRegistry(
                        "https://${env.DOCKER_REGISTRY}",
                        "${env.DOCKERHUB_CREDENTIALS}"
                    ) {
                        // Pousser l'image avec BUILD_ID
                        dockerImage.push()
                        
                        // Pousser aussi le tag latest
                        dockerImage.push('latest')
                    }
                    
                    echo "Image publiée sur Docker Hub"
                    echo "URL: https://hub.docker.com/r/wassimfrigui/wassim-frigui-app"
                }
            }
        }
        
        stage('Cleanup') {
            steps {
                sh '''
                    echo "=== Nettoyage des images locales ==="
                    docker images | grep wassimfrigui || true
                    # docker rmi ${DOCKER_IMAGE_NAME}:${BUILD_ID} || true
                '''
            }
        }
    }
    
    post {
        success {
            echo "✅ Pipeline réussie !"
            emailext(
                subject: "SUCCÈS: Build ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Le build ${env.BUILD_NUMBER} a réussi.\nImage: ${env.DOCKER_IMAGE_NAME}:${env.BUILD_ID}",
                to: 'wassim@example.com'
            )
            
            // Afficher les informations de déploiement
            sh '''
                echo "=== RÉSUMÉ DU DÉPLOIEMENT ==="
                echo "Application: wassim-frigui"
                echo "Build ID: ${BUILD_ID}"
                echo "Image Docker: ${DOCKER_IMAGE_NAME}:${BUILD_ID}"
                echo "Date: ${BUILD_DATE}"
                echo "Pour exécuter localement:"
                echo "  docker run -p 5000:5000 ${DOCKER_IMAGE_NAME}:${BUILD_ID}"
            '''
        }
        
        failure {
            echo "❌ Pipeline échouée !"
            emailext(
                subject: "ÉCHEC: Build ${env.JOB_NAME} #${env.BUILD_NUMBER}",
                body: "Le build ${env.BUILD_NUMBER} a échoué. Consultez Jenkins pour les détails.",
                to: 'wassim@example.com'
            )
        }
        
        always {
            echo "Build terminée - Nettoyage..."
            // Archive les artefacts si nécessaire
            archiveArtifacts artifacts: '**/*.log, **/requirements.txt', fingerprint: true
        }
    }
}
