#Bastion Host Security Group
resource "aws_security_group" "bastion_sg" {
  name   = "Allow SSH"
  vpc_id = module.app_vpc.vpc_id

  ingress { #inbound
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    #내 IP로부터의 접속만 허용
    cidr_blocks = ["1.236.233.38/32"]
  }

  egress { #outbound
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#EC2 Security Group
resource "aws_security_group" "wp_security" {
  name   = "Allow Bastion To EC2"
  vpc_id = module.app_vpc.vpc_id

  ingress { #inbound
    from_port = 22
    to_port   = 22
    protocol  = "tcp"
    #Bastion Host로부터의 접속만 허용
    cidr_blocks = ["${aws_instance.bastion_host.private_ip}/32"]
  }

  egress { #outbound
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#DB Security Group
resource "aws_security_group" "allow_to_rds" {
  name   = "Allow EC2 To RDS"
  vpc_id = module.app_vpc.vpc_id #output 참조

  ingress { #inbound
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    #EC2(wordpress server)로부터의 접속만 허용
    security_groups = [aws_security_group.wp_security.id]
  }

  egress { #outbound
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

#ALB Security Group 
resource "aws_security_group" "allow_http_sg" {
  name   = "Allow HTTP"
  vpc_id = module.app_vpc.vpc_id

  ingress { #inbound
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress { #outbound
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
