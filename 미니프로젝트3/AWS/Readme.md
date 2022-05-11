### 💻 Terraform과 Ansible을 활용한 AWS Cloud로의 Wordpress 배포
<br>

**✔️ Outputs**
- 보고서
- [발표 ppt](https://github.com/na3150/Cloud_boot_camp/blob/main/%EB%AF%B8%EB%8B%88%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B83/%EB%AF%B8%EB%8B%88%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B83%20%EB%B0%9C%ED%91%9C%20ppt%20%EC%B5%9C%EC%A2%85%EB%B3%B8.pdf)

<br>

**✔️ 아키텍처(Architecture)**
<br>
<br>

<img src="https://user-images.githubusercontent.com/64996121/165767459-caa6f80b-7a87-40fd-9601-c48729a60326.png" width = 600/>
<br>


**✔️ tree 구조**

```
.
├── alb.tf
├── db.tf
├── main.tf
├── output.tf
├── provider.tf
├── security_group.tf
├── variable.tf
├── vpc.tf
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
<br>
<br>


