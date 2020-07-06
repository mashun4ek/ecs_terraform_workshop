resource "aws_lb" "test-lb" {
  name               = "test-ecs-lb"
  load_balancer_type = "application"
  internal           = false
  subnets            = module.vpc.public_subnets
  tags = {
    "env"       = "dev"
    "createdBy" = "mkerimova"
  }
  security_groups = [aws_security_group.lb.id]
}

resource "aws_security_group" "lb" {
  name   = "allow-all-lb"
  vpc_id = data.aws_vpc.main.id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "env"       = "dev"
    "createdBy" = "mkerimova"
  }
}

resource "aws_lb_target_group" "lb_target_group" {
  name        = "masha-target-group"
  port        = "80"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.main.id
  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = "200,301,302"
  }
}

resource "aws_lb_listener" "web-listener" {
  load_balancer_arn = aws_lb.test-lb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }
}