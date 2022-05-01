#RDS Subnet group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name = "db-wordpress-group"
  subnet_ids = [
    "${module.app_vpc.private_subnets[2]}",
    "${module.app_vpc.private_subnets[3]}"
  ]
}

#RDS Instance
resource "aws_db_instance" "db-wordpress" {
  allocated_storage    = 10
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  name                 = "wordpress"
  identifier           = "wordpress"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  username             = var.db-user
  password             = var.db-password
  #availability_zone    = module.app_vpc.private_subnets[2]
  parameter_group_name   = "default.mysql5.7"
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.allow_to_rds.id]
  multi_az = true #최종날에 생성 예정
}