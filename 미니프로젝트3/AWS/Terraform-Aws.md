# # IaC를 이용해 AWS에 Wordpress 자동화 배포
---

<br>

## 아키텍쳐

<img style="border-radius: 7px;-moz-border-radius: 7px;-khtml-border-radius: 7px;-webkit-border-radius: 7px;" src="https://github.com/RungLyeok/pj3/blob/main/%EC%8B%9C%EC%8A%A4%ED%85%9C%20%EC%95%84%ED%82%A4%ED%85%8D%EC%B2%98.png?raw=true" />

Bastion Host를 Public Subnet에 구성하고 Web Server와 DB 서버를 Private Subnet에 구성함으로써 보안을 강화하고 Application Load Balancer와 AutoScaling를 활용하여 외부 트패픽 분산, 클라우드의 유연성을 강화하여 가용성을 확보하였다.

<br>
<br>

##  프로젝트 환경

--- 
###  테스트 컴퓨터 환경

|Resource|Configuration|
|-|-|
|CPU|2|
|Memory|4096MB|
|Disk|40GB|
|OS|CentOS 7|
|Hostname|controller|

<br>

### 구성 관리 / 배포 도구

>위 도구들을 Managed Server(현재 Controller)에 설치한다.

| Name | Version|
|-|-|
|Terraform| v 1.1.9 on linux_amd64|
| Ansible | v 2.9.27|
||python v 2.7.5 필요|
|Azure CLI|v 2.36.0|
||Python (Linux) 3.6.8 필요|

<br>
<br>

---

# Terraform _AWS 구성

## 1. 환경 구성

<br>

###  1-1. Ansible 설치

```
$ sudo yum install -y centos-release-ansible-29

$ sudo yum install -y ansible

# 설치 확인
$ ansible --version

ansible 2.9.27
  config file = /etc/ansible/ansible.cfg
  configured module search path = [u'/home/vagrant/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/site-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.5 (default, Nov 16 2020, 22:23:17) [GCC 4.8.5 20150623 (Red Hat 4.8.5-44)]
```

<br>

### 1-2. Terraform 설치

```
$ sudo yum install -y yum-utils

$ sudo yum-config-manager --add-repo 
https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo

$ sudo yum -y install terraform

# 설치 확인
$ terraform --version
Terraform v1.1.9
on linux_amd64
+ provider registry.terraform.io/hashicorp/aws v3.75.1

```

<br>

### 1-3. AWS IAM 사용자 생성

|AWS|IAM|
|-|-|
|Name| pj3-aws |
|권한|AdministratorAccess|

<br>

### 1-4. AWS CLI 설치

```
$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

$ sudo yum -y install unzip

$ unzip awscliv2.zip

$ sudo ./aws/install

$ aws configure 
AWS Access Key ID [****************ZSU2]: [AWS Access Key ID]
AWS Secret Access Key [****************2c+h]: [AWS Seret Access Key]
Default region name [us-east-1]: ap-northeast-2
Default output format [None]:

$ aws sts get-caller-identity
{
    "UserId": "AIDAY2HZGB5LD3PB5WF5V",
    "Account": "606112976726",
    "Arn": "arn:aws:iam::606112976726:user/pj3_aws"
}
```

<br>
<br>

---

## 2. 리소스 생성 및 배포

<br>

### 사용한 리소스
|Resource|Description|
|-|-|
|aws vpc module|AWS VPC 마법사와 같은 기능을 하는 모듈|
|aws_key_pair|AWS keypair를 생성하는 리소스|
|azurerm_network_security_group|AWS 보안그룹을 생성하는 리소스|
|aws_instance|  AWS EC2 를 생성하는 리소스 |
|aws_db_subnet_group|AWS RDS 를 생성하기 위해 필요한 서브넷 그룹을 생성하는 리소스|
|aws_db_instance|AWS RDS를 생성하는 리소스 |
|aws_alb_target_group|AWS ALB를 생성하는데 필요한 타겟 그룹을 생성하는 리소스|
|aws_alb|AWS ALB를 생성하는 리소스|
|aws_ami_from_instance|AWS AMI를 생성하는 리소스|
|aws_launch_template| AWS 시작템플릿을 생성하는 리소스|
|aws_autoscaling_group| AWS AutoScailing 생성하는 리소스 |


