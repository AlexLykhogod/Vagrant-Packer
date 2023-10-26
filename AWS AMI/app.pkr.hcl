packer {
  required_plugins {
    amazon = {
      version = ">= 1.0.9"
      source  = "github.com/hashicorp/amazon"
    }
  }
}
# Vars
variable "app-instance-type" {
  type    = string
  default = "t3.micro"
}

variable "aws-region" {
  type    = string
  default = "us-west-2"
}

# Locals
locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  common_tags = {
    OS      = "Ubuntu"
    Release = "latest"
    Type    = "Demo 29.06"
  }
}


# Source
source "amazon-ebs" "ubuntu" {
  ami_name      = "wa-packer-aws-ebs-${local.timestamp}"
  instance_type = "${var.app-instance-type}"
  region        = "${var.aws-region}"
  source_ami_filter {
    filters = {
      virtualization-type = "hvm"
      name                = "ubuntu/images/*ubuntu-jammy-22.04-amd64-server-*"
      root-device-type    = "ebs"
    }
    owners      = ["099720109477"]
    most_recent = true
  }
  ssh_username = "ubuntu"
  tags         = local.common_tags
}

# Build
build {
  name = "wa-app-build"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]
  provisioner "shell" {
    environment_vars = ["ENV_NAME=DEMO"]
    pause_before     = "10s"
    inline = [
      "echo Wellcome to $ENV_NAME",
      "sudo apt update",
      "sudo apt install -y git"
    ]
  }
  provisioner "breakpoint" {
    disable = false
    note    = "Test breakpoint: ${local.timestamp}"
  }
  provisioner "shell" {
    pause_before = "10s"
    script       = "./script/app.sh"
  }
}