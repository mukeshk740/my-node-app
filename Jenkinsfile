pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'        // Replace with your AWS region
        ECR_REPO_NAME = 'prism'        // Replace with your ECR repository name
        IMAGE_TAG = '2.0'
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
					  withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'prism-ecr-user', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')])  {
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
	
         stage ('Deploy') {
             steps{
               sshagent(credentials : ['ec2-ssh-key-for-ubuntu-user']) {
               sh 'ssh -o StrictHostKeyChecking=no ubuntu@ec2-3-83-42-221.compute-1.amazonaws.com uptime'
               sh 'ssh -v ubuntu@ec2-3-83-42-221.compute-1.amazonaws.com '
                    // Login to AWS ECR using the credentials stored in Jenkins
					  withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'prism-ecr-user', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')])  {
                        sh '''	
                        # Login to AWS ECR
                        LOGIN_PASSWORD=$(aws ecr get-login-password --region ${AWS_REGION})
                        echo $LOGIN_PASSWORD | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com''	   
			   sh 'docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}'
               sh 'docker run -d --name prism  --restart=unless-stopped ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}'
              }
    }
  }
}