<br>
<br>

### 2-1. AWS_Provider 지정 
---
provier.tf 파일에 Terraform Block과 Provider Block을 작성을 작성한다.
AWS provider를 정의하고, 버전에 대한 설정을 한다.

#### `provider.tf`  

```
terraform {

  required_providers {  
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }    
  }
  
  required_version = ">= 0.14.9"
  
}

provider "aws" {

  profile = "default"
  region  = "ap-northeast-2" #Seoul
  
}
```

작성 후 `$ terraform init` 명령어를 실행시켜 providers와 모듈을 업데이트를 시켜준다.

<br>

### 2-2. AWS_VPC 생성 
---

public 서브넷 2개
private 서브넷 4개
가용영역(azs) :  "ap-northeast-2a", "ap-northeast-2c" 
Internet gateway  생성
Nat gateway AZ당 1개씩  생성 

####  `vpc.tf`

>모듈 : [aws vpc module](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest)

```
module "app_vpc" {

 source = "terraform-aws-modules/vpc/aws"
 name = "wordpress_vpc"
 cidr = "10.0.0.0/16"

 enable_nat_gateway = true
 single_nat_gateway = false![[vpc.png]]
 one_nat_gateway_per_az = true 

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
```

| Inputs                 | value           |
| ---------------------- | --------------- |
| name                   | "wordpress_vpc" |
| cidr                   | "10.0.0.0/16"   |
| enable_nat_gateway     | true            |
| single_nat_gateway     | false           |
| one_nat_gateway_per_az | true            |

VPC
<img style="border-radius: 7px;-moz-border-radius: 7px;-khtml-border-radius: 7px;-webkit-border-radius: 7px;" src="https://github.com/RungLyeok/pj3/blob/main/vpc.png?raw=true" />

Subnet
<img style="border-radius: 7px;-moz-border-radius: 7px;-khtml-border-radius: 7px;-webkit-border-radius: 7px;" src="https://github.com/RungLyeok/pj3/blob/main/%EC%84%9C%EB%B8%8C%EB%84%B7.png?raw=true" />

<br>
<br>

## 2-3. AWS_key pair생성
---

#### `key.tf`

>리소스 : aws_key_pair

생성 할 EC2 에서 사용할 키를 생성한다.
vagrant에 있는 퍼블릭키를  ` file `로 복사하여 ` public_key `로 사용한다.

```
#Key Pair

resource "aws_key_pair" "wordpress_server_key" {

 key_name = "wordpress_server-key"
 
 public_key = file("/home/vagrant/.ssh/id_rsa.pub")

}
```

key pair
<img style="border-radius: 7px;-moz-border-radius: 7px;-khtml-border-radius: 7px;-webkit-border-radius: 7px;" src="https://github.com/RungLyeok/pj3/blob/main/%ED%82%A4%ED%8E%98%EC%96%B4.png?raw=true" />

<br>
<br>

## 2-4. AWS_EC2 생성
---

###  2-4-1. bastion_host

#### `security_group.tf`

>리소스 : aws_security_group

SSH 프로토콜을 사용하여 `Bastion Host`에 로그인하고 구성할 수 있도록 현재 IP 주소(내 IP)에서 들어오는 SSH 트래픽을 허용합니다.

```
#Bastion Host Security Group

resource "aws_security_group" "bastion_sg" {
 name = "Allow SSH"
 vpc_id = module.app_vpc.vpc_id

 ingress { # 인바운드 규칙
 from_port = 22
 to_port = 22
 protocol = "tcp"
 cidr_blocks = ["[ my ip ]/32"]
 }

 egress { # 아웃바운드 규칙
 from_port = 0
 to_port = 0
 protocol = "-1"
 cidr_blocks = ["0.0.0.0/0"]
 }
}

```

bastion_sg 보안그룹
<img style="border-radius: 7px;-moz-border-radius: 7px;-khtml-border-radius: 7px;-webkit-border-radius: 7px;" src="https://github.com/RungLyeok/pj3/blob/main/ssh%20%EB%B3%B4%EC%95%88%EA%B7%B8%EB%A3%B9.png?raw=true" />

<br>

#### `variable.tf`

여러 곳에 쓰이는 단어를 한번에 바꿀수 있도록 변수로 정의한다.

