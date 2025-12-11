pipeline {
    agent any
    
    tools {
        maven 'M3'
    }
    
    environment {
        // Ces variables seront configurées dans Jenkins
        SONAR_HOST_URL = 'http://192.168.33.10:9000'
        DOCKER_IMAGE = 'wassimfrigui/ci-cd-demo'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo '✅ Code checked out'
            }
        }
        
        stage('Analyze Project') {
            steps {
                sh '''
                    echo "=== PROJECT ANALYSIS ==="
                    ls -la
                    echo ""
                    
                    if [ -f "pom.xml" ]; then
                        echo "✅ Maven project detected"
                        echo "Java version:"
                        java -version
                        echo ""
                        echo "Maven version:"
                        mvn --version
                    else
                        echo "⚠️  No pom.xml found"
                        echo "This may not be a Java Maven project"
                    fi
                    
                    if [ -f "Dockerfile" ]; then
                        echo "✅ Dockerfile detected"
                    else
                        echo "⚠️  No Dockerfile found"
                    fi
                '''
            }
        }
        
        stage('Maven Build & Test') {
            when {
                expression { fileExists('pom.xml') }
            }
            steps {
                sh '''
                    echo "=== MAVEN BUILD ==="
                    mvn clean compile test
                    echo "✅ Build completed"
                '''
            }
        }
        
        stage('SonarQube Analysis') {
            when {
                expression { fileExists('pom.xml') }
            }
            steps {
                withSonarQubeEnv('SonarQube') {
                    sh '''
                        echo "=== SONARQUBE ANALYSIS ==="
                        mvn sonar:sonar \
                          -Dsonar.projectKey=wassim-frigui-devops \
                          -Dsonar.projectName="Wassim Frigui DevOps"
                    '''
                }
            }
        }
        
        stage('Quality Gate Check') {
            when {
                expression { fileExists('pom.xml') }
            }
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
                echo '✅ Quality Gate passed'
            }
        }
        
        stage('Docker Build') {
            when {
                expression { fileExists('Dockerfile') }
            }
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-wassim',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh '''
                            echo "=== DOCKER BUILD ==="
                            docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} -t ${DOCKER_IMAGE}:latest .
                            echo "✅ Docker image built"
                        '''
                    }
                }
            }
        }
        
        stage('Docker Push') {
            when {
                expression { fileExists('Dockerfile') }
            }
            steps {
                script {
                    withCredentials([usernamePassword(
                        credentialsId: 'dockerhub-wassim',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_PASS'
                    )]) {
                        sh '''
                            echo "=== DOCKER PUSH ==="
                            echo "${DOCKER_PASS}" | docker login -u "${DOCKER_USER}" --password-stdin
                            docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                            docker push ${DOCKER_IMAGE}:latest
                            echo "✅ Images pushed to Docker Hub"
                        '''
                    }
                }
            }
        }
    }
    
    post {
        success {
            echo '��� PIPELINE SUCCESSFUL!'
            sh '''
                echo "========================================"
                echo "           BUILD REPORT                 "
                echo "========================================"
                echo "Build: #${BUILD_NUMBER}"
                echo "SonarQube: ${SONAR_HOST_URL}"
                echo "Docker Image: ${DOCKER_IMAGE}:${BUILD_NUMBER}"
                echo "========================================"
            '''
        }
        failure {
            echo '❌ PIPELINE FAILED'
        }
        always {
            sh 'docker system prune -f 2>/dev/null || true'
            cleanWs()
        }
    }
}
