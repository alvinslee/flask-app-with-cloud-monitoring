output "ec2_instance_public_ip" {
  value = aws_instance.flask_instance.public_ip
  description = "Public IP of the EC2 instance hosting Flask"
}

output "cloudwatch_log_group_name" {
  value = aws_cloudwatch_log_group.flask_log_group.name
  description = "Name of CloudWatch log group for Flask logs"
}
