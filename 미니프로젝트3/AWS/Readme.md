### π» Terraformκ³Ό Ansibleμ νμ©ν AWS Cloudλ‘μ Wordpress λ°°ν¬
<br>

**βοΈ Outputs**
- λ³΄κ³ μ
- [λ°ν ppt](https://github.com/na3150/Cloud_boot_camp/blob/main/%EB%AF%B8%EB%8B%88%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B83/%EB%AF%B8%EB%8B%88%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B83%20%EB%B0%9C%ED%91%9C%20ppt%20%EC%B5%9C%EC%A2%85%EB%B3%B8.pdf)

<br>

**βοΈ μν€νμ²(Architecture)**
<br>
<br>

<img src="https://user-images.githubusercontent.com/64996121/165767459-caa6f80b-7a87-40fd-9601-c48729a60326.png" width = 600/>
<br>


**βοΈ tree κ΅¬μ‘°**

```
.
βββ alb.tf
βββ db.tf
βββ main.tf
βββ output.tf
βββ provider.tf
βββ security_group.tf
βββ variable.tf
βββ vpc.tf
βββ wp
    βββ roles
    β   βββ apache
    β   β   βββ tasks
    β   β   β   βββ main.yaml
    β   β   βββ vars
    β   β       βββ main.yaml
    β   βββ wordpress
    β       βββ tasks
    β       β   βββ main.yaml
    β       βββ templates
    β       β   βββ wp-config.php.j2
    β       βββ vars
    β           βββ main.yaml
    βββ wordpress.yaml
```
<br>
<br>


