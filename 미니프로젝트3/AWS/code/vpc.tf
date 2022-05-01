module "app_vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "wordpress_vpc"
  cidr = "10.0.0.0/16"

  enable_nat_gateway     = true
  single_nat_gateway     = false
  one_nat_gateway_per_az = true #AZ 1개당 NAT Gateway 생성

  create_igw = true

  azs = [
    "ap-northeast-2a",
    "ap-northeast-2c"
  ]

  public_subnets = [
    "10.0.0.0/24",
    "10.0.1.0/24"
  ]

  private_subnets = [
    "10.0.2.0/24",
    "10.0.3.0/24",
    "10.0.4.0/24",
    "10.0.5.0/24"
  ]
}