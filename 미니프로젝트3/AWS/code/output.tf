output "bastion_host_public_ip" {
  value = aws_instance.bastion_host.public_ip
}

output "rds_endpoint" {
  value = aws_db_instance.db-wordpress.endpoint
}

output "lb_endpoint" {
  value = aws_alb.wp-elb.dns_name
}