```
# region
variable "aws_region" {

 description = "AWS Region"
 type = string
 default = "ap-northeast-2" #Seoul
 
}


# ami
variable "amazon-linux-2-ami" {

 description = "Amazon Linux 5.10 AMI Image"
 type = string
 default = "ami-02e05347a68e9c76f"

}
```

<br>


#### `main.tf`

>리소스 : aws_instance

`bastion_host` 의 EC2 를 생성할 리소스를 작성한다.
앞에서 생성한 보안그룹, 퍼블릭키,  퍼블릭 서브넷 1번째 등을 연결한다.

```
resource "aws_instance" "bastion_host" {

 ami = var.amazon-linux-2-ami
 instance_type = "t2.micro"
 vpc_security_group_ids = [aws_security_group.bastion_sg.id]
 key_name = aws_key_pair.wordpress_server_key.key_name
 subnet_id = module.app_vpc.public_subnets[0]

}
```

bastion EC2
<img style="border-radius: 7px;-moz-border-radius: 7px;-khtml-border-radius: 7px;-webkit-border-radius: 7px;" src="https://github.com/RungLyeok/pj3/blob/main/bastion%20ec2.png?raw=true" />

<br>

### 2-4-2. wordrpess_ec2 생성

#### `security_group.tf`

>리소스 : aws_security_group

bastion_sg으로 보안그룹 설정된 host만 접속할 수 있게 설정한다.

```
#EC2 Security Group

resource "aws_security_group" "wp_security" {

 name = "Allow Bastion To EC2"
 vpc_id = module.app_vpc.vpc_id

 ingress { #inbound 
 from_port = 22
 to_port = 22
 protocol = "tcp"
 security_groups = [aws_security_group.bastion_sg.id]

 }
  
 egress { #outbound
 from_port = 0
 to_port = 0
 protocol = "-1"
 cidr_blocks = ["0.0.0.0/0"]

 }
}
```

Allow Bastion To EC2 보안그룹
<img style="border-radius: 7px;-moz-border-radius: 7px;-khtml-border-radius: 7px;-webkit-border-radius: 7px;" src="https://github.com/RungLyeok/pj3/blob/main/bastion%20%EB%B3%B4%EC%95%88%EA%B7%B8%EB%A3%B9.png?raw=true" />

<br>

#### `main.tf`

>리소스 : aws_instance

`remote-exec` , `file`  프로비저너를 사용하기위해 `connection`을 작성한다.
`file`  이용하여 wordpress를 배포할 때 사용할 playbook를 복사한다.
`remote-exec`  사용하여 다음을 실행한다.
  - ansible 설치
  - rds 엔드포인트 수정 
  - playbook 로컬 실행
  
 rds의 엔드포인트가 필요하기 떄문에 rds를 생성 후 생성되도록 `depends_on` 설정을 한다.
 
```
resource "aws_instance" "wordpress_host" {

 depends_on = [
 aws_db_instance.db-wordpress
 ]

 ami = var.amazon-linux-2-ami
 instance_type = "t2.micro"
 vpc_security_group_ids = [aws_security_group.wp_security.id]
 key_name = aws_key_pair.wordpress_server_key.key_name
 subnet_id = module.app_vpc.private_subnets[0]
 
 connection {
 user = "ec2-user"
 host = self.private_ip
 private_key = file("~/.ssh/id_rsa")
 timeout = "1m"

 bastion_user = "ec2-user"
 bastion_host = aws_instance.bastion_host.public_ip
 bastion_private_key = file("~/.ssh/id_rsa")

 }

 #yaml 파일 복사
 provisioner "file" {
 source = "wp"
 destination = "wp"

 }

 #ansible 설치 및 playbook 실행
 provisioner "remote-exec" {
 inline = [
 
 #ansible 설치
 "sudo amazon-linux-extras install -y epel",
 "sudo amazon-linux-extras install -y ansible2",
 
 #RDS 엔트포인트 수정
 "sed -i 's/rdsendpoint/${aws_db_instance.db-wordpress.endpoint}/g' /home/ec2-user/wp/roles/wordpress/vars/main.yaml",

 #playbook 실행
 "ansible-playbook --connection=local --inventory 127.0.0.1, --limit 127.0.0.1 /home/ec2-user/wp/wordpress.yaml -b"

 ]
 }
 }
}
```

