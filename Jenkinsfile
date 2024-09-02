pipeline {
    agent any

    environment {
        AWS_REGION = 'us-east-1'        // Replace with your AWS region
        ECR_REPO_NAME = 'prism'         // Replace with your ECR repository name
        IMAGE_TAG = '2.0'
        AWS_CREDENTIALS_ID = 'prism-ecr-user' // Jenkins credential ID for AWS
        AWS_ACCOUNT_ID = '664418988179'
        EC2_USER = 'ubuntu'            // Replace with your EC2 user
        EC2_HOST = 'ec2-3-83-42-221.compute-1.amazonaws.com' // Replace with your EC2 hostname or IP
    }

    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${ECR_REPO_NAME}:${IMAGE_TAG} ."
                }
            }
        }

        stage('Login to AWS ECR') {
            steps {
                script {
                    withCredentials([aws(accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: 'prism-ecr-user', secretKeyVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                        sh '''
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
                    sh "docker tag ${ECR_REPO_NAME}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}"
                    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}"
                }
            }
        }

        stage('Deploy') {
            steps {
                sshagent(credentials: ['ec2-ssh-key']) {
                    sh '''
                    ssh -o StrictHostKeyChecking=no ${EC2_USER}@${EC2_HOST} << EOF
                    # Commands to be executed on the remote server
                    echo "Deploying Docker container on remote server..."

                    # Login to AWS ECR on the remote server
                    LOGIN_PASSWORD=$(aws ecr get-login-password --region ${AWS_REGION})
                    echo $LOGIN_PASSWORD | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

                    # Pull the Docker image
                    docker pull ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}

                    # Run the Docker container
                    docker run -d --name prism --restart=unless-stopped ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}:${IMAGE_TAG}
                    EOF
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Docker image pushed and deployed successfully!'
        }
        failure {
            echo 'Build, push, or deploy failed.'
        }
    }
}

