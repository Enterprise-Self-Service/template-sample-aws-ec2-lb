data "aws_region" "current" {}

data "aws_vpcs" "main" {
  filter {
    # name   = "state"
    # values = ["available"]
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

data "aws_subnets" "main" {
  filter {
    name   = "vpc-id"
    values = [local.vpc_id]
  }
  filter {
    name   = "tag:Name"
    values = [var.subnet_name]
  }
  #   filter {
  #     name   = "cidr-block"
  #     values = ["10.*"]
  #   }
}

data "aws_ami" "amz-linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-gp2"]
  }
  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}


locals {
  vpc_id     = sort(data.aws_vpcs.main.ids)[0]
  subnet_ids = sort(data.aws_subnets.main.ids)
}