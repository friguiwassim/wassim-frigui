pipeline {
    agent any
    
    triggers {
        pollSCM('H/5 * * * *')  // Toutes les 5 minutes
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                checkout scm
            }
        }
        
        stage('List Files') {
            steps {
                sh '''
                    echo "=== Files in workspace ==="
                    ls -la
                    echo "=== Dockerfile content ==="
                    cat Dockerfile
                '''
            }
        }
        
        stage('Test Docker Build') {
            steps {
                sh '''
                    echo "Testing Docker build..."
                    docker build -t test-local:${BUILD_NUMBER} .
                    echo "Docker build successful!"
                '''
            }
        }
    }
    
    post {
        always {
            echo 'Build completed.'
        }
    }
}
