<br>

### ๐INDEX

- [AWX๋?](#awx๋)
- [AWX์ค์น](#awx-์ค์น)
- [AWX ๋ฆฌ์์ค ์์ฑ](#awx-๋ฆฌ์์ค-์์ฑ)

<br>

<br>

## AWX๋?

- AWX ๋ Ansible ํ๋ก์ ํธ ๊ด๋ฆฌ๋ฅผ ์ํ ์น ๊ธฐ๋ฐ ์ฌ์ฉ์ ์ธํฐํ์ด์ค, REST API ๋ฐ Task ์์ง ์ ๊ณตํ๋ ํด 

- ๋ชฉ์ : ์คํ / ๋ชจ๋ํฐ๋ง

- Red Hat Ansible Automation Platform ํ๋ก์ ํธ ์ค์ ํ๋ ์ด๋ฉฐ, ์คํ์์ค๋ก ์ ๊ณต : [ansible/awx](https://github.com/ansible/awx)

- AWX: RedHat [Ansible Tower](https://docs.ansible.com/ansible/2.5/reference_appendices/tower.html) ์ ํ์ Upstream

  - upstream์ด๋? ๊ฐ๋จํ๊ฒ ๋งํด ๋ฌด์์ผ๋ก ๋ง๋ค์ด์ง ๊ฒ์ธ์ง

- 18๋ฒ์  ๋ถํฐ๋ ์ฟ ๋ฒ๋คํฐ์ค๋ก๋ง ์ค์น๊ฐ๋ฅ

  ๋ฐ๋ผ์ ๋์ปค๋ก ์ค์น๊ฐ ๊ฐ๋ฅํ [17๋ฒ์ ](https://github.com/ansible/awx/tree/17.1.0)์ผ๋ก ์งํ

- ์ฐธ๊ณ 

> CentOS --up--> RHEL --up--> Fedora
> RHEL --> CentOS Stream --> Fedora
> Ansible Tower --> AWX
> Ubuntu --> Debian

AnsibleWorks -> AWX

[์ฐธ๊ณ ํ๊ธฐ ์ข์ ๋ธ๋ก๊ทธ](https://medium.com/@dudwls96/ansible-awx-open-source-%EB%9E%80-f1eabe0d1949)

<br>

<br>

## AWX ์ค์น

#### Docker ์ค์น

> https://docs.docker.com/engine/install/centos/

```
sudo yum install -y yum-utils
```

```
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
```

```
sudo yum install -y docker-ce docker-ce-cli containerd.io
```

```
sudo systemctl enable --now docker
```

```
docker --version
```

<br>

#### Docker-Compose ์ค์น

```
sudo yum install -y python3 python3-pip
```

```
sudo pip3 install -U -I pip wheel setuptools
sudo pip3 install docker-compose
```

```
docker-compose --version
```

<br>

#### AWX ์ค์น

```
sudo yum -y install git
```

```
cd ~
git clone --branch 17.1.0 --single-branch https://github.com/ansible/awx.git
```

```
cd ~/awx/installer
```

`~/awx/installer/inventory` : ํด๋น ๋ผ์ธ ์์ 

```ini
108 admin_password=password
141 project_data_dir=/var/lib/awx/projects
```

```
sudo yum -y install libselinux-python3
```

```
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```

```
ansible-playbook -i inventory install.yml -b
```

```
sudo docker ps
```

```
CONTAINER ID   IMAGE                COMMAND                  CREATED          STATUS          PORTS                                   NAMES
1ea4d852e694   ansible/awx:17.1.0   "/usr/bin/tini -- /uโฆ"   11 minutes ago   Up 11 minutes   8052/tcp                                awx_task
9c527c75a323   ansible/awx:17.1.0   "/usr/bin/tini -- /bโฆ"   20 minutes ago   Up 11 minutes   0.0.0.0:80->8052/tcp, :::80->8052/tcp   awx_web
f6775cad37ab   redis                "docker-entrypoint.sโฆ"   20 minutes ago   Up 11 minutes   6379/tcp                                awx_redis
16d33e864106   postgres:12          "docker-entrypoint.sโฆ"   20 minutes ago   Up 11 minutes   5432/tcp                                awx_postgres
```

<br>

`Create Preload data` ์์์์ ์ค๋ฅ ๋ฐ์์ ํ์ธ

```
sudo docker exec awx_task bash -c "/usr/bin/awx-manage create_preload_data"
```

```
An organization is already in the system, exiting.
(changed: False)
```

<br>

์น๋ธ๋ผ์ฐ์  ์ ์

```
http://192.168.100.10
```

![AWX ์ ์ํ์ผ](https://raw.githubusercontent.com/na3150/typora-img/main/img/AWX%20%EC%A0%91%EC%86%8D%ED%8C%8C%EC%9D%BC.PNG)

![AWX ๋ก๊ทธ์ธ ์๋ฃ](https://raw.githubusercontent.com/na3150/typora-img/main/img/AWX%20%EB%A1%9C%EA%B7%B8%EC%9D%B8%20%EC%99%84%EB%A3%8C.PNG)

<br>

<br>

## AWX ๋ฆฌ์์ค ์์ฑ

- Projects: ํ๋ ์ด๋ถ์ ๊ฐ์ง๋ ๋ฆฌ์์ค
	- /var/lib/awx/projects
- Inventories: ๊ด๋ฆฌ ๋ธ๋/์ธ๋ฒคํ ๋ฆฌ ๊ทธ๋ฃน์ ๊ฐ์ง๋ ๋ฆฌ์์ค
- Credentials: SSH, Sudo, Vault ๋ฑ ์๊ฒฉ์ฆ๋ช ์ ๋ณด๋ฅผ ๊ฐ์ง๋ ๋ฆฌ์์ค
- Templates: ํ๋ก์ ํธ, ์ธ๋ฒคํ ๋ฆฌ, ์๊ฒฉ์ฆ๋ช์ ๊ฐ์ง๋ ๋ฆฌ์์ค

<br>

<img src="https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220420193217475.png" alt="image-20220420193217475" style="zoom:80%;" />

<br>

#### ํ๋ ์ด๋ถ ์ค๋น

```
sudo mkdir /var/lib/awx/projects/test-awx
sudo vi /var/lib/awx/projects/test-awx/debug.yaml
```
- ์ ์ฉํ  ๋์์ inventory์์ ์ ์ํ  ๊ฒ์ด๊ธฐ ๋๋ฌธ์ yaml ํ์ผ์ hosts๋ฅผ all๋ก ํจ

```yaml
- hosts: all
  tasks:
    - debug:
        msg: Hello AWX World
```

```
[test-awx-group]
192.168.100.11
```

<br>

#### ํ๋ก์ ํธ ์์ฑ

Resouces -> Projects -> Add
- Name: test-awx-project
- Source Control Credentials Type: manual
- Playbook Directory: test-awx
- `Save`

<br>

#### ์ธ๋ฒคํ ๋ฆฌ ์์ฑ

Resources -> Inventories -> Add -> Add Inventory

- Create new inventory
	- Name: test-awx-inventory
	- `Save`

- Details -> Groups ํญ -> Add
	- Name: test-awx-group
	- 'Save'

- Group details -> Hosts ํญ -> Add -> Add new host
	- Name: 192.168.100.11
	- `Save`

<br>

#### ์๊ฒฉ์ฆ๋ช ์์ฑ

Resources -> Credentials -> Add
- Name: test-awx-credentials
- Credential Type: Machine
- Username: vagrant
- SSH Private Key
	- controller ์์คํ์ vagrant ์ฌ์ฉ์์ ํ๋๋ ํ ๋ฆฌ์์ ~/.ssh/id_rsa ํ์ผ ๋ด์ฉ ๋ณต์ฌ
- Privilege Escalation Method: sudo
- Privilege Escalation Username: root
- `Save`

![image-20220420194939915](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220420194939915.png)

<br>

#### ํํ๋ฆฟ ์์ฑ

Resources -> Templates -> Add -> Add job template
- Name: test-awx-template
- Inventory: test-awx-inventory
- Project: test-awx-project
- Playbook: debug.yaml
- Credentials: test-awx-credentials
- `Save`

![image-20220420194924560](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220420194924560.png)

<br>

#### ์์ ์คํ

Resources -> Templates -> test-awx-template -> ๋ก์ผ ๋ฒํผ

![image-20220420194905789](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220420194905789.png)
