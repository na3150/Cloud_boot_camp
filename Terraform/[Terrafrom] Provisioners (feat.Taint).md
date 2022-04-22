# [Terraform] Provisioners (feat.Taint)

<br>

### 📌INDEX

- [Provisioners](#provisioners)
- [Provisioner 연결](#provisioner-연결)
  - [실습해보기](#실습해보기)
-  [Taint란?](#taint란)
-  [Ansible 실행 방법](#ansible-실행-방법)

<br>

<br>

# Provisioners

[Provisioners](https://www.terraform.io/language/resources/provisioners/syntax) : terraform에서 제공하는 공통 **argument**

"Provisioners are a Last Resort " :  최후의 수단이라는 뜻으로, 되도록 `user-data`를 사용하는 것을 권장함

참고) user_data를 먼저 실행할 지 provisioner를 먼저 실행할 지 결정할 수 있는 방법이 없음

=> provisioner는 순서대로 실행됨

<br>

#### Provisioner 종류

- [**file**](https://www.terraform.io/language/resources/provisioners/file): 파일 복사

새로 생성된 리소스로 파일 또는 디렉토리를 복사하는 데 사용

```
resource "aws_instance" "web" {
  # ...

  # Copies the myapp.conf file to /etc/myapp.conf
  provisioner "file" {
    source      = "conf/myapp.conf"
    destination = "/etc/myapp.conf"
  }
}
```

- **[local_exec](https://www.terraform.io/language/resources/provisioners/local-exec)**: 로컬 머신에서 명령 실행

참고) self 는 자기 자신의 리소스와 동일

참고) 쌍따옴표 안에서 변수 참조할 때 : "${변수명}"

```
resource "aws_instance" "web" {
  # ...

  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> private_ips.txt"
  }
}
```

- [**remote_exec**](https://www.terraform.io/language/resources/provisioners/remote-exec): 원격 머신에서 명령 실행

```
resource "aws_instance" "web" {
  # ...

  # Establishes connection to be used by all
  # generic remote provisioners (i.e. file/remote-exec)
  connection {
    type     = "ssh"
    user     = "root"
    password = var.root_password
    host     = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "puppet apply",
      "consul join ${aws_instance.web.private_ip}",
    ]
  }
}
```

<br>

<br>

## Provisioner 연결

[Provisioner Connection Setting](https://www.terraform.io/language/resources/provisioners/connection)

`file`과 `remote_exec`는 ssh 연결이 필요함 => **connection block으로 정의**

<br>

#### connection 방법 2가지

**1. 프로비저너 내부에 정의** 

- 해당 프로비저닝에만 적용 

```
  provisioner "file" {        #프로비저너
	  connection {            #커넥션 블록
	    type     = "ssh"
	    user     = "root"
	    password = "${var.root_password}"
	    host     = "${var.host}"
	  }
  }
```

**2. 프로비저너와 connection 블록 분리**

- 모든 프로비저닝에 적용
- 일반적인 방법(더 많이 사용)

```
  provisioner "file" {       #프로비저너
  }

  provisioner "file" {
  }

  connection {               #커넥션 블록
  }
```

<br>

#### 실습해보기

[여기](https://nayoungs.tistory.com/138#%E-%-C%--%EF%B-%-F%--%EC%--%AC%EC%-A%A-%EC%-E%--%--%EB%-D%B-%EC%-D%B-%ED%--%B--Userdata-)에서 작성했던 user_data를 provisioner로 작성해보자

<br>

**index.html 파일 작성하기**

📝  index.html

```
<html>
    <head>
        <title>
            hello Terraform
        </title>
    </head>
    <body>
        <h1> Hello Terraform World</h1>
    </body>
</html>
```

<br>

**connection block 작성하기**

- host : self로 자신의 리소스 참조
- file function으로 private key 가져오기

```
 connection {
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("/home/vagrant/.ssh/id_rsa")
    timeout     = "1m"
  }
```

<br>

**키 페어 생성하기** : [Key Pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair)

- file function으로 public 키 가져오기

```
resource "aws_key_pair" "app_server_key" {
  key_name   = "app_server-key"
  public_key = file("/home/vagrant/.ssh/id_rsa.pub")
}
```

<br>

**instance argument로 `key_name`추가**

```
 key_name               = aws_key_pair.app_server_key.key_name
```

<br>

**ssh 22번 포트 열어주기**

📝 security_group.tf

```
resource "aws_security_group" "app_server_sg" {
  name = "Allow SSH & HTTP"
  vpc_id = module.app_vpc.vpc_id #output 참조

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

<br>

**`index.html` 파일을 복사하기 위한 `file` privisioner 작성**

`ec2-user`로 진행하기 때문에 권한상의 문제로 /tmp/index.html로 복사 후, 아래에서 /var/www/html/index.html로 복사

```
provisioner "file" {
  source      = "index.html"
  destination = "/tmp/index.html"
}
```

<br>

**resource내에 패키지 설치를 위한 `romote_exec` provisioner 작성**

- `ec2-user`로 접속되기 때문에 관리자 권한 필요 : `sudo`

```
provisioner "remote-exec" {
  inline = [
    "sudo yum install -y httpd",
    "sudo systemctl enable --now httpd",
    "sudo cp /tmp/index.html /var/www/html/index.html"
  ]
}
```

<br>

**📝  main.tf 최종본**

```
resource "aws_key_pair" "app_server_key" {
  key_name   = "app_server-key"
  public_key = file("/home/vagrant/.ssh/id_rsa.pub")

}

resource "aws_instance" "app_server" {
  ami                    = var.aws_amazon_linux_ami[var.aws_region]
  instance_type          = "t2.micro"
  availability_zone      = var.aws_availability_zone[var.aws_region]
  vpc_security_group_ids = [aws_security_group.app_server_sg.id]
  key_name               = aws_key_pair.app_server_key.key_name

  connection {
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("/home/vagrant/.ssh/id_rsa")
    timeout     = "1m"
  }

    provisioner "file" {
    source      = "index.html"
    destination = "/tmp/index.html"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install -y httpd",
      "sudo systemctl enable --now httpd",
      "sudo cp /tmp/index.html /var/www/html/index.html"
    ]
  }

  tags = local.common_tags
}

resource "aws_eip" "app_server_eip" {
  vpc      = true
  instance = aws_instance.app_server.id
  tags     = local.common_tags
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "encore-20220421"
  tags   = local.common_tags
}<br>
```

<br>

**접속 확인**

```
[vagrant@controller 01]$ curl http://3.35.59.108
<html>
    <head>
        <title>
            hello Terraform
        </title>
    </head>
    <body>
        <h1> Hello Terraform World</h1>
    </body>
</html>
```

<br>

<br>

## Taint란?
오염되다, 문제있다, 오류가 있다는 의미

리소스를 생성/변경 하다가 오류가 생기면, 해당 리소스는 Taint 처리됨

**Taint 처리된 리소스는 다음 작업시 무조건 재생성**

- untaint 설정하기

```shell
$ terraform taint <RESOURCE>
```

- taint 설정하기 
  - 재생성 시키기 위해 의도적으로 taint시키는 경우도 있음

```shell
$ terraform untaint <RESOURCE>
```

- tainted 상황 예시

```shell
$ terraform show
```

```
# aws_instance.app_server: (tainted) 
resource "aws_instance" "app_server" {
    ami                                  = "ami-02e05347a68e9c76f"
    arn                                  = "arn:aws:ec2:ap-northeast-2:556627152554:instance/i-0dd180dfd111fd24c"
    associate_public_ip_address          = true
    availability_zone                    = "ap-northeast-2a"
    cpu_core_count                       = 1
    cpu_threads_per_core                 = 1
```

<br>

<br>

## Ansible 실행 방법

Terraform은 [puppit](https://www.terraform.io/language/resources/provisioners/puppet), [salt-masterless](https://www.terraform.io/language/resources/provisioners/salt-masterless) 등 다양한 IaC 도구들의 provisioner를 제공하지만, ansible은 제공하지 않는다.

Terraform에서 Ansible을 어떻게 실행할까??

<br>

**1. AMI 이미지 내에 ansible을 미리 설치**

- file로 플레이북 및 파일 복사
- remote-exec로 실행
- ansible-playbook a.yaml -c local
  - 참고) local 접속방식: 자기 자신 한테 접속하는 것 => key 필요없음

<br>

**2. 로컬에서 실행**

- 로컬에 ansible이 설치되어 있어야 함
- local-exec로 인벤토리 생성
	- self.public_ip
- local-exec로 ansible-playbook 실행

<br>

예시

```
  connection {
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("/home/vagrant/.ssh/id_rsa")
    timeout     = "1m"
  }

  provisioner "local-exec" {
    command = "echo ${self.public_ip} ansible_user=ec2-user > inven.ini"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i inven.ini web_install.yaml -b"
  }
```