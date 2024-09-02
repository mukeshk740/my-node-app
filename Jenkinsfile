pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'        // Replace with your AWS region
        ECR_REPO_NAME = 'prism'        // Replace with your ECR repository name
//        IMAGE_TAG = 'latest'
        AWS_CREDENTIALS_ID = 'prism-ecr-user' // Jenkins credential ID for AWS
		AWS_ACCOUNT_ID = '664418988179'
    }

    stages {
        stage('Checkout Code') {
            steps {
                // Checkout your code from Git repository
                checkout scm
            }
        }
		
		 stage('Load Environment Variables') {
            steps {
                script {
                    // Load environment variables from .env file
                    def envVars = readFile('.env').split('\n')
                    envVars.each { line ->
                        def (key, value) = line.split('=')
                        if (key == 'IMAGE_TAG') {
                            env.IMAGE_TAG = value.trim()
                        }
                    }
                }
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    // Build the Docker image
                    sh 'docker build -t ${ECR_REPO_NAME}:${IMAGE_TAG} .'
                }
            }
        }

        stage('Login to AWS ECR') {
            steps {
                script {
                    // Login to AWS ECR using the credentials stored in Jenkins
                    withCredentials([usernamePassword(credentialsId: "${AWS_CREDENTIALS_ID}", passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                        sh '''
                        # Login to AWS ECR
                        LOGIN_PASSWORD=$(aws ecr get-login-password --region ${AWS_REGION})
                        echo $LOGIN_PASSWORD | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com
                        '''
                    }
                }
            }
        }

        stage('Tag and Push Docker Image') {
            steps {
                script {
                    // Tag the Docker image
                    sh "docker tag ${ECR_REPO_NAME}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}"
                    
                    // Push the Docker image to ECR
                    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}"
                }
            }
        }
    }

    post {
        success {
            echo 'Docker image pushed successfully!'
        }
        failure {
            echo 'Build or push failed.'
        }
    }
}
