terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region     = "ap-south-1"
  access_key = var.access_key
  secret_key = var.secret_key
}

# Reference the default VPC
resource "aws_default_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

# Create a subnet in the default VPC
resource "aws_subnet" "main" {
  vpc_id            = aws_default_vpc.default.id
  cidr_block        = "172.31.100.0/24"  # Adjust CIDR block as needed, ensure it fits within the VPC's CIDR
  availability_zone = "ap-south-1a"      # Specify an availability zone in ap-south-1
  map_public_ip_on_launch = true         # Enable public IP for instances in this subnet

  tags = {
    Name = "monitoring-subnet"
  }
}

# Create security group for the EC2 instance
resource "aws_security_group" "ec2_security_group" {
  name        = "ec2 security group"
  description = "allow access on ports 22"
  vpc_id      = aws_default_vpc.default.id  # Associate with the default VPC

  # Allow access on port 22
  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
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
    Name = "Monitoring server security group"
  }
}

# Create EC2 instance
resource "aws_instance" "Monitoring_server" {
  ami             = "ami-00bb6a80f01f03502"
  instance_type   = "t2.medium"
  subnet_id       = aws_subnet.main.id  # Reference the created subnet
  security_groups = [aws_security_group.ec2_security_group.name]
  key_name        = var.key_name

  tags = {
    Name = var.instance_name
  }
}
