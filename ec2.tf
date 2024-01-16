resource "aws_instance" "instances" {
  count                       = var.instance_count
  ami                         = data.aws_ami.amz-linux.id
  instance_type               = var.instance_type
  vpc_security_group_ids      = [aws_security_group.ec2.id]
  user_data                   = var.user_data
  user_data_replace_on_change = false
  subnet_id                   = local.subnet_ids[0]
  iam_instance_profile        = aws_iam_instance_profile.profile.name
  disable_api_termination     = false
  associate_public_ip_address = false

  root_block_device {
    volume_size           = var.disk_size
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  ebs_block_device {
    device_name           = "/dev/sdf"
    volume_type           = "gp3"
    volume_size           = 200
    delete_on_termination = true
  }

  lifecycle {
    ignore_changes = [
      subnet_id,
      tags,
      ami,
      root_block_device["volume_size"],
      root_block_device["volume_type"]
    ]
  }

  metadata_options {
    http_endpoint          = "enabled"
    instance_metadata_tags = "disabled"
  }
}


resource "aws_security_group" "ec2" {
  name        = "alb-ec2"
  description = "Allow HTTP inbound traffic from ALB"
  vpc_id      = local.vpc_id
}

resource "aws_security_group_rule" "alb-to-ec2" {
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
  security_group_id        = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "ec2-out" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.ec2.id
}

data "aws_iam_policy_document" "assume_role_ec2" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

data "aws_iam_policy" "cloudwatch" {
  name = "CloudWatchAgentServerPolicy"
}

data "aws_iam_policy" "ssm_core" {
  name = "AmazonSSMManagedInstanceCore"
}

data "aws_iam_policy" "ssm_patch" {
  name = "AmazonSSMPatchAssociation"
}

data "aws_iam_policy" "s3_full_access" {
  name = "AmazonS3FullAccess"
}

resource "aws_iam_role" "role" {
  name               = "rEC2Core"
  assume_role_policy = data.aws_iam_policy_document.assume_role_ec2.json
  managed_policy_arns = concat(
    [
      data.aws_iam_policy.cloudwatch.arn,
      data.aws_iam_policy.ssm_core.arn,
      data.aws_iam_policy.ssm_patch.arn,
      data.aws_iam_policy.s3_full_access.arn,
    ]
  )
}

resource "aws_iam_instance_profile" "profile" {
  name = "iEC2Core"
  role = aws_iam_role.role.name
}


