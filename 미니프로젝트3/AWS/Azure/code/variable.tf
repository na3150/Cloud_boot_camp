variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-2" #Seoul
}

variable "amazon-linux-2-ami" {
  description = "Amazon Linux 5.10 AMI Image"
  type        = string
  default     = "ami-02e05347a68e9c76f"
}

variable "db-user" {
  description = "RDS Wordpress User"
  type        = string
  default     = "wordpress"
}

variable "db-password" {
  description = "RDS Wordpress Password"
  type        = string
  default     = "skdud3150"
}


