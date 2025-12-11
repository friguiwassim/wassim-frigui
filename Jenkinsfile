pipeline {
    agent any

    triggers {
        pollSCM('*/2 * * * *')
    }

    environment {
        // Docker
        DOCKER_IMAGE = 'wassimfrigui/ci-cd-demo'
        DOCKER_CREDS = credentials('dockerhub-wassim')
        
        // SonarQube
        SONAR_HOST_URL = 'http://192.168.33.10:9000'
        SONAR_TOKEN = credentials('squ_de894476d94878b23fd052008524570fd130d7c4')
        
        // GitHub
        GITHUB_TOKEN = credentials('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')
    }

    tools {
        maven 'M3'  // Assurez-vous d'avoir configurÃ© Maven dans Global Tools
    }

    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
                echo 'Workspace cleaned'
            }
        }

        stage('Git Checkout with Token') {
            steps {
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    extensions: [],
                    userRemoteConfigs: [[
                        url: 'https://github.com/friguiwassim/wassim-frigui.git',
                        credentialsId: 'github-token'
                    ]]
                ])
                echo 'Code retrieved from Git using token'
            }
        }

        stage('Check Project Structure') {
            steps {
                sh '''
                    echo "=== Project Structure ==="
                    ls -la
                    
                    echo "=== Checking for pom.xml ==="
                    if [ -f "pom.xml" ]; then
                        echo "Maven project detected"
                        cat pom.xml | head -20
                    else
                        echo "No pom.xml found - not a Maven project"
                    fi
                '''
            }
        }

        stage('Maven Build (if applicable)') {
            when {
                expression { fileExists('pom.xml') }
            }
            steps {
                sh '''
                    echo "Running Maven build..."
                    mvn clean compile test -q
                    echo "Maven build completed"
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
                        echo "Starting SonarQube analysis..."
                        mvn sonar:sonar \
                            -Dsonar.projectKey=wassim-frigui-devops \
                            -Dsonar.projectName="Wassim Frigui DevOps Project" \
                            -Dsonar.host.url=${SONAR_HOST_URL} \
                            -Dsonar.login=${SONAR_TOKEN}
                        echo "SonarQube analysis submitted"
                    '''
                }
            }
        }

        stage('Check SonarQube Quality Gate') {
            when {
                expression { fileExists('pom.xml') }
            }
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Docker Build') {
            when {
                expression { fileExists('Dockerfile') }
            }
            steps {
                sh '''
                    echo "Building Docker image..."
                    docker build -t ${DOCKER_IMAGE}:v${BUILD_NUMBER} -t ${DOCKER_IMAGE}:latest .
                    echo "Docker image built successfully"
                '''
            }
        }

        stage('Docker Push') {
            when {
                expression { fileExists('Dockerfile') }
            }
            steps {
                sh '''
                    echo "Logging into Docker Hub..."
                    echo "${DOCKER_CREDS_PSW}" | docker login -u "${DOCKER_CREDS_USR}" --password-stdin

                    echo "Pushing images to Docker Hub..."
                    docker push ${DOCKER_IMAGE}:v${BUILD_NUMBER}
                    docker push ${DOCKER_IMAGE}:latest

                    echo "Images pushed successfully to Docker Hub"
                '''
            }
        }
    }

    post {
        success {
            echo 'í¾‰ PIPELINE SUCCESSFUL!'
            sh '''
                echo "========================================="
                echo "           CI/CD PIPELINE REPORT         "
                echo "========================================="
                echo "í³¦ Build Number: #${BUILD_NUMBER}"
                echo "í°³ Docker Image: ${DOCKER_IMAGE}:v${BUILD_NUMBER}"
                echo "í´— Docker Hub: https://hub.docker.com/r/wassimfrigui/ci-cd-demo"
                echo "í³Š SonarQube: ${SONAR_HOST_URL}/dashboard?id=wassim-frigui-devops"
                echo "í°™ GitHub: https://github.com/friguiwassim/wassim-frigui"
                echo "íº€ Test Command: docker run -p 8080:80 ${DOCKER_IMAGE}:latest"
                echo "========================================="
            '''
        }
        failure {
            echo 'âŒ PIPELINE FAILED - Check logs for details'
            sh '''
                echo "========================================="
                echo "           FAILURE DETAILS               "
                echo "========================================="
                echo "Job: ${JOB_NAME}"
                echo "Build: #${BUILD_NUMBER}"
                echo "URL: ${BUILD_URL}"
                echo "========================================="
            '''
        }
        always {
            sh '''
                echo "Cleaning up Docker images..."
                docker image prune -f 2>/dev/null || true
            '''
            cleanWs()
        }
    }
}
