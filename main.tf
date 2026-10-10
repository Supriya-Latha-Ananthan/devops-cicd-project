
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "devops_server" {
  ami                    = "ami-08e3b3155fc937a94"
  instance_type          = "t3.micro"
  key_name               = "devops-cicd-key"
  vpc_security_group_ids = [aws_security_group.devops_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.devops_profile.name

  user_data = <<-EOF
    #!/bin/bash
    set -e

    dnf install -y awscli docker
    systemctl enable --now docker

    # Retry fetching the GitHub token while IAM permissions become available
    TOKEN=""
    for attempt in {1..12}; do
      TOKEN=$(aws ssm get-parameter \
        --name /devops/ghcr/token \
        --with-decryption \
        --region ap-south-1 \
        --query Parameter.Value \
        --output text) && break
      sleep 10
    done

    if [ -z "$TOKEN" ] || [ "$TOKEN" = "None" ]; then
      echo "ERROR: Could not retrieve GitHub token"
      exit 1
    fi

    echo "$TOKEN" | docker login ghcr.io \
      -u Supriya-Latha-Ananthan --password-stdin

    unset TOKEN

    docker pull ghcr.io/supriya-latha-ananthan/devops-cicd-app:11

    docker run -d \
      --name devops-app \
      --restart unless-stopped \
      -p 5000:5000 \
      ghcr.io/supriya-latha-ananthan/devops-cicd-app:11

    docker logout ghcr.io
  EOF

  tags = {
    Name = "DevOps-CICD-Server"
  }

  depends_on = [
    aws_iam_role_policy.read_ghcr_token
  ]
}

resource "aws_security_group" "devops_sg" {
  name        = "devops-cicd-sg"
  description = "Allow SSH and web application access"

  ingress {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["14.195.132.38/32"]
  }

  ingress {
    description = "Flask application"
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DevOps-CICD-Security-Group"
  }
}

resource "aws_iam_role" "ec2_role" {
  name = "DevOps-EC2-SSM-Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_instance_profile" "devops_profile" {
  name = "DevOps-EC2-Instance-Profile"
  role = aws_iam_role.ec2_role.name
}

resource "aws_iam_role_policy" "read_ghcr_token" {
  name = "Read-GHCR-Token"
  role = aws_iam_role.ec2_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ssm:GetParameter",
        "kms:Decrypt"
      ]
      Resource = [
        "arn:aws:ssm:ap-south-1:669964677858:parameter/devops/ghcr/token",
        "arn:aws:kms:ap-south-1:669964677858:key/*"
      ]
    }]
  })
}
output "ec2_public_ip" {
  description = "Public IP of the DevOps EC2 server"
  value       = aws_instance.devops_server.public_ip
}

output "application_url" {
  description = "URL of the deployed Flask application"
  value       = "http://${aws_instance.devops_server.public_ip}:5000"
}

