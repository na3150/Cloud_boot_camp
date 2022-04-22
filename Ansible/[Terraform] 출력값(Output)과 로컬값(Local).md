# [Terraform] 출력값(Output)과 로컬값(Local)

<br>

### 📌INDEX

- [출력 값(Output)](#출력-값output)
-  [로컬 값(Local)](#로컬-값local)

<br>

<br>

# 출력 값(Output)

[Output Values](https://www.terraform.io/language/values/outputs)

원하는 값을 쉽게 얻기 위해 사용하며,  출력 값은 `output` 블록을 사용하여 선언해야 함

`output.tf`

```
output "app_server_elastic_ip" {
  value = aws_eip.app_server_eip.public_ip
}

output "app_server_public_ip" {
  value = aws_instance.app_server.public_ip
}
```

명령어를 통해 output 목록을 확인할 수 있음

```
terraform output
```

apply 후 마지막에 output을 확인할 수 있음

```
Apply complete! Resources: 0 added, 0 changed, 0 destroyed.

Outputs:

app_server_elastic_ip = "3.35.59.108"
app_server_public_ip = "3.35.59.108"
```

<br>

<br>

## 로컬 값(Local)

[Local Values](https://www.terraform.io/language/values/locals)

ansible에서는 없는 개념으로, 함수의 로컬(지역) 변수와 유사한 의미를 가짐 => 즉, Terraform 내부에서만 사용하기 위한 변수

관련된 로컬 값들은 단일 `locals` 블록에서 함께 선언할 수 있음 

<br>

예시: 공통태그를 붙이기

`local.tf`

```
locals {
  common_tags = {
    Name                = "My Terraform"
    project_name        = var.project_name
    project_environment = var.project_environment
  }
}
```

`main.tf`

```
resource "aws_instance" "app_server" {
  ami               = var.aws_amazon_linux_ami[var.aws_region]
  instance_type     = "t2.micro"
  availability_zone = var.aws_availability_zone[var.aws_region]
  tags = local.common_tags  #공통 태그
}

resource "aws_eip" "app_server_eip" {
  vpc      = true
  instance = aws_instance.app_server.id
  tags     = local.common_tags  #공통 태그
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "encore-20220421"
  tags   = local.common_tags  #공통 태그
}
```

<br>

<br>