wordpress_host
<img style="border-radius: 7px;-moz-border-radius: 7px;-khtml-border-radius: 7px;-webkit-border-radius: 7px;" src="https://github.com/RungLyeok/pj3/blob/main/web_suber.png?raw=true" />

<br>
<br>

## 2-5.  AWS_RDS 생성
---

### 2-5-1. 보안그룹생성

#### `security_group.tf`

>리소스 : aws_security_group

3306 포트를  EC2(wordpress  host)로부터의 접속만 허용도록 설정한다.

```
#DB Security Group

resource "aws_security_group" "allow_to_rds" {
 name = "Allow EC2 To RDS"
 vpc_id = module.app_vpc.vpc_id 

  

 ingress { #inbound
 from_port = 3306
 to_port = 3306
 protocol = "tcp"
 security_groups = [aws_security_group.wp_security.id]

 }

  
 egress { #outbound
 from_port = 0
 to_port = 0
 protocol = "-1"
 cidr_blocks = ["0.0.0.0/0"]

 }
}
```

RDS 보안그룹
<img style="border-radius: 7px;-moz-border-radius: 7px;-khtml-border-radius: 7px;-webkit-border-radius: 7px;" src="https://github.com/RungLyeok/pj3/blob/main/rds%20%EB%B3%B4%EC%95%88%EA%B7%B8%EB%A3%B9.png?raw=true" />

<br>

### 2-5-2. 변수 지정

#### `variable.tf`

데이터베이스의 `username` ,  `password` 를 변수로 지정한다.

``` 
variable "db-user" {

 description = "RDS Wordpress User"
 type = string
 default = "wordpress"

}
  
variable "db-password" {

 description = "RDS Wordpress Password"
 type = string
 default = "[db password]"

}
```

<br>

### 2-5-3. 서브넷 그룹 생성

#### `rds.tf`

>리소스 : aws_db_subnet_group

RDS를 생성하기 위해서는 2개 이상의 서브넷과 연결해줘야 한다.
따라서 서브넷 그룹에 private 서브넷을 지정하여 만들어 준다.

```
#RDS Subnet group

resource "aws_db_subnet_group" "rds_subnet_group" {

 name       = "db-wordpress-group"
 subnet_ids = ["${module.app_vpc.private_subnets[1]}", "${module.app_vpc.private_subnets[2]}"]

}
```

RDS 서브넷 그룹
<img style="border-radius: 7px;-moz-border-radius: 7px;-khtml-border-radius: 7px;-webkit-border-radius: 7px;" src="https://github.com/RungLyeok/pj3/blob/main/rds%20%EC%84%9C%EB%B8%8C%EB%84%B7%EA%B7%B8%EB%A3%B9.png?raw=true" />

<br>

### 2-5-4. RDS 생성

>리소스 : aws_db_instance

mysql을 사용하며 버전은 8.0.28 을 사용한다.
RDS 복제본 기능을 활성화 하여 고가용성 확보한다.

```
#RDS Instance

resource "aws_db_instance" "db-wordpress" {

 allocated_storage = 10
 engine = "mysql"
 engine_version = "8.0.28"
 instance_class = "db.t2.micro"
 name = "wordpress"
 identifier = "wordpress"
 db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
 username = var.db-user
 password = var.db-password
 parameter_group_name = "default.mysql8.0.28"
 skip_final_snapshot = true
 vpc_security_group_ids = [aws_security_group.allow_to_rds.id]
 multi_az = true

}
```

RDS
<img style="border-radius: 7px;-moz-border-radius: 7px;-khtml-border-radius: 7px;-webkit-border-radius: 7px;" src="https://github.com/RungLyeok/pj3/blob/main/RDS.png?raw=true" />

<br>
<br>

## 2-6. AWS_Load Balancing 구성
---

### 2-6-1.  보안그룹 생성
#### `security_group.tf`

>리소스 : aws_security_group

HTTP을 허용해주는 보안그룹을 작성한다.

