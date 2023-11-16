provider "aws" {
  region = "us-east-1" # Change this to your desired AWS region
}

resource "aws_instance" "jenkins_server" {
  ami           = "ami-0e8a34246278c21e4" # Choose a suitable Jenkins AMI
  instance_type = "t2.micro" # Choose a suitable instance type
  key_name      = "jenkins" # Specify your key pair name

  #security_group_names = ["jenkins_security_group"]

  user_data = <<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo yum install java-1.8.0 -y
              sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat-stable/jenkins.repo
              sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
              sudo yum install jenkins -y
              sudo service jenkins start
              EOF
}

resource "aws_security_group" "jenkins_security_group" {
  name        = "jenkins_security_group"
  description = "Security group for Jenkins server"

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol  = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

terraform {
  backend "s3" {
    bucket         = "week12-s3bucket"
    key            = "jenkins/terraform.tfstate"
    region         = "us-east-1" # Change this to your desired AWS region
    encrypt        = true
    dynamodb_table = "jenkins_lock"
  }
}
