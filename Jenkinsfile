pipeline {
    agent any
    
    tools {
        maven 'Maven-3.9.11'
    }
    
    environment {
        DOCKER_IMAGE = 'restlessness/projet-s3'
        DOCKER_CREDENTIALS = credentials('dockerhub-credentials')
        KUBE_NAMESPACE = 'default'
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
                    echo "🧾 Test results published!"
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
                    echo "📦 Artifact archived successfully!"
                }
            }
        }
        
        stage('🐳 Docker Build & Push') {
            steps {
                echo '=========================================='
                echo 'Stage 5: Building & pushing Docker image...'
                echo '=========================================='
                
                script {
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

        stage('🚀 Deploy to Kubernetes') {
            steps {
                echo '=========================================='
                echo 'Stage 6: Deploying to Kubernetes...'
                echo '=========================================='
                script {
                    sh '''
                        echo "Applying Kubernetes manifests..."
                        kubectl apply -f k8s/deployment.yaml
                        kubectl apply -f k8s/service.yaml
                        kubectl apply -f k8s/ingress.yaml

                        echo "Waiting for rollout..."
                        kubectl rollout status deploy/projet-s3 -n ${KUBE_NAMESPACE}

                        echo "Current cluster state:"
                        kubectl get all -n ${KUBE_NAMESPACE} -o wide
                    '''
                }
            }
        }

        stage('📊 Deploy Monitoring (Prometheus & Grafana)') {
            steps {
                echo '=========================================='
                echo 'Stage 7: Installing Prometheus & Grafana...'
                echo '=========================================='
                script {
                    sh '''
                        if ! helm status monitoring -n monitoring >/dev/null 2>&1; then
                            echo "Installing kube-prometheus-stack via Helm..."
                            helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
                            helm repo update
                            helm install monitoring prometheus-community/kube-prometheus-stack \
                                --namespace monitoring --create-namespace
                        else
                            echo "Monitoring stack already installed — skipping"
                        fi
                    '''
                }
            }
        }

        stage('🩺 Cluster Health Check') {
            steps {
                echo '=========================================='
                echo 'Stage 8: Checking cluster and monitoring health...'
                echo '=========================================='
                script {
                    sh '''
                        echo "Namespace: ${KUBE_NAMESPACE}"
                        echo "--- Default Namespace ---"
                        kubectl get pods -o wide -n ${KUBE_NAMESPACE}
                        echo "--- Monitoring Namespace ---"
                        kubectl get pods -n monitoring
                        echo "--- Services ---"
                        kubectl get svc -A
                    '''
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
            echo '🧹 Cleaning up workspace...'
            // cleanWs()
        }
    }
}
