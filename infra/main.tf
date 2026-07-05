provider "aws" {
  region = "eu-north-1"
}

resource "aws_security_group" "devops-sg" {
  name        = "pipeline1"
  description = "Security group for DevOps pipeline"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 30080
    to_port     = 30080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

locals {
  instances = {
    dev-PC        = "dev-PC"
    jenkins-server = "jenkins-server"
    deploy-pc     = "deploy-pc"
  }
}

resource "aws_instance" "pipeline" {
  for_each      = local.instances
  ami           = "ami-0c50b6f7dc3701c44" # Ubuntu 22.04 eu-north-1
  instance_type = "t3.micro"
  key_name      = "pipeline"

  vpc_security_group_ids = [aws_security_group.devops-sg.id]

  tags = {
    Name = each.value
  }
}
