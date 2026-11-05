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

data "aws_vpc" "default" {
  default = true
}

resource "aws_instance" "my_instance" {
  ami                         = var.my_instance_ami
  instance_type               = var.my_instance_type
  key_name                    = "key-pair"
  vpc_security_group_ids      = [aws_security_group.my_security_group.id]
  associate_public_ip_address = true

  # Enforce secure metadata access
  metadata_options {
    http_endpoint = "enabled"
    http_tokens   = "required"
  }

  # Root storage
  root_block_device {
    volume_size           = 25
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  tags = {
    Name = "MyInstance"
  }
}

resource "aws_security_group" "my_security_group" {
  name        = "my_security_group"
  description = "Allow SSH and HTTP traffic"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.my_ip_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "MyFinalSecurityGroup"
  }
}