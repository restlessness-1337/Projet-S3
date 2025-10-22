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
        
        stage('🐳 Build Docker Image') {
            steps {
                echo '=========================================='
                echo 'Stage 5: Building Docker image...'
                echo '=========================================='
                
                script {
                    sh """
                        echo "Building Docker image..."
                        docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                        docker build -t ${DOCKER_IMAGE}:latest .
                        
                        echo "Listing Docker images..."
                        docker images | grep projet-s3 || docker images
                    """
                }
            }
            post {
                success {
                    echo "✅ Docker image built successfully!"
                }
            }
        }
        
        stage('🚀 Push to Docker Hub') {
            steps {
                echo '=========================================='
                echo 'Stage 6: Pushing Docker image to Docker Hub...'
                echo '=========================================='
                
                script {
                    sh """
                        echo "Logging into Docker Hub..."
                        echo \${DOCKER_CREDENTIALS_PSW} | docker login -u \${DOCKER_CREDENTIALS_USR} --password-stdin
                        
                        echo "Pushing images..."
                        docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                        docker push ${DOCKER_IMAGE}:latest
                        
                        echo "✅ Images pushed successfully!"
                    """
                }
            }
            post {
                success {
                    echo "✅ Images available at: https://hub.docker.com/r/${DOCKER_IMAGE}"
                }
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
            // cleanWs() // Décommenter pour nettoyer le workspace après chaque build
        }
    }
}
