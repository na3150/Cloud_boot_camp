# [Terraform] Provisioners (feat.Taint)

<br>

### ๐INDEX

- [Provisioners](#provisioners)
- [Provisioner ์ฐ๊ฒฐ](#provisioner-์ฐ๊ฒฐ)
  - [์ค์ตํด๋ณด๊ธฐ](#์ค์ตํด๋ณด๊ธฐ)
-  [Taint๋?](#taint๋)
-  [Ansible ์คํ ๋ฐฉ๋ฒ](#ansible-์คํ-๋ฐฉ๋ฒ)

<br>

<br>

# Provisioners

[Provisioners](https://www.terraform.io/language/resources/provisioners/syntax) : terraform์์ ์ ๊ณตํ๋ ๊ณตํต **argument**

"Provisioners are a Last Resort " :  ์ตํ์ ์๋จ์ด๋ผ๋ ๋ป์ผ๋ก, ๋๋๋ก `user-data`๋ฅผ ์ฌ์ฉํ๋ ๊ฒ์ ๊ถ์ฅํจ

์ฐธ๊ณ ) user_data๋ฅผ ๋จผ์  ์คํํ  ์ง provisioner๋ฅผ ๋จผ์  ์คํํ  ์ง ๊ฒฐ์ ํ  ์ ์๋ ๋ฐฉ๋ฒ์ด ์์

=> provisioner๋ ์์๋๋ก ์คํ๋จ

<br>

#### Provisioner ์ข๋ฅ

- [**file**](https://www.terraform.io/language/resources/provisioners/file): ํ์ผ ๋ณต์ฌ

์๋ก ์์ฑ๋ ๋ฆฌ์์ค๋ก ํ์ผ ๋๋ ๋๋ ํ ๋ฆฌ๋ฅผ ๋ณต์ฌํ๋ ๋ฐ ์ฌ์ฉ

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

- **[local_exec](https://www.terraform.io/language/resources/provisioners/local-exec)**: ๋ก์ปฌ ๋จธ์ ์์ ๋ช๋ น ์คํ

์ฐธ๊ณ ) self ๋ ์๊ธฐ ์์ ์ ๋ฆฌ์์ค์ ๋์ผ

์ฐธ๊ณ ) ์๋ฐ์ดํ ์์์ ๋ณ์ ์ฐธ์กฐํ  ๋ : "${๋ณ์๋ช}"

```
resource "aws_instance" "web" {
  # ...

  provisioner "local-exec" {
    command = "echo ${self.private_ip} >> private_ips.txt"
  }
}
```

- [**remote_exec**](https://www.terraform.io/language/resources/provisioners/remote-exec): ์๊ฒฉ ๋จธ์ ์์ ๋ช๋ น ์คํ

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

## Provisioner ์ฐ๊ฒฐ

[Provisioner Connection Setting](https://www.terraform.io/language/resources/provisioners/connection)

`file`๊ณผ `remote_exec`๋ ssh ์ฐ๊ฒฐ์ด ํ์ํจ => **connection block์ผ๋ก ์ ์**

<br>

#### connection ๋ฐฉ๋ฒ 2๊ฐ์ง

**1. ํ๋ก๋น์ ๋ ๋ด๋ถ์ ์ ์** 

- ํด๋น ํ๋ก๋น์ ๋์๋ง ์ ์ฉ 

```
  provisioner "file" {        #ํ๋ก๋น์ ๋
	  connection {            #์ปค๋ฅ์ ๋ธ๋ก
	    type     = "ssh"
	    user     = "root"
	    password = "${var.root_password}"
	    host     = "${var.host}"
	  }
  }
```

**2. ํ๋ก๋น์ ๋์ connection ๋ธ๋ก ๋ถ๋ฆฌ**

- ๋ชจ๋  ํ๋ก๋น์ ๋์ ์ ์ฉ
- ์ผ๋ฐ์ ์ธ ๋ฐฉ๋ฒ(๋ ๋ง์ด ์ฌ์ฉ)

```
  provisioner "file" {       #ํ๋ก๋น์ ๋
  }

  provisioner "file" {
  }

  connection {               #์ปค๋ฅ์ ๋ธ๋ก
  }
```

<br>

#### ์ค์ตํด๋ณด๊ธฐ

[์ฌ๊ธฐ](https://nayoungs.tistory.com/138#%E-%-C%--%EF%B-%-F%--%EC%--%AC%EC%-A%A-%EC%-E%--%--%EB%-D%B-%EC%-D%B-%ED%--%B--Userdata-)์์ ์์ฑํ๋ user_data๋ฅผ provisioner๋ก ์์ฑํด๋ณด์

<br>

**index.html ํ์ผ ์์ฑํ๊ธฐ**

๐  index.html

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

**connection block ์์ฑํ๊ธฐ**

- host : self๋ก ์์ ์ ๋ฆฌ์์ค ์ฐธ์กฐ
- file function์ผ๋ก private key ๊ฐ์ ธ์ค๊ธฐ

```
 connection {
    user        = "ec2-user"
    host        = self.public_ip
    private_key = file("/home/vagrant/.ssh/id_rsa")
    timeout     = "1m"
  }
```

<br>

**ํค ํ์ด ์์ฑํ๊ธฐ** : [Key Pair](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair)

- file function์ผ๋ก public ํค ๊ฐ์ ธ์ค๊ธฐ

```
resource "aws_key_pair" "app_server_key" {
  key_name   = "app_server-key"
  public_key = file("/home/vagrant/.ssh/id_rsa.pub")
}
```

<br>

**instance argument๋ก `key_name`์ถ๊ฐ**

```
 key_name               = aws_key_pair.app_server_key.key_name
```

<br>

**ssh 22๋ฒ ํฌํธ ์ด์ด์ฃผ๊ธฐ**

๐ security_group.tf

```
resource "aws_security_group" "app_server_sg" {
  name = "Allow SSH & HTTP"
  vpc_id = module.app_vpc.vpc_id #output ์ฐธ์กฐ

  ingress { #์ธ๋ฐ์ด๋ ๊ท์น
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress { #์ธ๋ฐ์ด๋ ๊ท์น
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["๋ด IP/32"]
  }

  egress { #์์๋ฐ์ด๋ ๊ท์น
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

<br>

**`index.html` ํ์ผ์ ๋ณต์ฌํ๊ธฐ ์ํ `file` privisioner ์์ฑ**

`ec2-user`๋ก ์งํํ๊ธฐ ๋๋ฌธ์ ๊ถํ์์ ๋ฌธ์ ๋ก /tmp/index.html๋ก ๋ณต์ฌ ํ, ์๋์์ /var/www/html/index.html๋ก ๋ณต์ฌ

```
provisioner "file" {
  source      = "index.html"
  destination = "/tmp/index.html"
}
```

<br>

**resource๋ด์ ํจํค์ง ์ค์น๋ฅผ ์ํ `romote_exec` provisioner ์์ฑ**

- `ec2-user`๋ก ์ ์๋๊ธฐ ๋๋ฌธ์ ๊ด๋ฆฌ์ ๊ถํ ํ์ : `sudo`

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

**๐  main.tf ์ต์ข๋ณธ**

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

**์ ์ ํ์ธ**

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

## Taint๋?
์ค์ผ๋๋ค, ๋ฌธ์ ์๋ค, ์ค๋ฅ๊ฐ ์๋ค๋ ์๋ฏธ

๋ฆฌ์์ค๋ฅผ ์์ฑ/๋ณ๊ฒฝ ํ๋ค๊ฐ ์ค๋ฅ๊ฐ ์๊ธฐ๋ฉด, ํด๋น ๋ฆฌ์์ค๋ Taint ์ฒ๋ฆฌ๋จ

**Taint ์ฒ๋ฆฌ๋ ๋ฆฌ์์ค๋ ๋ค์ ์์์ ๋ฌด์กฐ๊ฑด ์ฌ์์ฑ**

- untaint ์ค์ ํ๊ธฐ

```shell
$ terraform taint <RESOURCE>
```

- taint ์ค์ ํ๊ธฐ 
  - ์ฌ์์ฑ ์ํค๊ธฐ ์ํด ์๋์ ์ผ๋ก taint์ํค๋ ๊ฒฝ์ฐ๋ ์์

```shell
$ terraform untaint <RESOURCE>
```

- tainted ์ํฉ ์์

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

## Ansible ์คํ ๋ฐฉ๋ฒ

Terraform์ [puppit](https://www.terraform.io/language/resources/provisioners/puppet), [salt-masterless](https://www.terraform.io/language/resources/provisioners/salt-masterless) ๋ฑ ๋ค์ํ IaC ๋๊ตฌ๋ค์ provisioner๋ฅผ ์ ๊ณตํ์ง๋ง, ansible์ ์ ๊ณตํ์ง ์๋๋ค.

Terraform์์ Ansible์ ์ด๋ป๊ฒ ์คํํ ๊น??

<br>

**1. AMI ์ด๋ฏธ์ง ๋ด์ ansible์ ๋ฏธ๋ฆฌ ์ค์น**

- file๋ก ํ๋ ์ด๋ถ ๋ฐ ํ์ผ ๋ณต์ฌ
- remote-exec๋ก ์คํ
- ansible-playbook a.yaml -c local
  - ์ฐธ๊ณ ) local ์ ์๋ฐฉ์: ์๊ธฐ ์์  ํํ ์ ์ํ๋ ๊ฒ => key ํ์์์

<br>

**2. ๋ก์ปฌ์์ ์คํ**

- ๋ก์ปฌ์ ansible์ด ์ค์น๋์ด ์์ด์ผ ํจ
- local-exec๋ก ์ธ๋ฒคํ ๋ฆฌ ์์ฑ
	- self.public_ip
- local-exec๋ก ansible-playbook ์คํ

<br>

์์

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