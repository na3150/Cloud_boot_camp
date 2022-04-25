# [Terraform] Terraform Cloud

<br>

### 📌INDEX

- [백엔드(Backend)](#백엔드backend)
- [Terraform Cloud](#terraform-cloud)

<br>

# 백엔드(Backend)

현재 사용하고 있는 백엔드: Local Backend

s3에 상태를 저장하고 공유 : [s3, dynamo DB 를 이용한 원격 백엔드](https://www.terraform.io/language/settings/backends/s3)

<br>

예시

```
terraform {
  backend "s3" {
    bucket = "mybucket"
    key    = "path/to/my/key"
    region = "us-east-1"
  }
}
```

<br>

동시에 접근하는 것을 방지하기 위해 `locking` 사용

s3는 잠금 기능이 없어서 dynamodb를 사용하여 locking

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "dynamodb:GetItem",
        "dynamodb:PutItem",
        "dynamodb:DeleteItem"
      ],
      "Resource": "arn:aws:dynamodb:*:*:table/mytable"
    }
  ]
}
```

but, terraform cloud가 나오면서 잘 사용하지 않는 방법이 됨

<br>

<br>

## Terraform Cloud

[Backends Configuaraion](https://www.terraform.io/language/settings/backends/configuration)

organization name은 전세계에서 유일해야함

<br>

wordspace 생성 : CLI 선택 후 Name 입력 - [Creatae Workspace]



![image-20220426022904747](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220426022904747.png)



<br>

**local에서 terraform 연결**

```shell
$ terraform login
```

- https://app.terraform.io/app/settings/tokens?source=terraform-login 에서 토큰 생성 후 복사

![image-20220426023417296](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220426023417296.png)

<br>

Backend 설정은 **terraform block 내에 backend 서브 블록**을 이용해 설정 : workspace생성 후 overview에서 확인할 수 있음

📝`provider.tf`

```
terraform {
  backend "remote" {
    organization = "example_corp"

    workspaces {
      name = "my-app-prod"
    }
  }
}
```

<br>
Settings > Execution Mode

`Remote` 는 Git이 연결되어있어야하고, **CLI Type은 `local`**이 되어야함

 현재는 Git 연동이 안되어있으므로, local로 수정



![image-20220426022624170](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220426022624170.png)



설정완료 후 `terraform init` 

로컬의 상태를 terraform cloud로 옮겨가는 것(migrate)

```shell
$ terraform init
```

apply 하기

```shell
$ terraform apply
```

- workspace에 상태가 저장되어있음을 확인할 수 있음
- terraform.tfstate 파일이 없어도 terraform 상태를 확인할 수 있음 : terraform cloud에 저장되어있기 때문

```shell
$ terraform destroy
```

destory 중 workspace state에서 locking 되어있음을 확인할 수 있음

![image-20220426023543880](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220426023543880.png)

