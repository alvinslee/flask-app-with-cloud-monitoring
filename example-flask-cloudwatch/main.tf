module "flask_ec2" {
  source             = "../tofu-flask-ec2"
  region             = "us-west-1"
  ami_id             = "ami-0f8e81a3da6e2510a"
  instance_type      = "t2.micro"
  instance_name      = "FlaskAppInstance"
  key_pair           = "flask-key"
  log_retention_days = 7
  aws_access_key     = var.aws_access_key
  aws_secret_key     = var.aws_secret_key
}
