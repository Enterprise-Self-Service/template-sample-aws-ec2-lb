resource "aws_lb" "alb" {
  name                       = var.alb_name
  internal                   = true
  load_balancer_type         = "application"
  subnets                    = local.subnet_ids
  enable_deletion_protection = false
  security_groups            = [aws_security_group.alb.id]
}


resource "aws_security_group" "alb" {
  name        = "allow_tls"
  description = "Allow TLS inbound traffic"
  vpc_id      = local.vpc_id

  ingress {
    description = "TLS from inet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    description = "LB out"
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_listener" "alb" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "443"
  protocol          = "HTTPS"
  certificate_arn   = aws_acm_certificate.default.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }
}

resource "aws_lb_listener_rule" "header" {
  listener_arn = aws_lb_listener.alb.arn

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }

  condition {
    host_header {
      values = [var.host_header]
    }
  }
}

resource "aws_lb_target_group" "alb" {
  name        = "alb-tg-http"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = local.vpc_id

  health_check {
    path                = "/"
    port                = "80"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = "200"
  }
  stickiness {
    type    = "lb_cookie"
    enabled = "true"
  }
}

resource "aws_lb_target_group_attachment" "alb" {
  for_each         = { for instance, config in aws_instance.instances : instance => instance }
  target_group_arn = aws_lb_target_group.alb.arn
  target_id        = aws_instance.instances[each.key].private_ip
  port             = 80
}



resource "aws_acm_certificate" "acm_certificate" {
  domain_name       = var.host_header
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}