### 💻 Terraform과 Ansible을 활용한 Wordpress 배포

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

**아키텍처(Architecture)**
<br>
<br>

<img src="https://user-images.githubusercontent.com/64996121/165767459-caa6f80b-7a87-40fd-9601-c48729a60326.png" width = 600/>