```
#allow_http_sg

resource "aws_security_group" "allow_http_sg" {

 name = "Allow HTTP"
 vpc_id = module.app_vpc.vpc_id
  
 ingress { #inbound
 from_port = 80
 to_port = 80
 protocol = "tcp"
 cidr_blocks = ["0.0.0.0/0"]

 }

 egress { #outbound
 from_port = 0
 to_port = 0
 protocol = "-1"
 cidr_blocks = ["0.0.0.0/0"]

 }
```

Allow HTTP 보안그룹
<img style="border-radius: 7px;-moz-border-radius: 7px;-khtml-border-radius: 7px;-webkit-border-radius: 7px;" src="https://github.com/RungLyeok/pj3/blob/main/Allow%20HTTP.png?raw=true" />

<br>

### 2-6-2.  타겟그룹 생성

>리소스 : aws_alb_target_group

```
resource "aws_alb_target_group" "wp-alb-tg" {

 name = "wp-alb-tg"
 port = 80
 protocol = "HTTP"
 vpc_id = module.app_vpc.vpc_id

}
```

타겟그룹 
<img style="border-radius: 7px;-moz-border-radius: 7px;-khtml-border-radius: 7px;-webkit-border-radius: 7px;" src="https://github.com/RungLyeok/pj3/blob/main/%ED%83%80%EA%B2%9F%EA%B7%B8%EB%A3%B9.png?raw=true" />

<br>

### 2-6-3.  ALB 생성

>리소스 : aws_alb

외부 사용자가 HTTP를 통해 접속할수 있도록  보안그룹과 연결한다.

```
#Applicatioin Load Balancer

resource "aws_alb" "wp-alb" {

 name = "wp-alb"
 internal = false # internet facing 설정
 load_balancer_type = "application"
 security_groups = [aws_security_group.allow_http_sg.id] # 외부에서 들어오는 HTTP 허용
 subnets = [module.app_vpc.public_subnets[0], module.app_vpc.public_subnets[1]] 
 enable_cross_zone_load_balancing = true

}
```

로드밸런서 
<img style="border-radius: 7px;-moz-border-radius: 7px;-khtml-border-radius: 7px;-webkit-border-radius: 7px;" src="https://github.com/RungLyeok/pj3/blob/main/%EB%A1%9C%EB%93%9C%EB%B0%B8%EB%9F%B0%EC%84%9C.png?raw=true" />

<br>

### 2-6-4.  LB와 타겟그룹 연결

>리소스 : aws_alb_listener

생성한 타겟 그룹과  ALB를 연결해준다.

```
#Load Balancer Listener

resource "aws_alb_listener" "wp-alb-listener" {

 load_balancer_arn = aws_alb.wp-alb.arn
 port = 80
 protocol = "HTTP"
 default_action {
 type = "forward"
 target_group_arn = aws_alb_target_group.wp-alb-tg.arn

 }
}
```

<br>

#### `output.tf`

>`output`은 terraform으로 생성시에 정의한 내용들을 출력해준다.
>
>`bastion_host - public_ip`
>`lb - dns_name`
>접속 테스트를 쉽게 하기위해 위 내용을 작성한다.
```
output "bastion_host_public_ip" {

 value = aws_instance.bastion_host.public_ip

}

output "lb_dns_name" {

 value = aws_alb.wp-alb.dns_name

}
```

output 
<img style="border-radius: 7px;-moz-border-radius: 7px;-khtml-border-radius: 7px;-webkit-border-radius: 7px;" src="https://github.com/RungLyeok/pj3/blob/main/output.png?raw=true" />

<br>
<br>

## 2-7. AWS_AutoScaling 구성
---

### 2-7-1. AMI 생성
#### `autoscailing.tf`

>리소스 : aws_ami_from_instance

오토스케일링에 이용할 AMI를 앞에서 생성한 wordpress_host를 이용하여 생성한다. 
인스턴스가 생성후 AMI를 생성할수 있게 `depends_on` 를 설정한다.

```
resource "aws_ami_from_instance" "wordpress_ami" {

 name = "wordpress_ami"
 source_instance_id = aws_instance.instance_for_ami.id

 depends_on = [

 aws_instance.instance_for_ami

 ]
}
```

AMI 이미지 생성
<img style="border-radius: 7px;-moz-border-radius: 7px;-khtml-border-radius: 7px;-webkit-border-radius: 7px;" src="https://github.com/RungLyeok/pj3/blob/main/AMI.png?raw=true" />

<br>

