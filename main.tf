terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_security_group" "web" {
  name        = "terraform-project-sg"
  description = "SSH and dashboard from my IP only"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  ingress {
    description = "Dashboard"
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [var.my_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "server" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web.id]

  user_data = <<-EOT
    #!/bin/bash
    apt-get update -y
    apt-get install -y docker.io docker-compose-v2
    systemctl enable --now docker
    usermod -aG docker ubuntu
    git clone https://github.com/Amruthjinesh/status-dashboard.git /home/ubuntu/status-dashboard
    printf 'DB_PASSWORD=%s\nTARGETS=%s\n' '${var.db_password}' 'self=http://localhost:8000' > /home/ubuntu/status-app.env
    chmod 600 /home/ubuntu/status-app.env
    ln -s /home/ubuntu/status-app.env /home/ubuntu/status-dashboard/.env
    chown -R ubuntu:ubuntu /home/ubuntu/status-dashboard /home/ubuntu/status-app.env
    cd /home/ubuntu/status-dashboard && docker compose up -d --build
  EOT

  tags = {
    Name = "terraform-project"
  }
}
