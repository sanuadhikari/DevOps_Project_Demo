// my-hello-world-app-web: latest this is my image pipeline

pipeline {
    agent any // Specifies that the pipeline can run on any available Jenkins agent

    // Define environment variables used throughout the pipeline
    environment {
        EC2_HOST = "13.50.249.139" // Public IP or hostname of your EC2 instance
        SSH_CRED_ID = "AWS"       // ID of the SSH credentials stored in Jenkins
        REMOTE_PORT = "8081"      // Port on EC2 to expose the app
        REMOTE_USER = "ubuntu"    // User to SSH into the EC2 instance (use ec2-user for Amazon Linux)
    }

    // Define the sequence of stages in the pipeline
    stages {
        stage('Clone Repo') {
            steps {
                // Clone the source code from the Git repository
                git url: 'https://github.com/rax-ops/my-hello-world-app', branch: 'master'
            }
        }

        stage('Test Docker Access') {
            steps {
                // Verify that the Jenkins agent has the docker command available
                sh 'docker --version'
            }
        }

        stage('Build Docker Image') {
            steps {
                // Build the Docker image using the Dockerfile in the 'docker' directory
                // -t tags the image, -f specifies the Dockerfile path, . is the build context
                sh 'docker build -t hello-world-app -f Docker/Dockerfile .'
            }
        }

        stage('Save Docker Image') {
            steps {
                // Save the built Docker image as a tar archive
                // -o specifies the output file name
                sh 'docker save hello-world-app -o hello-world-app.tar'
            }
        }

        stage('Copy Image to EC2') {
            steps {
                // Use the Jenkins SSH Agent to make the SSH key available
                sshagent (credentials: [env.SSH_CRED_ID]) {
                    // Copy the image archive to the EC2 instance using scp
                    // -o StrictHostKeyChecking=no disables host key verification (use with caution!)
                    sh "scp -o StrictHostKeyChecking=no hello-world-app.tar ${REMOTE_USER}@${EC2_HOST}:/home/${REMATE_USER}/"
                }
            }
        }

        stage('Deploy on EC2') {
            steps {
                // Use the SSH Agent again
                sshagent (credentials: [env.SSH_CRED_ID]) {
                    // Connect to EC2 via ssh and execute commands
                    // The triple quotes allow for a multi-line shell script
                    sh """
                        ssh -o StrictHostKeyChecking=no ${REMOTE_USER}@${EC2_HOST} '
                            # Load the Docker image archive into the Docker daemon
                            docker load < hello-world-app.tar &&
                            # Stop and forcefully remove any existing container with the same name
                            # || true ensures the command doesn't fail if the container doesn't exist
                            docker rm -f hello-world-app || true &&
                            # Run a new container in detached mode (-d), mapping host port REMOTE_PORT to container port 80,
                            # and name the container
                            docker run -d -p ${REMOTE_PORT}:80 --name hello-world-app hello-world-app
                        '
                    """
                }
            }
        }
    }

    // Actions to perform after the main stages
    post {
        success {
            // If all stages succeed, print a completion message with the access URL
            echo "✅ Deployment complete: http://${EC2_HOST}:${REMOTE_PORT}"
        }
        // You could add other blocks like 'failure', 'always', 'cleanup', etc.
    }
}
