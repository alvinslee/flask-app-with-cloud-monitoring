module "flask_ec2" {
  source            = "./terraform-flask-ec2"
  region            = "us-east-1"
  ami_id            = "ami-0abcdef1234567890"
  instance_type     = "t2.micro"
  key_pair          = "my-ssh-key"
  log_retention_days = 7
  aws_access_key    = var.aws_access_key
  aws_secret_key    = var.aws_secret_key
}
