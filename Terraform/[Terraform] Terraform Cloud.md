# [Terraform] Terraform Cloud

<br>

### ๐INDEX

- [๋ฐฑ์๋(Backend)](#๋ฐฑ์๋backend)
- [Terraform Cloud](#terraform-cloud)

<br>

# ๋ฐฑ์๋(Backend)

ํ์ฌ ์ฌ์ฉํ๊ณ  ์๋ ๋ฐฑ์๋: Local Backend

s3์ ์ํ๋ฅผ ์ ์ฅํ๊ณ  ๊ณต์  : [s3, dynamo DB ๋ฅผ ์ด์ฉํ ์๊ฒฉ ๋ฐฑ์๋](https://www.terraform.io/language/settings/backends/s3)

<br>

์์

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

๋์์ ์ ๊ทผํ๋ ๊ฒ์ ๋ฐฉ์งํ๊ธฐ ์ํด `locking` ์ฌ์ฉ

s3๋ ์ ๊ธ ๊ธฐ๋ฅ์ด ์์ด์ dynamodb๋ฅผ ์ฌ์ฉํ์ฌ locking

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

but, terraform cloud๊ฐ ๋์ค๋ฉด์ ์ ์ฌ์ฉํ์ง ์๋ ๋ฐฉ๋ฒ์ด ๋จ

<br>

<br>

## Terraform Cloud

[Backends Configuaraion](https://www.terraform.io/language/settings/backends/configuration)

organization name์ ์ ์ธ๊ณ์์ ์ ์ผํด์ผํจ

<br>

wordspace ์์ฑ : CLI ์ ํ ํ Name ์๋ ฅ - [Creatae Workspace]



![image-20220426022904747](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220426022904747.png)



<br>

**local์์ terraform ์ฐ๊ฒฐ**

```shell
$ terraform login
```

- https://app.terraform.io/app/settings/tokens?source=terraform-login ์์ ํ ํฐ ์์ฑ ํ ๋ณต์ฌ

![image-20220426023417296](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220426023417296.png)

<br>

Backend ์ค์ ์ **terraform block ๋ด์ backend ์๋ธ ๋ธ๋ก**์ ์ด์ฉํด ์ค์  : workspace์์ฑ ํ overview์์ ํ์ธํ  ์ ์์

๐`provider.tf`

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

`Remote` ๋ Git์ด ์ฐ๊ฒฐ๋์ด์์ด์ผํ๊ณ , **CLI Type์ `local`**์ด ๋์ด์ผํจ

 ํ์ฌ๋ Git ์ฐ๋์ด ์๋์ด์์ผ๋ฏ๋ก, local๋ก ์์ 



![image-20220426022624170](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220426022624170.png)



์ค์ ์๋ฃ ํ `terraform init` 

๋ก์ปฌ์ ์ํ๋ฅผ terraform cloud๋ก ์ฎ๊ฒจ๊ฐ๋ ๊ฒ(migrate)

```shell
$ terraform init
```

apply ํ๊ธฐ

```shell
$ terraform apply
```

- workspace์ ์ํ๊ฐ ์ ์ฅ๋์ด์์์ ํ์ธํ  ์ ์์
- terraform.tfstate ํ์ผ์ด ์์ด๋ terraform ์ํ๋ฅผ ํ์ธํ  ์ ์์ : terraform cloud์ ์ ์ฅ๋์ด์๊ธฐ ๋๋ฌธ

```shell
$ terraform destroy
```

destory ์ค workspace state์์ locking ๋์ด์์์ ํ์ธํ  ์ ์์

![image-20220426023543880](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220426023543880.png)

