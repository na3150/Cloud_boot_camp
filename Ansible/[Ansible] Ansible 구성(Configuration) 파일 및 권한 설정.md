## [Ansible] Ansible 구성(Configuration) 파일 및 권한 설정



### 📌INDEX

- [구성 파일](#구성-파일)

- [권한 상승(Privilege Escalation)](#권한-상승privilege-escalation)

<br>

<br>

## 구성 파일

- [Ansible Configuration settings](https://docs.ansible.com/ansible/latest/reference_appendices/config.html)

- 설정 파일 위치
  - 설정파일에는 우선 순위가 있음
  - 같은 설정에 대해서 어디가 우선 순위가 높은지

1.   `ANSIBLE_CONFIG` (environment variable if set)
     - 환경변수 설정
     - 우선 순위가 가장 높기 때문에 어떤 디렉토리에 있든지 적용됨
     - 일반적으로 사용 잘 안됨
2.  `ansible.cfg` : 현재 작업 디렉토리
    - 자주 사용되는 설정 파일
    - **현재 디렉토리에 있을 때만 적용됨**
3.  `~/.ansible.cfg` : 홈 디렉토리
    - 현재 작업 디렉토리인 **`ansible.cfg`와 구분**하기 : ansible 앞에 '`.`' 있음
4.  `/etc/ansible/ansible.cfg` : 기본 설정 파일
    - ini 형식 : Section이 있음



- 현재 적용되는 설정 파일 확인

```shell
[vagrant@controller ~]$ ansible --version
ansible 2.9.27
  config file = /home/vagrant/.ansible.cfg  #현재 설정파일
  configured module search path = [u'/home/vagrant/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/site-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.5 (default, Apr  2 2020, 13:16:51) [GCC 4.8.5 20150623 (Red Hat 4.8.5-39)]
```

- 환경변수로 설정 파일 변경해보기

```shell
[vagrant@controller ~]$ touch /tmp/a.cfg
[vagrant@controller ~]$ export ANSIBLE_CONFIG=/tmp/a.cfg
[vagrant@controller ~]$ ansible --version
ansible 2.9.27
  config file = /tmp/a.cfg
  configured module search path = [u'/home/vagrant/.ansible/plugins/modules', u'/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python2.7/site-packages/ansible
  executable location = /usr/bin/ansible
  python version = 2.7.5 (default, Apr  2 2020, 13:16:51) [GCC 4.8.5 20150623 (Red Hat 4.8.5-39)]
```

- 환경변수 설정 해제

```shell
[vagrant@controller ~]$ unset ANSIBLE_CONFIG
```

- 설정 파일 수정을 통해 -i 옵션으로 **inventory를 지정할 필요 없게 하기**
  - ansible 명령어는 설정 파일을 확인함
  - 홈 디렉토리의 설정 파일의 인벤토리 위치가 inventory.ini 를 가리키게 됨

```shell
[vagrant@controller ~]$ vi .ansible.cfg
```

```shell
[defaults]
inventory=./inventory.ini
```

```shell
[vagrant@controller ~]$ ansible all --list-hosts
  hosts (2):
    192.168.100.11
    192.168.100.12
```



예시



```
[defaults]
remote_user=<SSH_USER>
ask_pass=<True|False>
host_key_checking=<True|False>

[privilege_escalation]
become=<True|False>
become_ask_pass=<True|False>
become_method=<sudo|su>
become_user=<SUDO_USER>
```

- ask_pass 기본값: false
- host_key_checking 기본값: true
- become 기본값: false
- become_ask_pass 기본값: false
- become_method 기본값: sudo

<br>

<br>

## 권한 상승(Privilege Escalation)

- su
  - root의 패스워드를 물어봄
  - root를 여러명이 공유하게 되는 것
  - 가능하면 절대 사용하지 말 것
- **sudo**
  - root에 접근할 때 각자의 패스워드를 입력
  - sudo를 사용할 수 있는 사용자를 지정할 수 있음
    - `/etc/sudoers`



**`sshd_config`**

- PermintRootLogin : default no
- 루트로 바로 접속하는 것은 위험하기 때문



**`/etc/sudoers`**

- `sudo`를 사용할 수 있는 사용자 제어
- 핵심 부분

```
%wheel  ALL=(ALL)       ALL
```

- %wheel: wheel 그룹 
- ALL : 모든 시스템에서
- (ALL) : 모든 사용자로
- ALL : 모든 명령어



예시

- `vagrant` 사용자만 `192.168.56.100`에서 접속했을 때, `root`로만 전환할 수 있고, `ls`명령어만 sudo로 사용 가능

```
vagrant 192.168.56.100=(root) /usr/bin/ls
```



**`/etc/sudoers.d/[파일]`**

- sudeors 설정 파일 디렉토리
- `sudo` 명령은 해당 디렉토리 아래의 모든 파일들을 적용(읽음)
  - 파일명은 상관 X
- `/etc/sudoers.d/vagrant`

```
%vagrant ALL=(ALL) NOPASSWD: ALL
```

- NOPASSWD: 패스워드 묻지 않음(passwordless sudo)

<br>

<br>

