# [Terraform] 사용자 데이터(Userdata)와 보안그룹(Security Group)

<br>

### 📌INDEX

- [사용자-데이터(Userdata)](#사용자-데이터userdata)
-  [security_group](#securitygroup)

<br>

<br>

# 사용자 데이터(Userdata)

AWS EC2 인스턴스 생성시 작성하는 userdata와 동일

<br>

예시

- 인스턴스 resource 내에 작성하기

```
user_data = <<-EOF
    #!/bin/sh
    yum -y install httpd
    systemctl enable --now httpd
    echo "hello world" > /var/www/html/index.html
  EOF
```

📝 main.tf

```
resource "aws_instance" "app_server" { #ec2 instance
  ami               = var.aws_amazon_linux_ami[var.aws_region]
  instance_type     = "t2.micro"
  availability_zone = var.aws_availability_zone[var.aws_region]

  user_data = <<-EOF  #userdata
    #!/bin/sh
    yum -y install httpd
    systemctl enable --now httpd
    echo "hello world" > /var/www/html/index.html
  EOF
  
  tags = local.common_tags
}

resource "aws_eip" "app_server_eip" {
  vpc      = true
  instance = aws_instance.app_server.id
  tags     = local.common_tags
}
```

참고) apply된 상태에서, userdata를 작성하고 다시 apply하면 삭제되고 replaced됨 

참고) enable --now : now 옵션 쓰면 start까지 같이 이루어짐

참고) EOF : 멀티라인 사용할 때 많이 작업

```
[vagrant@controller 01]$ cat <<EOF > a.txt
> a
> b
> d
> c
> EOF
```

꼭 EOF일 필요는 X

```
[vagrant@controller 01]$ cat <<ABC > b.txt
> a
> b
> c
> ABC
```

참고) output으로 확인되는 elastic_ip와 ec2 public ip는 왜 다를까?

```
Outputs:

app_server_elastic_ip = "3.35.59.108"
app_server_public_ip = "3.38.93.53"
```

출력된 ec2 public ip는 인스턴스가 생성될 때의 ip이고, 탄력적 ip를 할당받으면서 기존의 퍼블릭ip를 잃어버리기 때문

다시 apply하게되면 같아짐

<br>

- [`file`](https://www.terraform.io/language/functions/file) function 사용하여 .sh 파일 참조하기

file function은 주어진 경로에서 **파일의 내용을 읽고 문자열로 반환**

📝 userdata.sh

```shell
#!/bin/sh
yum -y install httpd
systemctl enable --now httpd
echo "hello world" > /var/www/html/index.html
```

📝 main.tf

```
resource "aws_instance" "app_server" {
  ami                    = var.aws_amazon_linux_ami[var.aws_region]
  instance_type          = "t2.micro"
  availability_zone      = var.aws_availability_zone[var.aws_region]
  vpc_security_group_ids = [aws_security_group.app_server_sg.id]

  user_data = file("userdata.sh") #userdata.sh 내용 읽고 문자열로 반환

  tags = local.common_tags
}
```

<br>

<br>

## security_group

[security_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group)

앞서 생성한 userdata 확인 접속을 위한 보안그룹을 설정해보자

📝 security_group.tf

```
resource "aws_security_group" "app_server_sg" {
  name = "Allow SSH & HTTP"  #보안그룹 이름

  ingress {                  #인바운드 규칙
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {                   #아웃바운드 규칙
    from_port   = 0
    to_port     = 0
    protocol    = "-1"       #모두 허용한다는 의미
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

📝 main.tf

보안그룹 id는 리스트로 작성해야함

[`security_groups`](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance#security_groups) - (Optional, EC2-Classic and default VPC only) **A list** of security group names to associate with.

```
resource "aws_instance" "app_server" {
  ami                    = var.aws_amazon_linux_ami[var.aws_region]
  instance_type          = "t2.micro"
  availability_zone      = var.aws_availability_zone[var.aws_region]
  vpc_security_group_ids = [aws_security_group.app_server_sg.id]          #리스트로 작성

  user_data = <<-EOF
    #!/bin/sh
    yum -y install httpd
    systemctl enable --now httpd
    echo "hello world" > /var/www/html/index.html
  EOF

  tags = local.common_tags
}
```

접속 확인

```
$ curl http://3.35.59.108
hello world
```

<br>

<br>

