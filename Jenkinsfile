pipeline {
    agent any
    
    tools {
        maven 'Maven-3.9.11'
    }
    
    environment {
        DOCKER_IMAGE = 'restlessness/projet-s3'
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

        stage('🐳 Build & Push Docker Image with Jib') {
            steps {
                echo '=========================================='
                echo 'Stage 5: Building and pushing Docker image using Jib...'
                echo '=========================================='

                withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials',
                                                  usernameVariable: 'DH_USER',
                                                  passwordVariable: 'DH_PASS')]) {
                    sh """
                        mvn -B com.google.cloud.tools:jib-maven-plugin:3.4.1:build \
                          -Dimage=${DOCKER_IMAGE}:${BUILD_NUMBER} \
                          -Djib.to.tags=latest,${BUILD_NUMBER} \
                          -Djib.to.auth.username=${DH_USER} \
                          -Djib.to.auth.password=${DH_PASS} \
                          -Djib.from.image=tomcat:10.1-jdk17 \
                          -Djib.containerizingMode=packaged \
                          -Djib.container.ports=8080
                    """
                }
                echo "✅ Image pushed: ${DOCKER_IMAGE}:${BUILD_NUMBER} and :latest"
                echo "🔗 Docker Hub: https://hub.docker.com/r/${DOCKER_IMAGE}"
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
        }
        failure {
            echo '❌❌❌ Pipeline failed! ❌❌❌'
            echo 'Check the logs above for errors.'
        }
    }
}
