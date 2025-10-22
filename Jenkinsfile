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
                
                sh 'mvn test'
            }
            post {
                always {
                    junit allowEmptyResults: true, testResults: '**/target/surefire-reports/*.xml'
                    echo "Test results published!"
                }
                success {
                    echo "✅ All tests passed!"
                }
                failure {
                    echo "❌ Some tests failed!"
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
                    sh 'ls -la target/*.war'
                }
            }
            post {
                success {
                    archiveArtifacts artifacts: 'target/*.war', fingerprint: true
                    echo "✅ Artifact archived successfully!"
                }
            }
        }
        
        stage('🔎 SonarQube Analysis') {
            steps {
                echo '=========================================='
                echo 'Stage 5: Running SonarQube analysis...'
                echo '=========================================='
                
                script {
                    withSonarQubeEnv('SonarQube-Server') {
                        sh '''
                            mvn sonar:sonar \
                            -Dsonar.projectKey=Projet-S3 \
                            -Dsonar.projectName="Projet S3 - Employee Management" \
                            -Dsonar.java.binaries=target/classes
                        '''
                    }
                }
            }
        }
        
        stage('✅ Quality Gate') {
            steps {
                echo '=========================================='
                echo 'Stage 6: Waiting for Quality Gate...'
                echo '=========================================='
                
                timeout(time: 5, unit: 'MINUTES') {
                    script {
                        def qg = waitForQualityGate()
                        if (qg.status != 'OK') {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        } else {
                            echo "✅ Quality Gate passed!"
                        }
                    }
                }
            }
        }
        
        stage('🐳 Build Docker Image') {
            steps {
                echo '=========================================='
                echo 'Stage 7: Building Docker image...'
                echo '=========================================='
                
                script {
                    sh """
                        docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} .
                        docker build -t ${DOCKER_IMAGE}:latest .
                        docker images | grep projet-s3
                    """
                }
            }
        }
        
        stage('🚀 Push to Docker Hub') {
            steps {
                echo '=========================================='
                echo 'Stage 8: Pushing Docker image to Docker Hub...'
                echo '=========================================='
                
                script {
                    sh """
                        echo ${DOCKER_CREDENTIALS_PSW} | docker login -u ${DOCKER_CREDENTIALS_USR} --password-stdin
                        docker push ${DOCKER_IMAGE}:${BUILD_NUMBER}
                        docker push ${DOCKER_IMAGE}:latest
                        echo "✅ Images pushed successfully!"
                    """
                }
            }
        }
        
        stage('☸️ Deploy to Kubernetes') {
            steps {
                echo '=========================================='
                echo 'Stage 9: Deploying to Kubernetes...'
                echo '=========================================='
                
                script {
                    sh '''
                        kubectl apply -f k8s/namespace.yaml
                        kubectl apply -f k8s/configmap.yaml
                        kubectl apply -f k8s/secret.yaml
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        kubectl apply -f k8s/ingress.yaml
                        
                        echo "Waiting for deployment to complete..."
                        kubectl rollout status deployment/projet-s3-deployment -n projet-s3 --timeout=5m
                        
                        echo "Getting deployment status..."
                        kubectl get all -n projet-s3
                    '''
                }
            }
            post {
                success {
                    echo "✅ Application deployed successfully to Kubernetes!"
                }
                failure {
                    echo "❌ Kubernetes deployment failed!"
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
            echo "Build Status: ${currentBuild.result}"
            echo "Duration: ${currentBuild.durationString}"
        }
        
        success {
            echo '✅✅✅ Pipeline executed successfully! ✅✅✅'
            echo "Docker Image: ${DOCKER_IMAGE}:${BUILD_NUMBER}"
            echo "Deployment: projet-s3-deployment in namespace projet-s3"
        }
        
        failure {
            echo '❌❌❌ Pipeline failed! ❌❌❌'
            echo 'Check the logs above for errors.'
        }
        
        cleanup {
            echo 'Cleaning up workspace...'
            // cleanWs()
        }
    }
}
