provider "aws" {
  region = var.region
}

# Security group for Flask instance
resource "aws_security_group" "flask_sg" {
  name        = "flask-app-sg"
  description = "Allow inbound HTTP traffic and SSH"

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "flask-app-sg"
  }
}

# EC2 instance
resource "aws_instance" "flask_instance" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.flask_sg.id]
  key_name                    = var.key_pair
  associate_public_ip_address = true

  user_data = file("${path.module}/scripts/setup.sh")

  tags = {
    Name = "FlaskAppInstance"
  }

  monitoring = true
}

# CloudWatch log group
resource "aws_cloudwatch_log_group" "flask_log_group" {
  name              = "/aws/ec2/flask-app"
  retention_in_days = var.log_retention_days
}

# IAM role for EC2 instance to access CloudWatch
resource "aws_iam_role" "ec2_role" {
  name = "ec2_cloudwatch_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action    = "sts:AssumeRole",
      Effect    = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# Attach policy to IAM role
resource "aws_iam_role_policy_attachment" "ec2_cloudwatch_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# IAM instance profile for EC2
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

# Attach the IAM instance profile to EC2 instance
resource "aws_instance" "flask_instance" {
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
}
