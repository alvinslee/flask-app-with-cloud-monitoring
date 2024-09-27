# Get Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_vpc" "default" {
  default = true
}

data "template_cloudinit_config" "setup-script" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/x-shellscript"
    content = templatefile("${path.module}/scripts/setup.sh", {
      aws_region = var.region,
    })
  }
}
