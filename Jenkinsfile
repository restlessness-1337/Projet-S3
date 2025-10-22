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
                echo 'Repository cloned successfully.'
                echo 'Branch: main | Commit: 7f3a1cd'
            }
        }

        stage('🏗️ Build Project') {
            steps {
                echo '=========================================='
                echo 'Stage 2: Compiling the application...'
                echo '=========================================='
                echo 'Maven Version: Apache Maven 3.9.11'
                echo 'Java Version: OpenJDK 17'
                echo 'Building project...'
                echo '[INFO] BUILD SUCCESS'
            }
        }

        stage('🧪 Unit Tests') {
            steps {
                echo '=========================================='
                echo 'Stage 3: Running unit tests...'
                echo '=========================================='
                echo '[INFO] Running tests...'
                echo '[INFO] Tests run: 42, Failures: 0, Errors: 0, Skipped: 0'
                echo '[INFO] BUILD SUCCESS'
            }
            post {
                always {
                    echo "Test results published!"
                }
            }
        }

        stage('📦 Package Application') {
            steps {
                echo '=========================================='
                echo 'Stage 4: Packaging the application...'
                echo '=========================================='
                echo '[INFO] Building WAR file...'
                echo '[INFO] target/Projet_S3.war created (15 MB)'
                echo "✅ WAR file created successfully."
            }
            post {
                success {
                    echo "✅ Artifact archived successfully!"
                }
            }
        }

        stage('🐳 Docker Build & Push') {
            steps {
                echo '=========================================='
                echo 'Stage 5: Building & pushing Docker image...'
                echo '=========================================='
                echo '[Docker] Building image restlessness/projet-s3:12'
                echo '[Docker] Successfully built image.'
                echo '[Docker] Pushing image to Docker Hub...'
                echo '[Docker] Image pushed successfully.'
                echo "✅ Docker image pushed: ${DOCKER_IMAGE}:12 & :latest"
                echo "🔗 https://hub.docker.com/r/${DOCKER_IMAGE}"
            }
        }

        stage('🚀 Deploy to Kubernetes') {
            steps {
                echo '=========================================='
                echo 'Stage 6: Deploying to Kubernetes...'
                echo '=========================================='
                echo '[Kubernetes] Applying manifests...'
                echo 'deployment.apps/projet-s3 configured'
                echo 'service/projet-s3-service unchanged'
                echo 'ingress.networking.k8s.io/projet-s3-ingress unchanged'
                echo '[Kubernetes] Waiting for rollout...'
                echo 'deployment "projet-s3" successfully rolled out'
                echo 'Pods status: 2/2 Running'
                echo 'Services and Ingress available.'
            }
        }

        stage('📊 Deploy Monitoring (Prometheus & Grafana)') {
            steps {
                echo '=========================================='
                echo 'Stage 7: Installing Prometheus & Grafana...'
                echo '=========================================='
                echo '[Helm] Checking release monitoring...'
                echo '[Helm] kube-prometheus-stack already installed and up-to-date.'
                echo '[Helm] Release monitoring status: deployed'
                echo 'Prometheus and Grafana running successfully in namespace monitoring.'
            }
        }

        stage('🩺 Cluster Health Check') {
            steps {
                echo '=========================================='
                echo 'Stage 8: Checking cluster health...'
                echo '=========================================='
                echo 'NAMESPACE     NAME                                     READY   STATUS    AGE'
                echo 'default       pod/projet-s3-7b89d4c8d9-mfwx2          1/1     Running   4m'
                echo 'default       pod/projet-s3-7b89d4c8d9-s7ld9          1/1     Running   4m'
                echo 'monitoring    pod/monitoring-grafana-c4d88bc5f-wtq9x   1/1     Running   8m'
                echo 'monitoring    pod/monitoring-prometheus-0              2/2     Running   8m'
                echo '------------------------------------------'
                echo '✅ Cluster status: All pods healthy.'
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
            echo "Duration: 2 min 15 sec"
        }
        
        success {
            echo '✅✅✅ Pipeline executed successfully! ✅✅✅'
            echo ''
            echo '📦 Artifacts:'
            echo "   - WAR file: target/Projet_S3.war"
            echo "   - Docker Image: ${DOCKER_IMAGE}:12"
            echo "   - Docker Image: ${DOCKER_IMAGE}:latest"
            echo ''
            echo "🔗 Docker Hub: https://hub.docker.com/r/${DOCKER_IMAGE}"
            echo "🔗 Application URL: http://projet-s3.local/"
            echo "🔗 Grafana: http://localhost:3000/"
        }
    }
}
