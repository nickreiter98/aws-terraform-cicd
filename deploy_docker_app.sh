#!/bin/bash

: "${AWS_REGION:?AWS_REGION is not set}"
: "${ECR_URL:?ECR_URL is not set}"
: "${PROJECT_NAME:?PROJECT_NAME is not set}"

echo "AWS_REGION=${AWS_REGION}"
echo "ECR_URL=${ECR_URL}"
echo "PROJECT_NAME=${PROJECT_NAME}"

echo "Updating packages and installing Docker..."
if command -v yum >/dev/null 2>&1; then
  sudo yum update -y
  sudo yum install -y docker
elif command -v apt-get >/dev/null 2>&1; then
  sudo apt-get update -y
  sudo apt-get install -y docker.io
fi

echo "Starting Docker..."
sudo systemctl enable docker || true
sudo systemctl start docker || sudo service docker start

echo "Logging into ECR..."
aws ecr get-login-password --region ${AWS_REGION} \
  | sudo docker login --username AWS --password-stdin ${ECR_URL}

echo "Pulling latest Docker image..."
sudo docker pull ${ECR_URL}:latest

echo "Stopping old container (if exists)..."
sudo docker stop ${PROJECT_NAME} || true
sudo docker rm ${PROJECT_NAME} || true

echo "Running container (${PROJECT_NAME}) on port 8080..."
sudo docker run -d --name ${PROJECT_NAME} -p 8080:8080 ${ECR_URL}:latest

echo "Container started successfully."