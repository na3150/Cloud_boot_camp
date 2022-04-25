# [Terraform] Count 반복문

<br>

## Count

[count Meta-Argument](https://www.terraform.io/language/meta-arguments/count)

- count는 resource의 가장 처음에 적는 것이 관습
- count는 resource에서만 사용 가능
- 0부터 시작하는 count.index를 참조하여 사용

<br>

예시 : `count`에 값에 정수인 인수가 포함된 경우 Terraform은 그만큼의 인스턴스를 생성

```
resource "aws_instance" "server" {
  count = 4 # create four similar EC2 instances

  ami           = "ami-a1b2c3d4"
  instance_type = "t2.micro"

  tags = {
    Name = "Server ${count.index}"
  }
}
```

<br>

📝`main.tf` : `eip`에서 instance에 count.index를 통해 참조

```
resource "aws_instance" "app_server" {
  count = 2  #count
  #aws_instance.app_server[0]
  #aws_instance.app_server[1]

  ami           = var.aws_amazon_linux_ami[var.aws_region]
  instance_type = "t3.small"
  #availability_zone      = var.aws_availability_zone[var.aws_region]
  vpc_security_group_ids = [aws_security_group.app_server_sg.id]
  key_name               = aws_key_pair.app_server_key.key_name
  subnet_id              = module.app_vpc.public_subnets[0]

  tags = local.common_tags
}
```

```
resource "aws_eip" "app_server_eip" {
  count = 2  #count 

  vpc      = true
  instance = aws_instance.app_server[count.index].id  #instance 참조
  tags     = local.common_tags
}
```

<br>

**output에서 count 사용 불가능** => '`*`' 를 통해 전체 참조 : 자주 사용되는 방법

```
output "app_server_elastic_ip" {
  value = aws_eip.app_server_eip.*.public_ip
}

output "app_server_public_ip" {
  value = aws_instance.app_server.*.public_ip
}
```

<br>

count를 매번 변경하기는 번거로우므로, **변수 처리**해주는 것이 좋음

📝`variable.tf`

```
variable "instance_count" {
  description = "Instance Count"
  type        = number
  default     = 2
}
```

📝`terraform.tfvars`

```
instance_count = 4
```

📝 `main.tf`

```
resource "aws_eip" "app_server_eip" {
  count = var.instance_count

  vpc      = true
  instance = aws_instance.app_server[count.index].id
  tags     = local.common_tags
}
```

<br>

**모듈러(%) 활용하기**

count가 서브넷의 개수를 넘어서는 것과 같은 경우를 대비하여 **순환을 위해 모듈러 연산자(%)를 활용**

```
resource "aws_instance" "app_server" {
  count = var.instance_count
  #aws_instance.app_server[0]
  #aws_instance.app_server[1]

  ami           = data.aws_ami.ubuntu_image.id
  instance_type = "t3.small"
  vpc_security_group_ids = [aws_security_group.app_server_sg.id]
  key_name               = aws_key_pair.app_server_key.key_name
  subnet_id              = module.app_vpc.public_subnets[count.index % length(module.app_vpc.public_subnets)]  #모듈려 연산자 활용


  tags = local.common_tags
}
```

<br>

**length function**

[length](https://www.terraform.io/language/functions/length) : list, map, string의 length를 반환

서브넷의 개수가 바뀌면 계속 수정해줘야하는 번거로움을 줄이기 위해 length() 함수를 사용할 수 있음

```
subnet_id              = module.app_vpc.public_subnets[count.index%length(module.app_vpc.aws_subnet.public_subnets)]
```
