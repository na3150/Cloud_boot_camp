# [Terraform] 모듈(Module)

<br>

<br>
<br>

# 모듈(Module)이란?

[Module](https://registry.terraform.io/browse/modules)

[Terraform AWS Module Github 저장소](https://github.com/terraform-aws-modules)

ansible에서의 역할(role)과 비슷하며, **자주 사용하는 리소스들을 모아둔 컨테이너**

<br>

**모듈의 종류**

- root 모듈 : 기본 작업 디렉토리 의 파일에 정의된 리소스
- child 모듈 : 모듈에 의해 호출된 모듈

<br>

**모듈 초기화**

초기화해야 모듈이 다운로드 된다.

```
terraform init
```

예시

```
module "myvpc" {
	source = 

	...입력 변수...
}
```

```
resource "aws_instance" "web" {

  subnet_id = module.myvpc.<출력값>
}
```



#### 💻 VPC 모듈 사용해보기

[여기](https://nayoungs.tistory.com/139#c13)에 이어서 작성한 것

**모듈을 사용할 때는 output 변수 이름 잘 확인해야함❕** :  [aws vpc module outputs]([terraform-aws-modules/vpc/aws | Terraform Registry](https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/latest?tab=outputs))

<br>

📝main.tf

```
module "app_vpc" {    #vpc 모듈
  source = "terraform-aws-modules/vpc/aws"

  name = "app_vpc"
  cidr = "10.0.0.0/16"

  azs = [
    "ap-northeast-2a",
    "ap-northeast-2b",
    "ap-northeast-2c",
    "ap-northeast-2d"
  ]
  public_subnets = [  #list로 작성해야함
    "10.0.0.0/24",
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"
  ]
  private_subnets = [  #list로 작성해야함
    "10.0.10.0/24",
    "10.0.11.0/24",
    "10.0.12.0/24",
    "10.0.13.0/24"
  ]
}

resource "aws_key_pair" "app_server_key" {    #보안 그룹
  key_name   = "app_server-key"
  public_key = file("/home/vagrant/.ssh/id_rsa.pub")
}

resource "aws_instance" "app_server" {     #EC2 인스턴스
  ami           = var.aws_amazon_linux_ami[var.aws_region]
  instance_type = "t3.small"
  vpc_security_group_ids = [aws_security_group.app_server_sg.id]
  key_name               = aws_key_pair.app_server_key.key_name
  subnet_id              = module.app_vpc.public_subnets[0]   #서브넷

  tags = local.common_tags
}

resource "aws_instance" "app_server2" {
  ami           = var.aws_amazon_linux_ami[var.aws_region]
  instance_type = "t3.small"
  vpc_security_group_ids = [aws_security_group.app_server_sg.id]
  key_name               = aws_key_pair.app_server_key.key_name
  subnet_id              = module.app_vpc.public_subnets[1] #output value를 참조한것

  tags = local.common_tags
}

resource "aws_eip" "app_server_eip" {
  vpc      = true
  instance = aws_instance.app_server.id
  tags     = local.common_tags
}
```

<br>

📝security_group.tf

보안 그룹은 vpc에 속하는 것이므로, 보안그룹의 vpc를 수정해야함

```
resource "aws_security_group" "app_server_sg" {
  name = "Allow SSH & HTTP"
  vpc_id = module.app_vpc.vpc_id #output value 참조

  ingress { #인바운드 규칙
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { #인바운드 규칙
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["내 IP/32"]
  }

  egress { #아웃바운드 규칙
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

**vpc 생성 확인**

![image-20220422210940331](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220422210940331.png)

**서브넷 생성 확인**

![image-20220422211044119](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220422211044119.png)

**인스턴스 생성 확인**

![image-20220422211150412](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220422211150412.png)
