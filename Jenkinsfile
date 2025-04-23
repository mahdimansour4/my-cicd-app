pipeline {
    agent any // Agent needs Docker installed or configured

    tools {
        maven 'Maven 3.9.6' // Matches name in Jenkins Global Tool Config
    }

    environment {
        DOCKER_REGISTRY = 'mahdimansour'
        APP_NAME        = 'my-cicd-app'
        IMAGE_TAG       = "${env.BUILD_NUMBER}"
        DOCKER_IMAGE    = "${DOCKER_REGISTRY}/${APP_NAME}:${IMAGE_TAG}"
        REGISTRY_CREDS  = 'dockerhub-creds'

        // --- ADD THESE FOR KUBERNETES ---
        K8S_DEPLOYMENT  = 'my-cicd-app-deployment' // Matches 'name' in deployment.yaml
        K8S_NAMESPACE   = 'default' // Target Kubernetes namespace (change if needed)
        K8S_CONTAINER   = 'my-cicd-app-container' // Matches 'name' under containers in deployment.yaml
        // Optional: KUBECONFIG_CREDS = 'kubeconfig-credentials-id' // If using Jenkins credentials for kubeconfig
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
                // ... echo and other diagnostic steps ...
                script {
                    echo "Attempting to build ${env.DOCKER_IMAGE}..."
                    docker.build(env.DOCKER_IMAGE, ".")
                    // --- ADD VERIFICATION STEP ---
                    sh "echo '--- Verifying Local Docker Images After Build ---'"
                    // List images and filter for your app name to check tag
                    sh "docker images | grep ${env.APP_NAME} || true"
                    // The '|| true' prevents the pipeline failing if grep finds nothing
                    sh "echo '--- Verification End ---'"
                    // --- END VERIFICATION STEP ---
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
        // --- ADD THIS ENTIRE STAGE ---
        stage('Deploy to Kubernetes') {
                 steps {
                     echo "Deploying image ${env.DOCKER_IMAGE} to Kubernetes namespace ${env.K8S_NAMESPACE}..."
                     withEnv(['KUBECONFIG=/var/lib/jenkins/.kube/config']) { // Keep this
                         script {
                             // Original commands:
                             sh "kubectl config set-context --current --namespace=${env.K8S_NAMESPACE}"
                             sh "kubectl apply -f k8s/"
                             sh "kubectl set image deployment/${env.K8S_DEPLOYMENT} ${env.K8S_CONTAINER}=${env.DOCKER_IMAGE}"
                             sh "kubectl rollout status deployment/${env.K8S_DEPLOYMENT}"
                         }
                     }
                 }
            }
        // --- END OF NEW STAGE ---
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