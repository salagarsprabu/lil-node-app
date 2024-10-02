
pipeline {
    agent any 
    
    stages { 
        stage('SCM Checkout') {
            steps{
           git branch: 'main', url: 'https://github.com/salagarsprabu/lil-node-app.git'
            }
        }
        // run sonarqube test
        stage('Run Sonarqube') {
            environment {
                scannerHome = tool 'sonarscanner';
            }
            steps {
              withSonarQubeEnv(credentialsId: 'sonarqubeid', installationName: 'sonarserver') {
                sh "${scannerHome}/bin/sonar-scanner"
              }
            }
        }
    }
}
