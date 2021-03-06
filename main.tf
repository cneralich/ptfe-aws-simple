locals {
  namespace = "your-name-here"
}

# PROVIDER CONFIGURATION - AWS
provider "aws" {
  region     = "${var.region}"
}

# RESOURCE CONFIGURATION - AWS
resource "aws_instance" "main" {
  ami           = "${data.aws_ami.ubuntu.id}"
  instance_type = "m5.large"
  key_name = "${var.key_name}"
  associate_public_ip_address = true
  vpc_security_group_ids = ["${aws_security_group.main.id}"]
  depends_on = ["aws_security_group.main"]

  root_block_device {
    volume_size = "60"
  }

  tags {
    Name = "${local.namespace} instance"
    owner = "youremail@email.com"
    TTL = 24
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true

  tags {
    Name = "${local.namespace}-vpc"
  }
}

resource "aws_security_group" "main" {
  name = "${local.namespace}-sg"
  description = "${local.namespace} security group"

  ingress {
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 8800
    to_port     = 8800
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}
