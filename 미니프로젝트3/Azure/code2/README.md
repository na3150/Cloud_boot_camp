### π» Terraformκ³Ό Ansibleμ νμ©ν Azure Cloudλ‘μ Wordpress λ°°ν¬

<br>

βοΈ **Outputs**

- λ³΄κ³ μ
- [λ°ν ppt](https://github.com/na3150/Cloud_boot_camp/blob/main/%EB%AF%B8%EB%8B%88%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B83/%EB%AF%B8%EB%8B%88%ED%94%84%EB%A1%9C%EC%A0%9D%ED%8A%B83%20%EB%B0%9C%ED%91%9C%20ppt%20%EC%B5%9C%EC%A2%85%EB%B3%B8.pdf)

<br>


βοΈ **μν€νμ²(Architecture)**

<img src="https://user-images.githubusercontent.com/64996121/167747992-ef93f1cb-01dc-430f-9912-7f6519ba177f.png" width =800/>





 βοΈ **Packer File**

`packer`

<br>

 βοΈ **Ansible File**

`wp`

<br>

βοΈ **tree κ΅¬μ‘°**

```shell
.
βββ data.tf
βββ db-mysql.tf
βββ lb.tf
βββ main.tf
βββ output.tf
βββ packer
β   βββ centos.pkr.hcl
βββ provider.tf
βββ pub.tf
βββ security_group.tf
βββ variable.tf
βββ vmss.tf
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
