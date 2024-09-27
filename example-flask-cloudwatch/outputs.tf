output "ec2_instance_public_ip" {
  value = module.flask_ec2.ec2_instance_public_ip
}

output "ec2_instance_public_dns" {
  value = module.flask_ec2.ec2_instance_public_dns
}

output "cloudwatch_log_group_name" {
  value = module.flask_ec2.cloudwatch_log_group_name
}
