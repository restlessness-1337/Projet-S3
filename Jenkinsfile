pipeline {
  agent any

  tools {
    maven 'Maven-3.9.11'
  }

  environment {
    // Image Docker à publier sur Docker Hub
    DOCKER_IMAGE = 'restlessness/projet-s3'
    // Tag par build
    DOCKER_TAG   = "${BUILD_NUMBER}"
    // Nom du serveur Sonar déclaré dans Jenkins > Manage Jenkins > System > SonarQube servers
    SONARQUBE_ENV = 'sonarqube-local'
    // (Option) Si ton WAR n'a pas ce nom, change-le ici ou passe un --build-arg au docker.build
    WAR_NAME = 'Projet_S3.war'
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
          mvn -B clean compile
        '''
      }
    }

    stage('🧪 Unit Tests') {
      steps {
        echo '=========================================='
        echo 'Stage 3: Running unit tests...'
        echo '=========================================='
        sh 'mvn -B test'
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
        sh 'mvn -B package -DskipTests'
        script {
          sh 'ls -lah target/*.war || true'
          echo "✅ WAR expected: target/${env.WAR_NAME}"
        }
      }
      post {
        success {
          archiveArtifacts artifacts: 'target/*.war', fingerprint: true
          echo "✅ Artifact archived successfully!"
        }
      }
    }

    stage('🧭 SonarQube Analysis') {
      steps {
        echo '=========================================='
        echo 'Stage 5: SonarQube analysis...'
        echo '=========================================='
        withSonarQubeEnv("${env.SONARQUBE_ENV}") {
          sh 'mvn -B sonar:sonar'
        }
      }
    }

    stage('🐳 Docker Build & Push') {
      steps {
        echo '=========================================='
        echo 'Stage 6: Building and pushing Docker image...'
        echo '=========================================='

        script {
          // Pour Docker Hub, l'endpoint recommandé est registry-1.docker.io
          docker.withRegistry('https://registry-1.docker.io/', 'dockerhub-credentials') {

            // Si ton Dockerfile est à la racine et accepte WAR_NAME en ARG :
            // def app = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}", "--build-arg WAR_NAME=${WAR_NAME} .")

            // Sinon, build simple (Dockerfile à la racine, nom WAR géré dans le Dockerfile)
            def app = docker.build("${DOCKER_IMAGE}:${DOCKER_TAG}")

            // Push du tag de build et du tag latest
            app.push()
            app.push('latest')
          }
        }

        echo "✅ Docker image pushed: ${DOCKER_IMAGE}:${DOCKER_TAG} & :latest"
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
      echo "📦 WAR: target/${env.WAR_NAME}"
      echo "🐳 Image: ${DOCKER_IMAGE}:${DOCKER_TAG} & :latest"
    }
    failure {
      echo '❌❌❌ Pipeline failed! ❌❌❌'
      echo 'Check the logs above for errors.'
    }
  }
}
