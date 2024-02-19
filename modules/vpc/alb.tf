resource "aws_alb" "ecs_alb" {
 name = "ecs-alb"
 internal = false
 load_balancer_type = "application"
 security_groups = [aws_security_group.alb_sg.id]

 enable_deletion_protection = false

 subnets = [aws_subnet.public_subnet_az1.id, aws_subnet.public_subnet_az2.id]

 enable_http2 = true-
 idle_timeout = var.idle_timeout

 enable_cross_zone_load_balancing = true

 tags = {
 Name = "ecs_alb"
 }
 }


# Redirect all traffic from the ALB to the target group
resource "aws_alb_listener" "front_end" {
  load_balancer_arn = aws_alb.ecs_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    target_group_arn = aws_alb_target_group.ecs_alb_tg.arn
    type             = "forward"
  }
}


resource "aws_alb_target_group" "ecs_alb_tg" {
 name = "ecs-alb-tg"
 port = 80
 protocol = "HTTP"
 vpc_id = aws_vpc.vpc.id
 target_type = "ip"

health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }

 }