
pipeline {
    
  parameters {
        string(name: 'BRANCH_NAME', defaultValue: 'main', description: 'Branch to build from')
    }

  environment {
    registry = "senthil123/lil-nodejs-app"
    registryCredential = 'dockerhubid'
    dockerImage = ''
    commitSHA = ''
    // GitToken = credentials('ghpat') // ID of the stored PAT
  }
  agent any
  stages {
        stage('SCM Checkout') {
            steps {
                // Checkout code from version control
                git branch: params.BRANCH_NAME , url: 'https://github.com/salagarsprabu/lil-node-app.git'
                script {
                   echo "Build No: ${BUILD_NUMBER}"
                   def commitSHA = sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
                   echo "Commit SHA: ${commitSHA}"
                }
            }
        }
		// run sonarqube test
        stage('SAST - Sonar') {
            environment {
                scannerHome = tool 'sonarscanner';
            }
            steps {
              withSonarQubeEnv(credentialsId: 'sonarqubeid', installationName: 'sonarserver') {
                sh "${scannerHome}/bin/sonar-scanner"
              }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    def commitSHA = sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
                    dockerImage = docker.build("${registry}:${commitSHA}")
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                script {
                    def commitSHA = sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhubid') {
                        dockerImage.push("${commitSHA}")
                        dockerImage.push("latest")
                    
                    }
                    //echo "docker push step"
                }
            }
        }
        stage('Remove Unused docker image') {
           steps{
               script {
                    def commitSHA = sh(script: 'git rev-parse HEAD', returnStdout: true).trim()
                    sh "docker rmi $registry:${commitSHA}"
                    }
           }
        }
               
  }
  post {
        success {
            echo "Pipeline completed successfully!"
            // Optionally send a notification (e.g., Slack, email, etc.)
        }
        failure {
            echo "Pipeline failed. Please check the logs."
            // Add notification for failure
        }
        always {
            echo "Pipeline finished"
        }
    }
}
