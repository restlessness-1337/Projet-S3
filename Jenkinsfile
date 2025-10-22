pipeline {
    agent any
    
    tools {
        maven 'Maven-3.9.11'
    }
    
    environment {
        DOCKER_IMAGE = 'restlessness/employee-app'
        DOCKER_CREDENTIALS = credentials('dockerhub-credentials')
        K8S_NAMESPACE = 'employee-app'
        BUILD_VERSION = "${BUILD_NUMBER}"
    }
    
    stages {
        stage('🔍 Checkout Code') {
            steps {
                echo '=========================================='
                echo 'Stage 1: Cloning repository from GitHub...'
                echo '=========================================='
                checkout scm
                
                script {
                    def gitCommit = bat(returnStdout: true, script: '@git rev-parse HEAD').trim()
                    echo "Git Commit: ${gitCommit}"
                }
            }
        }
        
        stage('🏗️ Build Project') {
            steps {
                echo '=========================================='
                echo 'Stage 2: Compiling the application...'
                echo '=========================================='
                
                bat '''
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
                
                bat 'mvn test'
            }
            post {
                always {
                    // Publier les résultats des tests
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
                
                bat 'mvn package -DskipTests'
                
                script {
                    def jarFile = bat(returnStdout: true, script: '@dir /b target\\*.jar').trim()
                    echo "Generated JAR: ${jarFile}"
                }
            }
            post {
                success {
                    archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
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
                        bat '''
                            mvn sonar:sonar ^
                            -Dsonar.projectKey=employee-management-app ^
                            -Dsonar.projectName="Employee Management Application" ^
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
                    bat """
                        docker build -t ${DOCKER_IMAGE}:${BUILD_VERSION} .
                        docker build -t ${DOCKER_IMAGE}:latest .
                        docker images | findstr ${DOCKER_IMAGE}
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
                    bat """
                        echo ${DOCKER_CREDENTIALS_PSW} | docker login -u ${DOCKER_CREDENTIALS_USR} --password-stdin
                        docker push ${DOCKER_IMAGE}:${BUILD_VERSION}
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
                    bat """
                        kubectl apply -f k8s/namespace.yaml
                        kubectl apply -f k8s/configmap.yaml
                        kubectl apply -f k8s/secret.yaml
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        kubectl apply -f k8s/ingress.yaml
                        
                        echo "Waiting for deployment to complete..."
                        kubectl rollout status deployment/employee-app-deployment -n ${K8S_NAMESPACE} --timeout=5m
                        
                        echo "Getting deployment status..."
                        kubectl get all -n ${K8S_NAMESPACE}
                    """
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
            echo "Docker Image: ${DOCKER_IMAGE}:${BUILD_VERSION}"
            echo "Deployment: employee-app-deployment in namespace ${K8S_NAMESPACE}"
        }
        
        failure {
            echo '❌❌❌ Pipeline failed! ❌❌❌'
            echo 'Check the logs above for errors.'
        }
        
        cleanup {
            // Nettoyage optionnel
            echo 'Cleaning up workspace...'
            // cleanWs() // Décommenter si vous voulez nettoyer le workspace
        }
    }
}
