#Key Pair
resource "aws_key_pair" "wordpress_server_key" {
  key_name   = "wordpress_server-key"
  public_key = file("/home/vagrant/.ssh/id_rsa.pub")
}


################################################################################
# Bastion Host
################################################################################


resource "aws_instance" "bastion_host" {

  ami                    = var.amazon-linux-2-ami
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]
  key_name               = aws_key_pair.wordpress_server_key.key_name
  subnet_id              = module.app_vpc.public_subnets[0]

  connection {
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("/home/vagrant/.ssh/id_rsa")
    timeout     = "1m"
  }

  provisioner "file" {
    source      = "/home/vagrant/.ssh/id_rsa"
    destination = "/tmp/key_file"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo cp /tmp/key_file /home/ec2-user/.ssh/id_rsa",
      "sudo chmod 400 /home/ec2-user/.ssh/id_rsa"
    ]
  }

  tags = {
    Name = "Bastion Host"
  }
}


################################################################################
# EC2 AMI
################################################################################


#AMI를 위한 EC2 생성
#EC2에 wordpress 구성 후 AMI 생성
resource "aws_instance" "instance_for_ami" {

  #RDS 엔드포인트가 필요하기 때문에, rds 생성 후 EC2 생성
  depends_on = [
    aws_db_instance.db-wordpress
  ]

  ami                    = var.amazon-linux-2-ami
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.wp_security.id]
  key_name               = aws_key_pair.wordpress_server_key.key_name
  subnet_id              = module.app_vpc.private_subnets[0]

  connection {
    user        = "ec2-user"
    host        = self.private_ip
    private_key = file("~/.ssh/id_rsa")
    timeout     = "1m"

    bastion_user        = "ec2-user"
    bastion_host        = aws_instance.bastion_host.public_ip
    bastion_private_key = file("~/.ssh/id_rsa")
  }

  #yaml 파일 복사
  provisioner "file" {
    source      = "wp"
    destination = "wp"
  }

  #ansible 설치 및 playbook 실행
  provisioner "remote-exec" {
    inline = [
      #ansible 설치
      "sudo amazon-linux-extras install -y ansible2",
      #RDS 엔트포인트 수정
      "sed -i 's/rdsendpoint/${aws_db_instance.db-wordpress.endpoint}/g' /home/ec2-user/wp/roles/wordpress/vars/main.yaml",
      #playbook 실행
      "ansible-playbook --connection=local --inventory 127.0.0.1, --limit 127.0.0.1 /home/ec2-user/wp/wordpress.yaml -b"
    ]
  }

  tags = {
    Name = "Instance for AMI"
  }
}

#EC2 인스턴스로 AMI 생성
resource "aws_ami_from_instance" "wordpress_ami" {
  name               = "wordpress_ami"
  source_instance_id = aws_instance.instance_for_ami.id

  #인스턴스 생성 후에 ami 생성
  depends_on = [
    aws_instance.instance_for_ami
  ]
}


################################################################################
# Launch template
################################################################################


resource "aws_launch_template" "wordpress_template" {

  depends_on = [
    aws_db_instance.db-wordpress
  ]

  name        = "wordpress_template"
  description = "wordpress template for atsg v1.0"

  image_id                             = aws_ami_from_instance.wordpress_ami.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t2.micro"
  key_name                             = aws_key_pair.wordpress_server_key.key_name
  vpc_security_group_ids               = [aws_security_group.wp_security.id, aws_security_group.allow_http_sg.id]

  monitoring {
    enabled = true
  }

  placement {
    availability_zone = var.aws_region
  }

  tags = {
    Name = "wordpress template"
  }

}


################################################################################
# AutoScaling
################################################################################


#AutoScaling attachment
resource "aws_autoscaling_attachment" "wp-atsg-attach" {
  autoscaling_group_name = aws_autoscaling_group.wp_atsg.name
  alb_target_group_arn   = aws_alb_target_group.wp-elb-tg.arn
}

#AutoScaling Group
resource "aws_autoscaling_group" "wp_atsg" {
  name                      = "wordpress-autoscaling"
  health_check_type         = "ELB"
  health_check_grace_period = 120
  force_delete              = true

  vpc_zone_identifier = [
    module.app_vpc.private_subnets[0],
    module.app_vpc.private_subnets[1]
  ]

  termination_policies = ["OldestInstance"]
  launch_template {
    id      = aws_launch_template.wordpress_template.id
    version = aws_launch_template.wordpress_template.latest_version
  }

  desired_capacity = 2
  min_size         = 2 #최소용량
  max_size         = 4 #최대용량

  lifecycle {
    create_before_destroy = true
  }

  target_group_arns = [aws_alb_target_group.wp-elb-tg.arn]
}