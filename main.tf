# Required providers
provider "aws" {
  region = "us-east-1"
}

# IAM Role for CloudWatch
resource "aws_iam_role" "ec2_role" {
  name = "ec2_cloudwatch_role"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
}

# IAM policy to allow EC2 to write to CloudWatch
resource "aws_iam_policy" "cloudwatch_logs_policy" {
  name        = "ec2_cloudwatch_logs_policy"
  description = "EC2 instance policy to write logs to CloudWatch"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Effect": "Allow",
        "Resource": "*"
      }
    ]
  })
}

# Attach policy to the role
resource "aws_iam_role_policy_attachment" "attach_cloudwatch_logs" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.cloudwatch_logs_policy.arn
}

# EC2 Instance Profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

# Security group to allow SSH
resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
  description = "Allow SSH inbound traffic"

  ingress {
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
}

# Create EC2 micro instance
resource "aws_instance" "micro_instance" {
  ami                    = "ami-0c02fb55956c7d316" # Amazon Linux 2 AMI (Update as per your region)
  instance_type          = "t2.micro"
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  security_groups        = [aws_security_group.allow_ssh.name]
  key_name               = "your-key-pair" # Specify your key-pair

  tags = {
    Name = "MicroEC2Instance"
  }
}

# Enable CloudWatch logging for the EC2 instance
resource "null_resource" "setup_cloudwatch_logs" {
  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = aws_instance.micro_instance.public_ip
      user        = "ec2-user"
      private_key = file("~/.ssh/your-key.pem") # Update with your SSH key path
    }

    # Install CloudWatch Agent
    inline = [
      "sudo yum install -y amazon-cloudwatch-agent",
      "sudo amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c default -s",
    ]
  }

  depends_on = [aws_instance.micro_instance]
}

# Output the instance's public IP
output "instance_public_ip" {
  value = aws_instance.micro_instance.public_ip
}
