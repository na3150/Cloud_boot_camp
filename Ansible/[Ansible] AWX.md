<br>

### 📌INDEX

- [AWX란?](#awx란)
- [AWX설치](#awx-설치)
- [AWX 리소스 생성](#awx-리소스-생성)

<br>

<br>

## AWX란?

- AWX 는 Ansible 프로젝트 관리를 위한 웹 기반 사용자 인터페이스, REST API 및 Task 엔진 제공하는 툴 

- 목적: 실행 / 모니터링

- Red Hat Ansible Automation Platform 프로젝트 중에 하나 이며, 오픈소스로 제공 : [ansible/awx](https://github.com/ansible/awx)

- AWX: RedHat [Ansible Tower](https://docs.ansible.com/ansible/2.5/reference_appendices/tower.html) 제품의 Upstream

  - upstream이란? 간단하게 말해 무엇으로 만들어진 것인지

- 18버전 부터는 쿠버네티스로만 설치가능

  따라서 도커로 설치가 가능한 [17버전](https://github.com/ansible/awx/tree/17.1.0)으로 진행

- 참고

> CentOS --up--> RHEL --up--> Fedora
> RHEL --> CentOS Stream --> Fedora
> Ansible Tower --> AWX
> Ubuntu --> Debian

AnsibleWorks -> AWX

[참고하기 좋은 블로그](https://medium.com/@dudwls96/ansible-awx-open-source-%EB%9E%80-f1eabe0d1949)

<br>

<br>

## AWX 설치

#### Docker 설치

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

#### Docker-Compose 설치

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

#### AWX 설치

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

`~/awx/installer/inventory` : 해당 라인 수정

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
1ea4d852e694   ansible/awx:17.1.0   "/usr/bin/tini -- /u…"   11 minutes ago   Up 11 minutes   8052/tcp                                awx_task
9c527c75a323   ansible/awx:17.1.0   "/usr/bin/tini -- /b…"   20 minutes ago   Up 11 minutes   0.0.0.0:80->8052/tcp, :::80->8052/tcp   awx_web
f6775cad37ab   redis                "docker-entrypoint.s…"   20 minutes ago   Up 11 minutes   6379/tcp                                awx_redis
16d33e864106   postgres:12          "docker-entrypoint.s…"   20 minutes ago   Up 11 minutes   5432/tcp                                awx_postgres
```

<br>

`Create Preload data` 작업에서 오류 발생시 확인

```
sudo docker exec awx_task bash -c "/usr/bin/awx-manage create_preload_data"
```

```
An organization is already in the system, exiting.
(changed: False)
```

<br>

웹브라우저 접속

```
http://192.168.100.10
```

![AWX 접속파일](https://raw.githubusercontent.com/na3150/typora-img/main/img/AWX%20%EC%A0%91%EC%86%8D%ED%8C%8C%EC%9D%BC.PNG)

![AWX 로그인 완료](https://raw.githubusercontent.com/na3150/typora-img/main/img/AWX%20%EB%A1%9C%EA%B7%B8%EC%9D%B8%20%EC%99%84%EB%A3%8C.PNG)

<br>

<br>

## AWX 리소스 생성

- Projects: 플레이북을 가지는 리소스
	- /var/lib/awx/projects
- Inventories: 관리 노드/인벤토리 그룹을 가지는 리소스
- Credentials: SSH, Sudo, Vault 등 자격증명 정보를 가지는 리소스
- Templates: 프로젝트, 인벤토리, 자격증명을 가지는 리소스

<br>

<img src="https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220420193217475.png" alt="image-20220420193217475" style="zoom:80%;" />

<br>

#### 플레이북 준비

```
sudo mkdir /var/lib/awx/projects/test-awx
sudo vi /var/lib/awx/projects/test-awx/debug.yaml
```
- 적용할 대상은 inventory에서 정의할 것이기 때문에 yaml 파일의 hosts를 all로 함

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

#### 프로젝트 생성

Resouces -> Projects -> Add
- Name: test-awx-project
- Source Control Credentials Type: manual
- Playbook Directory: test-awx
- `Save`

<br>

#### 인벤토리 생성

Resources -> Inventories -> Add -> Add Inventory

- Create new inventory
	- Name: test-awx-inventory
	- `Save`

- Details -> Groups 탭 -> Add
	- Name: test-awx-group
	- 'Save'

- Group details -> Hosts 탭 -> Add -> Add new host
	- Name: 192.168.100.11
	- `Save`

<br>

#### 자격증명 생성

Resources -> Credentials -> Add
- Name: test-awx-credentials
- Credential Type: Machine
- Username: vagrant
- SSH Private Key
	- controller 시스템의 vagrant 사용자의 홈디렉토리에서 ~/.ssh/id_rsa 파일 내용 복사
- Privilege Escalation Method: sudo
- Privilege Escalation Username: root
- `Save`

![image-20220420194939915](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220420194939915.png)

<br>

#### 템플릿 생성

Resources -> Templates -> Add -> Add job template
- Name: test-awx-template
- Inventory: test-awx-inventory
- Project: test-awx-project
- Playbook: debug.yaml
- Credentials: test-awx-credentials
- `Save`

![image-20220420194924560](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220420194924560.png)

<br>

#### 작업 실행

Resources -> Templates -> test-awx-template -> 로켓 버튼

![image-20220420194905789](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220420194905789.png)
