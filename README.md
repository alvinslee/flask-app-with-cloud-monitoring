# Simple EC2 -> Cloudwatch Example

Simple project for creating a small ec2 instance with cloudwatch monitoring.

## Set up

- Install [tenv](https://github.com/tofuutils/tenv)
- Install OpenTofu: `tenv tofu install 1.8.2`
- Set up `terraform.tfvars` credentials for AWS
- Run: `tofu apply`

*NOTE:* This runs the service in development mode as *root*. You really
shouldn't do that. *Use at your own risk.*
