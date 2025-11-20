#!/bin/bash

ECR_URL=$(jq -r '.ecr_url.value' ./terraform/outputs.json)
EC2_IP=$(jq -r '.ec2_public_ip.value' ./terraform/outputs.json)
AWS_REGION=$(jq -r '.aws_region.value' ./terraform/outputs.json)
PROJECT_NAME=$(jq -r '.project_name.value' ./terraform/outputs.json)

jq -r '.private_key_pem.value' ./terraform/outputs.json > ec2_key.pem
chmod 600 ec2_key.pem

echo "++++Building Docker image++++"
cd app
docker buildx build --platform linux/amd64 -t ${PROJECT_NAME}:latest --load .
# docker build -t ${PROJECT_NAME}:latest .
cd ..

echo "+++++Logging into AWS ECR++++"
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_URL}

echo "⬆️  ++++Pushing image to ECR++++"
docker tag ${PROJECT_NAME}:latest ${ECR_URL}:latest
docker push ${ECR_URL}:latest

echo "++++ Executing remote EC2 script ++++"
ssh -o StrictHostKeyChecking=no -i "ec2_key.pem" ec2-user@${EC2_IP} \
  "AWS_REGION='${AWS_REGION}' ECR_URL='${ECR_URL}' PROJECT_NAME='${PROJECT_NAME}' bash -s" \
  < ec2_run.sh