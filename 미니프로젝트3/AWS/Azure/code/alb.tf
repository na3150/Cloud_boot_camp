#Applicatioin Load Balancer
resource "aws_alb" "wp-elb" {
  name                             = "wp-alb"
  internal                         = false # internet facing 설정
  load_balancer_type               = "application"
  security_groups                  = [aws_security_group.allow_http_sg.id]                                # 외부에서 들어오는 HTTP 허용
  subnets                          = [module.app_vpc.public_subnets[0], module.app_vpc.public_subnets[1]] # public subnet에 위치
  enable_cross_zone_load_balancing = true
}

#Target Group
resource "aws_alb_target_group" "wp-elb-tg" {
  name     = "wp-alb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = module.app_vpc.vpc_id
}

#Load Balancer Listener
resource "aws_alb_listener" "wp-elb-listener" {
  load_balancer_arn = aws_alb.wp-elb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.wp-elb-tg.arn
  }
}