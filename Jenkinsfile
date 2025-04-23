pipeline {
    agent any // Agent needs Docker installed or configured

    tools {
        maven 'Maven 3.9.6' // Matches name in Jenkins Global Tool Config
    }

    environment {
        // Define registry and image name - REPLACE 'your-dockerhub-username'
        DOCKER_REGISTRY = 'mahdimansour'
        APP_NAME        = 'my-cicd-app'
        // Use the Jenkins BUILD_NUMBER for unique image tags
        IMAGE_TAG       = "${env.BUILD_NUMBER}"
        // Full image name including registry path
        DOCKER_IMAGE    = "${DOCKER_REGISTRY}/${APP_NAME}:${IMAGE_TAG}"
        // Credentials ID for Docker Hub/Registry configured in Jenkins
        REGISTRY_CREDS  = 'dockerhub-creds' // REPLACE if you use a different ID
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                // REPLACE 'your-git-repo-url'
                git branch: 'master', url: 'https://github.com/mahdimansour4/my-cicd-app'
                // credentialsId: 'your-git-credentials-id' // Add if Git repo is private
            }
        }
        stage('Build & Test') {
            steps {
                echo 'Building and testing...'
                sh 'chmod +x mvnw'
                sh './mvnw clean package' // Use sh for Linux/macOS agents
            }
            post {
                 success {
                      echo 'Build and tests successful. Archiving JAR.'
                      junit 'target/surefire-reports/**/*.xml'
                      archiveArtifacts artifacts: 'target/*.jar', fingerprint: true
                 }
                 failure {
                      error 'Build or tests failed.' // Fails the pipeline
                 }
            }
        }
        // --- NEW DOCKER STAGES ---
        stage('Build Docker Image') {
            steps {
                echo "Building Docker image: ${env.DOCKER_IMAGE}"
                // --- DIAGNOSTIC STEPS ---
                sh 'echo "--- Checking Workspace ---"'
                sh 'pwd' // Print current directory
                sh 'ls -la' // List all files (check for Dockerfile)
                sh 'echo "--- Checking target directory ---"'
                sh 'ls -la target/' // Check for the JAR file produced by Maven
                sh 'echo "--- Diagnostics End ---"'
                // --- END DIAGNOSTIC STEPS ---
                script {
                     // docker.build(env.DOCKER_IMAGE, ".") // Comment out original
                     docker.build("mahdimansour/my-cicd-app:testbuild", ".") // Use simple test tag
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                echo "Pushing Docker image: ${env.DOCKER_IMAGE}"
                script {
                     // Login to the registry using configured credentials and push
                     // The URL 'https://index.docker.io/v1/' is standard for Docker Hub
                     docker.withRegistry('https://index.docker.io/v1/', env.REGISTRY_CREDS) {
                         docker.image(env.DOCKER_IMAGE).push()

                         // Also push a 'latest' tag for convenience (optional)
                         // docker.image(env.DOCKER_IMAGE).push('latest')
                     }
                }
            }
        }
        // --- END OF NEW DOCKER STAGES ---
    }
    post {
         always {
             echo 'Pipeline finished.'
             // Optional: cleanWs() // Cleans workspace after build
         }
         success {
             echo 'Pipeline Succeeded!'
             // Add success notifications (Slack, Email) later
         }
         failure {
             echo 'Pipeline Failed!'
             // Add failure notifications later
         }
    }
}