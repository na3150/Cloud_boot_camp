# [Terraform] 데이터 소스(Data Source)

[Data Source: aws_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami)

- **프로바이더에서 정보를 가져오는 것**을 모두 데이터 소스라고 함
- **data 블록**에 작성
- 리소스와 정의하는 방법은 동일함
- ` owner` 필수(required)
- 필터(filter)를 걸어서 검색

<br>

다음과 같이 Data Sources 존재

![image-20220426020025106](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220426020025106.png)

참고) [ubuntu image 검색 사이트](https://cloud-images.ubuntu.com/locator/)

<br>

💻 예시: aws_ami data source로 ami 생성

📝 `data_source.tf`

```
data "aws_ami" "ubuntu_image" {
  owners      = ["099720109477"]
  most_recent = true #가장 최신 버전을 사용할 것인가

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-*-amd64-server-*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
```

📝 `main.tf`

```shell
resource "aws_instance" "app_server" {
  count = var.instance_count
  #aws_instance.app_server[0]
  #aws_instance.app_server[1]

 ami           = data.aws_ami.ubuntu_image.id #이미지
  instance_type = "t3.small"
 
  vpc_security_group_ids = [aws_security_group.app_server_sg.id]
  key_name               = aws_key_pair.app_server_key.key_name
  subnet_id              = module.app_vpc.public_subnets[count.index % length(module.app_vpc.public_subnets)]


  tags = local.common_tags
}
```



AMI 생성확인

![image-20220426015617154](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220426015617154.png)
