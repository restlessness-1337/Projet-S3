pipeline {
    agent any
    
    tools {
        maven 'Maven-3.9.11'
    }
    
    environment {
        DOCKER_IMAGE = 'restlessness/projet-s3'
        DOCKER_CREDENTIALS = credentials('dockerhub-credentials')
    }
    
    stages {
        stage('🔍 Checkout Code') {
            steps {
                echo '=========================================='
                echo 'Stage 1: Cloning repository from GitHub...'
                echo '=========================================='
                checkout scm
                
                script {
                    def gitCommit = sh(returnStdout: true, script: 'git rev-parse HEAD').trim()
                    echo "Git Commit: ${gitCommit}"
                }
            }
        }
        
        stage('🏗️ Build Project') {
            steps {
                echo '=========================================='
                echo 'Stage 2: Compiling the application...'
                echo '=========================================='
                
                sh '''
                    echo "Maven Version:"
                    mvn --version
                    
                    echo "Starting compilation..."
                    mvn clean compile
                '''
            }
        }
        
        stage('🧪 Unit Tests') {
            steps {
                echo '=========================================='
                echo 'Stage 3: Running unit tests...'
                echo '=========================================='
                
                sh 'mvn test || true'
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
                    echo "Test results published!"
                }
            }
        }
        
        stage('📦 Package Application') {
            steps {
                echo '=========================================='
                echo 'Stage 4: Packaging the application...'
                echo '=========================================='
                
                sh 'mvn package -DskipTests'
                
                script {
                    sh 'ls -lah target/*.war'
                    echo "✅ WAR file created: target/Projet_S3.war"
                }
            }
            post {
                success {
                    archiveArtifacts artifacts: 'target/*.war', fingerprint: true
                    echo "✅ Artifact archived successfully!"
                }
            }
        }
        
        stage('🐳 Docker Build & Push') {
            steps {
                echo '=========================================='
                echo 'Stage 5: Building & pushing Docker image...'
                echo '=========================================='
                
                script {
                    // Build et push en une seule étape, avec les credentials DockerHub
                    docker.withRegistry('https://registry-1.docker.io/', 'dockerhub-credentials') {
                        def app = docker.build("${DOCKER_IMAGE}:${BUILD_NUMBER}")
                        app.push()
                        app.push('latest')
                    }
                }
                
                echo "✅ Docker image pushed: ${DOCKER_IMAGE}:${BUILD_NUMBER} & :latest"
                echo "🔗 https://hub.docker.com/r/${DOCKER_IMAGE}"
            }
        }
    }
    
    post {
        always {
            echo '=========================================='
            echo 'Pipeline Execution Summary'
            echo '=========================================='
            echo "Build Number: ${BUILD_NUMBER}"
            echo "Build Status: ${currentBuild.result ?: 'SUCCESS'}"
            echo "Duration: ${currentBuild.durationString}"
        }
        
        success {
            echo '✅✅✅ Pipeline executed successfully! ✅✅✅'
            echo ''
            echo '📦 Artifacts:'
            echo "   - WAR file: target/Projet_S3.war"
            echo "   - Docker Image: ${DOCKER_IMAGE}:${BUILD_NUMBER}"
            echo "   - Docker Image: ${DOCKER_IMAGE}:latest"
            echo ''
            echo "🔗 Docker Hub: https://hub.docker.com/r/${DOCKER_IMAGE}"
        }
        
        failure {
            echo '❌❌❌ Pipeline failed! ❌❌❌'
            echo 'Check the logs above for errors.'
        }
        
        cleanup {
            echo 'Cleaning up workspace...'
            // cleanWs() // décommente si tu veux nettoyer après chaque build
        }
    }
}
