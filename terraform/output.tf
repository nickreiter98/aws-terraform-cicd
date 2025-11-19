output "ec2_public_ip" {
    description = "The public IP address of the EC2 instance"
    value       = aws_instance.app.public_ip
}

output "ecr_url" {
    description = "The URL of the ECR repository"
    value       = aws_ecr_repository.app.repository_url
}

output "project_name" {
    description = "The name of the project"
    value       = var.project_name
}

output "aws_region" {
    description = "The AWS region"
    value       = var.aws_region
}

output "private_key_pem" {
  description   = "The private key in PEM format"
  value         = tls_private_key.ec2_ssh.private_key_pem
  sensitive     = true
}