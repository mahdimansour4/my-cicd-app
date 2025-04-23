pipeline {
    agent any // Use any available Jenkins agent

    tools {
        maven 'Maven 3.9.6' // Specify a Maven tool configured in Jenkins Global Tool Config
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                git branch: 'master', url: 'https://github.com/mahdimansour4/my-cicd-app' // Replace with your repo URL
                // If private repo, add credentialsId: 'your-git-credentials-id'
            }
        }
        stage('Build & Test') {
            steps {
                echo 'Building and testing...'
                // Use sh for Linux/macOS agents, bat for Windows
                bat './mvnw clean package'
            }
            post {
                success {
                     echo 'Build and tests successful. Archiving JAR.'
                     junit 'target/surefire-reports/**/*.xml' // Publish test results
                     archiveArtifacts artifacts: 'target/*.jar', fingerprint: true // Archive the build artifact
                }
                failure {
                     echo 'Build or tests failed.'
                }
            }
        }
    }
    post {
         always {
             echo 'Pipeline finished.'
             // Clean up Maven workspace?
             // cleanWs()
         }
    }
}