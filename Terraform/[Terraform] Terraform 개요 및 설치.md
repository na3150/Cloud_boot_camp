# [Terraform] Terraform 개요 및 설치

<br>

### 📌INDEX

- [Terraform이란?](#terraform이란)
- [Terraform 설치](#terraform-설치)
-  [Terraform 구성 파일](#terraform-구성-파일)
-  [Terraform 실행 순서](#terraform-실행-순서)
-  [Terraform 입력 변수](#terraform-입력-변수)
-  [실습해보기](#실습해보기)

<br>

<br>

## Terraform이란?

- [hashicorp/terraform: Terraform 깃허브 저장소](https://github.com/hashicorp/terraform)
- [What is Terraform?](https://www.terraform.io/intro)
- terraform은 **배포를 위한 것** => 새로운 것을 만들어내는 것 , **라이프사이클(변경, 삭제, 생성 등) 담당**
  - ansible은 새로운 것을 만들어내는 것이 아닌 주로 구성을 관리하기 위한 것
- terraform은 **IaC(Infrastructure as  Code) 도구**
- [provider](https://registry.terraform.io/browse/providers)를 통해 액세스 가능한 API를 통해 거의 모든 플랫폼 또는 서비스와 함께 작동할 수 있음

- HCL(Hashicorp Configuration Language) 사용 <--- DSL(Domain Specific Language)

**❕ Workflow**

- **코드 작성(Write)** : HCL 사용
- **계획(Plan)** : ansible의 `--check`옵션과 유사(시뮬레이션)
- **적용(Apply)** : provider에게 provisioning

<br>

<br>

## Terraform 설치

[Terraform Downloads](https://www.terraform.io/downloads)

```shell
$ sudo yum install -y yum-utils
$ sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/RHEL/hashicorp.repo
$ sudo yum -y install terraform
$ terraform --version
```

[AWS-CLI Downloads](https://docs.aws.amazon.com/ko_kr/cli/latest/userguide/getting-started-install.html)

- 참고) AWS CLI 없이 환경 변수로도 설정 가능 : [Setting AWS_ACCESS_KEY_ID](https://learn.hashicorp.com/tutorials/terraform/aws-build?in=terraform/aws-get-started#prerequisites)
- AWS IAM 사용자 생성 과정
  - administratoraccess 권한이 있는 그룹 생성
  - 사용자 생성(프로그래밍 방식)
  - 앞서 생성한 administratoraccess 권한이 있는 그룹에 사용자 추가
  - 키파일.csv 다운로드 :  `'aws configure'` 명령 시 액세스 키(access key) 사용

```shell
$ cd ~
$ curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" 
$ sudo yum install -y unzip
$ unzip awscliv2.zip 
$ sudo ./aws/install
$ aws --version
$ aws configure
$ aws sts get-caller-identity
```

선택사항: ntp 시간 설정

```shell
$ sudo vi /etc/chrony.conf
$ sudo systemctl restart chronyd
$ timedatectl set-ntp true
$ sudo timedatectl set-timezone Asia/Seoul
$ chronyc sources -v
```

<br>

<br>

## Terraform 구성 파일

Terraform Configure File

- `.tf`
- `.tf.json`

인코딩 : Unicode

현재 작업 디렉토리 위치에 따라 **해당 디렉토리의 `.tf`, `.tf.json` 모두 읽어서 실행** => 어떤 디렉토리에서 진행하는지가 중요

참고) 버전 0.11,0.12는 0.13,0.14.1.xx 과 호환 안됨, 0.13,0.14,1.xx는 서로 호환됨

<br>

#### Block

Terraform 파일은 Block으로 구성

항상 중괄호로 시작해서 중괄호로 끝남 { }

```
<BLOCK TYPE> <BLOCK LABEL> ... {
	ARGUMENT
	KEY = VALUE
}
```

- BLOCK LABEL은 여러개 올 수 있음

<br>

#### Terraform Block

- 공급자를 지정
- 버전에 관련된 지정이 필요없다면 작성이 필수는 아님

```
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"                   #aws provider버전이 3.27보다 커야함,별도로 지정하지 않으면 최신버전 설치
    }
  }

  required_version = ">= 0.14.9"            #terraform 최소 필요 버전
}
```

- aws: 프로바이더의 이름
- source: 프로바이더의 종류
- version: 프로바이더의 버전
  - 4.10 : 특정 버전
  - ~> 3.12 : 특정 버전 이상
  -  -> 3.12 : 최소 버전

<br>

#### Provider Block

- **필수**로 작성해야함

```shell
provider "aws" {
  profile = "default"
  region  = "us-west-2"
}
```

- provider "aws" : terraform block의 provider 이름과 매칭이 되어야함

- profile: aws 자격증명 파일의 프로필

  - `~/.aws/config`의 section, `~/.aws/credentials`의 section 

  ```shell
  [vagrant@controller .aws]$ cat config
  [default] #default section
  region = ap-northeast-2
  ```

  - 사용자가 바꿔서 지정해도됨

- region

<br>

#### Resource Block

```
resource "RESOURCE_TYPE" "NAME" {
  ARGUMENT = VALUE
}
```

- RESOURCE_TYPE: 리소스 종류
- NAME: 리소스 이름(terraform에서 구분 하기 위한 이름)
- ARGUMENT: 인자/속성
- 참고)
  테라폼 리소스 = 앤서블 모듈
  테라폼 모듈 = 앤서블 역할

- 참고) [AWS PROVIDER DATA RESOURCES](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/instance)

<br>

예시

```
resource "aws_instance" "app_server" {
  ami           = "ami-830c94e3"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}
```

- 참고) AMI는 같은 이미지더라도 리전이 다르면 아이디가 다름
- 참고)  tag는 AWS를 사용하면 공통속성

<br>

#### 리소스 생성 순서⭐

- 의존 관계가 없는 리소스는 병렬로 실행
- 의존 관계가 있는 경우 의존 관계에 따라서 순서가 정해지게 됨
- 지울 때(destory)는 역순

#### 명시적 의존성

- [Meta-Arguments](https://www.terraform.io/language/meta-arguments/depends_on)
- **암시적 의존성** : attribute reference를 할당함으로써 암시적 의존성을 가지게 됨
- `depends_on` : 의존성을 직접 지정

```
resource "aws_instance" "app_server" {

  depends_on = [
    aws_s3_bucket.app_bucket
  ]
}
```

**Argument Reference**

- 리소스 블럭의 파라미터

**Attribute Reference**

- 속성
- 암시적 의존성

<br>

<br>

## Terraform 실행 순서

**초기화**

디렉토리 위치 확인하기

`provider plugin`을 다운로드 받을 수 있도록 최초로 1번을 해줘야함 

```shell
$ terraform init
```

참고) `.terraform`은 절대 직접 수정하면 안됨 + 공유하면 안됨 + git에도 올리면 안됨

- 프로바이더가 tf 코드를 받아서 api로 바꿔서 실행해줌 => 프로바이더는 반드시 있어야함

- 초기화 작업이 필요한 경우
  - 최초로 프로바이더 설치
  - 프로바이더 버전 업데이트

<br>

**포맷팅**

포맷을 일률적으로 맞춰줌

```shell
$ terraform fmt
```

- 포맷팅이 필요한 경우
  - 새로운 파일 작성
  - 기존 파일 변경

<br>

**유효성 검증**

문법상으로 이상이 없는지 검사

```shell
$ terraform validate
Success! The configuration is valid.
```

- ansible '`--systanx-check`'와 동일하다고 보면됨

<br>

**계획**

실제 aws 서비스 상태와 작성한 프로그램의 상태를 비교해줌

- 꼭 해야되는 것은 아니나, 하는 것이 좋음

```shell
$ terraform plan
```

<br>

**적용**

명령후 yes하면 만들어짐

```shell
$ terraform apply
```

- `--auto-approve` 옵션 : 자동 승인, yes 입력안해도됨

```
$ terraform apply --auto-approve
```

- 이미 apply 된 상태에서 이미지를 변경하고 apply 한다면??

  - destroy and then create replacement : 기존의 것 제거하고 교체 => 이미지만 교체하는 것은 불가능
- 태그만 변경하는 경우에는 삭제되지 않고, 단순히 update

<br>

**제거**

yes하면 제거됨

```shell
$ terraform destroy
```

<br>

**상태 확인**

terraform.tfstate를 보는 명령 == 상태를 보는 명령어

```
terraform show
```

- [type].[이름]

```shell
$ terraform state list
aws_instance.app_server
```

- 리소스 상세 정보 확인
  - 리소스가 많을 때는 지정해서 확인 가능

```shell
[vagrant@controller 01]$ terraform state show aws_instance.app_server
```

<br>

**상태 재 동기화**

수동으로 수정(ex: AWS Console)을 했다면 해당 명령어를 통해 동기화할 수 있음

```
terraform refresh
```

<br>

**tfstate 파일**

- `terraform.tfstate`: 현재상태 
- `terraform.tfstate.backup`: 직전 상태

```
[vagrant@controller 01]$ ls
main.tf  terraform.tfstate  terraform.tfstate.backup
```

- `terraform.tfstate`, `terraform.tfstate.backup` 
  - 절대 공유하면 안되고, 직접 수정하면 안되는 파일

<br>

❕ 만약 terraform.tfstate가 없어진다면?(삭제된다면?)

- 테라폼은 상태(state)가 없어진 것이기 때문에 아무것도 없다고 가정하고, apply 시 새로 생성됨

-  기존의 인스턴스는 테라폼에서 더 이상 관리가 안됨 => 수동으로 관리해야함

- 만약 백업(terraform.tfstate.backup)에 이전상태가 있다면 복구할 수 있음

<br>

<br>

## Terraform 입력 변수

- [Input Variabe](https://www.terraform.io/language/values/variables)
- 변수 사용할 때는 따옴표 X
- number : 숫자는 따옴표 붙이면 안됨

```
variable "instance_name" {
  type        = string
  description = "Instance Name"
  default     = "App Instance"
}
```

일반적으로 type, default, description 3가지 정의

- type

| 일반타입 | string     | "app_server"   |
| -------- | ---------- | -------------- |
|          | number     | 1, 1.0         |
|          | bool       | true, false    |
| 복합타입 | list/tuple | [a,b,c]        |
|          | map/object | {a=abc, b=xyz} |

- default: 기본 값 -> default는 정의하지 않아도 크게 상관없음 : 우선순위 매우 낮음

- description: 설명

<br>

예시

list(값의 타입) : 타입 안넣어주면 디폴트는 string

```
variable "abc" {
  type = list(string)
  # ["a", "b"]
  type = list(number)
  # [1, 2]
}
```

변수만 정의하는 별도의 파일

```
variable "instance_name" {
  type        = string
  description = "Instance Name"
  default     = "App Instance" 
}
```

<br>

#### 변수 할당 방법

- **`-var`옵션**

임시로 할당

우선순위가 가장 높음

```shell
$ terraform plan -var "instance_name=xyz"
```

- **terraform.tfvars** 파일에 변수 설정

가장 많이 사용하는 방식임

default값이 없어도 해당 값이 할당됨

단, variable.tf에 정의되어있어야함

```shell
$ instance_name = "xyz"
```

- **환경 변수 설정**

잘 안씀

<br>

<br>

## 실습해보기



💻 **탄력적 IP가 할당된 EC2 인스턴스 생성하기**

📝main.tf

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
  region  = "ap-northeast-2"
}

resource "aws_instance" "app_server" {     #EC2 인스턴스
  ami           = "ami-02de72c5dc79358c9"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

resource "aws_eip" "app_server_eip" {      #EIP 할당
  vpc      = true
  instance = aws_instance.app_server.id    #암시적 종속성
}
```

- eip는 인스턴스가 생성된 후 생성됨
  - 암시적인 종족성을 가지기 때문 : ec2-instance의 attribute reference을 할당함으로써

- 지울 때(destory)는 역순

<br>

```shell
$ terraform fmt
$ terraform validate
$ terraform plan
$ terraform apply
```

인스턴스가 생성되고, 탄력적 IP가 할당된 것을 확인할 수 있음

![image-20220421184355128](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220421184355128.png)

<br>

<br>

💻 **생성된 EC2 인스턴스에 태그 추가하기**

📝main.tf : tags 수정

```
 tags = {
    Name        = "ExampleAppServerInstance"
    Environment = "Terraform"                  #태그 추가
  }
```

```shell
$ terraform fmt
$ terraform validate
$ terraform plan
$ terraform apply
```

태그만 변경하는 경우에는 삭제된 뒤 다시 생성되지 않고, 단순히 update됨

태그 추가 확인

![image-20220421184840024](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220421184840024.png)

<br>

<br>

💻 **S3 bucket 생성하기**

📝main.tf

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
  region  = "ap-northeast-2"
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "encore-20220421"
}
```

```shell
$ terraform fmt
$ terraform validate
$ terraform plan
$ terraform apply
```

생성 확인

![image-20220421185251620](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220421185251620.png)

<br>

<br>

💻 **하나의 main.tf 파일을 provider.tf로 분류하기**

📝main.tf

```
resource "aws_instance" "app_server" {     #EC2 인스턴스
  ami           = "ami-02de72c5dc79358c9"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}

resource "aws_eip" "app_server_eip" { #eip
  vpc      = true
  instance = aws_instance.app_server.id
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "encore-20220421"
}
```

📝provider.tf : 이 파일은 수정할 일이 거의 없음

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
  region  = "ap-northeast-2"
}
```

<br>

<br>

💻 **EC2 인스턴스의 이름, AMI이미지, 리전, 가용영역 변수처리하기**

📝main.tf

```
resource "aws_instance" "app_server" {      
  ami               = var.image_id          #AMI 변수처리
  instance_type     = "t2.micro"
  availability_zone = var.instance_az       #az 변수처리

  tags = {
    Name        = var.instance_name         #인스턴스 이름 변수처리
    Environment = "Terraform"
  }
}

resource "aws_eip" "app_server_eip" {
  vpc      = true
  instance = aws_instance.app_server.id  
}

resource "aws_s3_bucket" "app_bucket" {
  bucket = "encore-20220421"
}
```

📝provider.tf

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
  region  = var.instance_region            #region 변수 처리
}
```

📝variable.tf

```
variable "instance_name" {

}

variable "image_id" {

}

variable "instance_region"{

}

variable "instance_az" {
  
}
```

📝terraform.tfvars

```
instance_name   = "xyz"
image_id        = "ami-0454bb2fefc7de534"
instance_region = "ap-northeast-2"
instance_az     = "ap-northeast-2a"
```



생성확인

- 인스턴스 이름과 리전 확인

![image-20220421202656022](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220421202656022.png)

- AMI 확인

![image-20220421202729479](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220421202729479.png)

- 가용영역 확인

![image-20220421202455260](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220421202455260.png)
