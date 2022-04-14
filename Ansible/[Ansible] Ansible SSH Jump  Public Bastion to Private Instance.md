## [Ansible] Ansible SSH Jump : Public Bastion to Private Instance



### 📌INDEX

- [인스턴스 구성하기](#인스턴스-구성하기)
- [첫번째 방법(ProxyJump)](#첫번째-방법proxyjump)
- [두번째 방법(Inventory 파일)](#두번째-방법inventory-파일)





## 인스턴스 구성하기

본 실습의 아키텍처(Architecture)는 다음과 같다.

Ansible -> Bastion 으로 SSH 접속할 때와, Bastion -> Private Instance로 접속할 때 **다른 키 페어**를 사용할 예정이다.





![ansible ssh jump architechture drawio](https://user-images.githubusercontent.com/64996121/163371397-a1bdec5c-163b-478f-83a8-786dcafd618c.png)





##### 1. Ansible Controller에서 공개키 복사

- 편의를 위해 controller에 생성되어있는 공개키 `~/.ssh/id_rsa.pub`를 사용

```shell
[vagrant@controller ~]$ cat .ssh/id_rsa.pub
[키 내용]
```



##### 2. AWS에서 [작업] - [키 페어 가져오기]

- 복사한 키를 붙여넣기

![Inked키 내용_LI](https://user-images.githubusercontent.com/64996121/163371591-6848d09c-d140-4c92-9a5e-6c250c58624c.jpg)


##### 3. Private Subnet 생성

- default vpc 에서 생성


![private서브넷 생성](https://user-images.githubusercontent.com/64996121/163371873-d9180224-b715-43ec-b8f9-60df7415ff79.png)



##### 4. Bastion Host로 사용할 AWS EC2 인스턴스 생성하기

- 좀 전에 생성한 `mycontroller` key 사용
- default vpc public subnet에 생성
- 보안을 위해 내IP에서의 SSH 트래픽만 허용

![Inkedbastion 생성_LI](https://user-images.githubusercontent.com/64996121/163371706-8d974f17-89e0-4a85-870a-8528cf3e48c2.jpg)



##### 5. ~/.ssh/config 파일 작성

```shell
[vagrant@controller ~]$ cat ~/.ssh/config
Host bastion
        Hostname 52.79.235.84
        User ec2-user
        Port 22
        IdentityFile ~/.ssh/id_rsa
```

- 권한 변경

```shell
[vagrant@controller ~]$ sudo chmod 600 .ssh/config
```





##### 6. Bastion Host에서 키 생성하기

- Bastion Host -> Private Subnet EC2 접속할 때 사용할 키 페어

```shell
[ec2-user@ip-172-31-41-176 ~]$ ssh-keygen
```

- 공개키 내용 복사 

```
[ec2-user@ip-172-31-41-176 ~]$ cat ~/.ssh/id_rsa.pub
[키 내용]
```



##### 7. AWS에서 [작업] - [키 페어 가져오기]

- 2번 작업과 같이 붙여 넣기 후 키페어 생성



##### 8. Private Subnet EC2 인스턴스 생성하기

- 이전에 생성한 private subnet `myprivatesubnet` 선택
- 7번에서 생성한 키 페어 선택

<br>

<br>

## 첫번째 방법(ProxyJump)

첫번째 방법은 **~/.ssh/config 파일에 ProxyJump**를 정의하는 방법이다.



##### 1) Bastion Host에서 키 파일 복사

```shell
[ec2-user@ip-172-31-41-176 ~]$ cat ~/.ssh/id_rsa
```



##### 2) Controller에 키 붙여넣기

```shell
[vagrant@controller ~]$ vim ~/.ssh/test_rsa
```



##### 3) 키 파일 `test_rsa` 권한 변경

```shell
[vagrant@controller ~]$ chmod 600 ~/.ssh/test_rsa
```



##### 4) Controller의 `~/.ssh/config` 파일 수정

```shell
Killed by signal 1.
[vagrant@controller ~]$ cat ~/.ssh/config
Host bastion
        Hostname 52.79.235.84
        User ec2-user
        Port 22
        IdentityFile ~/.ssh/id_rsa

Host node
        Hostname 172.31.65.195
        User ec2-user
        Port 22
        Identityfile ~/.ssh/test_rsa
        ProxyJump bastion  #Bastion Host를 점프해서 들어가게됨
```



##### 5) SSH 점프 접속 테스트

- 정상적으로 접속되는 것을 확인할 수 있음

```shell
[vagrant@controller ~]$ ssh node
Last login: Thu Apr 14 09:58:25 2022 from ip-172-31-41-176.ap-northeast-2.compute.internal

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
[ec2-user@ip-172-31-65-195 ~]$
```



##### 6) ansible 명령 사용해보기

- inventory파일에 node(private ec2) 추가

```shell
[vagrant@controller ~]$ cat inventory.ini

[ec2]
node
```

- ansible 명령어로 private subnet의 ec2 인스턴스 id 확인해보기
  - 정상적으로 작동하는 것을 확인할 수 있음
  - `-i` 옵션으로 inventory 파일을 지정해주지 않는 것은 ansible 설정 파일 `/home/vagrant/.ansible.cfg` 에 inventory를 지정해뒀기 때문

```shell
[vagrant@controller ~]$ ansible ec2 -m command -a id
[WARNING]: Platform linux on host node is using the discovered Python
interpreter at /usr/bin/python, but future installation of another Python
interpreter could change this. See https://docs.ansible.com/ansible/2.9/referen
ce_appendices/interpreter_discovery.html for more information.
node | CHANGED | rc=0 >>
uid=1000(ec2-user) gid=1000(ec2-user) groups=1000(ec2-user),4(adm),10(wheel),190(systemd-journal)
```



💧 ProxyJump는 설정이 편하나 되는 경우도 있고, 안되는 경우도 있어서(ansible client 설정이 잘 안되는 겨우가 있음) 일반적으로는 아래의 두번째 방법을 더 많이 사용함

<br>

<br>

## 두번째 방법(Inventory 파일)

두번째 방법은 Inventory 파일에 `ansible_ssh_common_args` 변수를 정의하여 jump하는 방법이다.

- [Sample](https://www.jeffgeerling.com/blog/2022/using-ansible-playbook-ssh-bastion-jump-host)
  - `ansible_ssh_common_args` 변수를 정의하면 ssh 접속을 할 때마다 변수의 값(설정)이 적용됨(옵션이 붙게됨)
  - `-p` : Port
  - `-w` : stdin과 sdout을 해당되는 호스트(%h)와 포트(%p)로 넘겨줌
    - 실질적으로 접속할 Target(여기서는 private instance)의 호스트와 포트 정보 

```shell
[proxy]
bastion.example.com

[nodes]
private-server-1.example.com
private-server-2.example.com
private-server-3.example.com

[nodes:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -p 2222 -W %h:%p -q username@bastion.example.com"
```



##### 1) `~/.ssh/config` 파일 수정

- 1번째 방법을 시도했다면, `~/.ssh/config` 파일의 `ProxyJump`로 인해 Jump가 되는것이 아님을 증명하기 위해 ProxyJump 정의를 삭제

```
[vagrant@controller ~]$ vim ~/.ssh/config
```

```shell
[vagrant@controller ~]$ cat ~/.ssh/config
Host bastion
        Hostname 52.79.235.84
        User ec2-user
        Port 22
        IdentityFile ~/.ssh/id_rsa

Host node
        Hostname 172.31.65.195
        User ec2-user
        Port 22
        Identityfile ~/.ssh/test_rsa
```





##### 2) inventory 파일 수정하기

- `-q` 옵션 뒤에는 Bastion Host의 IP

```shell
[vagrant@controller ~]$ cat inventory.ini
192.168.100.11
192.168.100.12

[wp]
192.168.100.11

[ec2]
node

[ec2:vars]
ansible_ssh_common_args='-o ProxyCommand="ssh -p 22 -W %h:%p -q ec2-user@52.79.235.84"'
```



##### 3) ansible 명령해보기

- 정상적으로 jump되어 작동되는 것을 확인할 수 있음

```shell
[vagrant@controller ~]$ ansible ec2 -m command -a id
[WARNING]: Platform linux on host node is using the discovered Python
interpreter at /usr/bin/python, but future installation of another Python
interpreter could change this. See https://docs.ansible.com/ansible/2.9/referen
ce_appendices/interpreter_discovery.html for more information.
node | CHANGED | rc=0 >>
uid=1000(ec2-user) gid=1000(ec2-user) groups=1000(ec2-user),4(adm),10(wheel),190(systemd-journal)
```