### 2-7-2. 시작템플릿 생성

>리소스 : aws_launch_template

생성한 ami를 이용하여 시작템플릿을 생성한다.
인스턴스가 생성후 AMI를 생성할수 있게 `depends_on` 를 설정한다.

```
resource "aws_launch_template" "wordpress_template" {

 depends_on = [
 aws_instance.instance_for_ami
 ]

 name = "wordpress_template"
 description = "wordpress template for atsg v1.0"

 image_id = aws_ami_from_instance.wordpress_ami.id
 instance_initiated_shutdown_behavior = "terminate"
 instance_type = "t2.micro"
 key_name = aws_key_pair.wordpress_server_key.key_name
 vpc_security_group_ids = [aws_security_group.wp_security.id, 
                            aws_security_group.allow_http_sg.id]

 monitoring {
 enabled = true
 }

 placement {
 availability_zone = var.aws_region
 } 
}
```

시작템플릿
<img style="border-radius: 7px;-moz-border-radius: 7px;-khtml-border-radius: 7px;-webkit-border-radius: 7px;" src="https://github.com/RungLyeok/pj3/blob/main/%EC%8B%9C%EC%9E%91%ED%85%9C%ED%94%8C%EB%A6%BF.png?raw=true" />

<br>

### 2-7-3. 오토스케일링 그룹 생성

>리소스 : aws_autoscaling_group

2분마다 EC2의 상태를 확인하여 최소 2개, 최대 4개까지 스케일링을 진행한다.

```
#AutoScaling Group

resource "aws_autoscaling_group" "wp_atsg" {

 name = "wordpress-autoscaling"
 health_check_type = "EC2"
 health_check_grace_period = 120
 force_delete = true
 termination_policies = ["OldestInstance"]
 target_group_arns = [aws_alb_target_group.wp-alb-tg.arn]

 vpc_zone_identifier = [
 module.app_vpc.private_subnets[0],
 module.app_vpc.private_subnets[1]

 ]
 
 launch_template {
 
 id = aws_launch_template.wordpress_template.id
 version = aws_launch_template.wordpress_template.latest_version

 }

 desired_capacity = 2
 min_size = 2 #최소용량
 max_size = 4 #최대용량

 lifecycle {

 create_before_destroy = true

 }
}

```


>리소스 : aws_autoscaling_attachment

 스케일링된 EC2 로드밸런서와 자동으로 연결해준다.
 
```
#AutoScaling attachment
resource "aws_autoscaling_attachment" "wp-atsg-attach" {

 autoscaling_group_name = aws_autoscaling_group.wp_atsg.name
 alb_target_group_arn = aws_alb_target_group.wp-alb-tg.arn

}
```

오토스케일링
<img style="border-radius: 7px;-moz-border-radius: 7px;-khtml-border-radius: 7px;-webkit-border-radius: 7px;" src="https://github.com/RungLyeok/pj3/blob/main/%EC%98%A4%ED%86%A0%EC%8A%A4%EC%BC%80%EC%9D%BC%EB%A7%81.png?raw=true" />

<br>
<br>

---
## 3. 결과

### 3-1. wordpress 설치 페이지

>로드밸런서 DNS_name/wordpress


<img style="border-radius: 7px;-moz-border-radius: 7px;-khtml-border-radius: 7px;-webkit-border-radius: 7px;" src="https://github.com/RungLyeok/pj3/blob/main/%EC%9B%8C%EB%93%9C%ED%94%84%EB%A0%88%EC%8A%A4%20%EA%B2%B0%EA%B3%BC.png?raw=true" />

<br>

### 3-2 . AS-IS-TO-BE
#### AS-IS

- AWS Cloud 활용 가능 (포털 사용 및 리소스 코드화)
- Bastion Host 접속을 통한 Web Server 접속을 구현하여 보안 강화
- Ansible Playbook을 이용하여 Web Server 구성 관리 자동화
- Load Balancer를 이용하여 Web 부하 분산
- Auto Scaling을 이용하여 클라우드의 유연성을 강화
- Terraform을 이용하여 Wordpress 배포 자동화

  
#### TO-BE

- Bastion Host Server의 AutoScaling 구현으로 단일 장애점 해결
- Ansible Playbook 변수 파일 Vault 암호화를 통한 보안 강화

