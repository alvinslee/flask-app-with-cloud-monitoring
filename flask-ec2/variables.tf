variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "ami_id" {
  description = "AMI ID for EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "log_retention_days" {
  description = "Number of days to retain logs in CloudWatch"
  type        = number
  default     = 7
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
  default     = "FlaskAppInstance"
}

variable "aws_access_key" {}

variable "aws_secret_key" {}
