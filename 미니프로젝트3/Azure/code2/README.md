### 💻 Terraform과 Ansible을 활용한 Azure Cloud로의 Wordpress 배포

<br>

✔️ **Outputs**

- 보고서
- [발표 ppt](https://github.com/na3150/Cloud_boot_camp/blob/main/%EB%AF%B8%EB%8B%88%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B83/%EB%AF%B8%EB%8B%88%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B83%20%EB%B0%9C%ED%91%9C%20ppt%20%EC%B5%9C%EC%A2%85%EB%B3%B8.pdf)
<br>


✔️ **아키텍처(Architecture)**

<img src="https://user-images.githubusercontent.com/64996121/167747992-ef93f1cb-01dc-430f-9912-7f6519ba177f.png" width =800/>





 ✔️ **Packer File**
 
`packer`

<br>

 ✔️ **Ansible File**
 
`wp`

<br>

✔️ **tree 구조**

```shell
.
├── data.tf
├── db-mysql.tf
├── lb.tf
├── main.tf
├── output.tf
├── packer
│   └── centos.pkr.hcl
├── provider.tf
├── pub.tf
├── security_group.tf
├── variable.tf
├── vmss.tf
└── wp
    ├── roles
    │   ├── apache
    │   │   ├── tasks
    │   │   │   └── main.yaml
    │   │   └── vars
    │   │       └── main.yaml
    │   └── wordpress
    │       ├── tasks
    │       │   └── main.yaml
    │       ├── templates
    │       │   └── wp-config.php.j2
    │       └── vars
    │           └── main.yaml
    └── wordpress.yaml
```
