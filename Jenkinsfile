pipeline {
  agent any

  tools {
    // Déclare des outils nommés que tu auras configurés dans Jenkins (Manage Jenkins > Tools)
    jdk 'jdk17'
    maven 'maven3'
  }

  environment {
    // Nom du serveur SonarQube déclaré dans Jenkins (Manage Jenkins > System > SonarQube servers)
    SONARQUBE_ENV = 'sonarqube-local'
  }

  options {
    // Garde des logs lisibles et limite la rétention
    timestamps()
    buildDiscarder(logRotator(numToKeepStr: '20'))
  }

  triggers {
    // (simple) Scrute le repo chaque minute. Tu peux remplacer par un webhook GitHub.
    pollSCM('* * * * *')
  }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Build') {
      steps {
        sh 'mvn -B -DskipTests clean package'
      }
    }

    stage('Test') {
      steps {
        sh 'mvn -B test'
      }
      post {
        always {
          junit allowEmptyResults: true, testResults: '*/target/surefire-reports/*.xml, target/surefire-reports/*.xml'
        }
      }
    }

    stage('SonarQube Analysis') {
      steps {
        withSonarQubeEnv("${env.SONARQUBE_ENV}") {
          sh 'mvn -B sonar:sonar'
        }
      }
    }

    stage('Package artifact') {
      when { expression { fileExists('target') } }
      steps {
        sh 'ls -lah target || dir target'
        archiveArtifacts artifacts: 'target/*', fingerprint: true
      }
    }
  }

  post {
    success { echo 'Build OK ✅' }
    failure { echo 'Build KO ❌' }
  }
}
