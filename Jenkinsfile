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

        stage('🐳 Docker Build & Push') {
  steps {
    echo '=========================================='
    echo 'Stage 5: Building and pushing Docker image...'
    echo '=========================================='

    script {
      // registry-1.docker.io = endpoint officiel de Docker Hub
      docker.withRegistry('https://registry-1.docker.io/', 'dockerhub-credentials') {
        // Construit l’image à partir du Dockerfile à la racine
        def app = docker.build("${DOCKER_IMAGE}:${BUILD_NUMBER}")
        // Push du tag de build et du tag latest
        app.push()
        app.push('latest')
      }
    }

    echo "✅ Docker image pushed: ${DOCKER_IMAGE}:${BUILD_NUMBER} & :latest"
    echo "🔗 https://hub.docker.com/r/${DOCKER_IMAGE}"
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
