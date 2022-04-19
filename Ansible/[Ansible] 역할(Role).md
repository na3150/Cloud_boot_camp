# [Ansible] 역할(Role)



### 📌INDEX

- [역할(Role)](#역할role)
  - [실습](#실습)
- [ansible-galaxy](#ansible-galaxy)

<br>

<br>

## 역할(Role)

- [Roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html#playbooks-reuse-roles)
- 통합(통일)된 플레이북을 만들기위한 통일화된 구조 : 역할 생성 --> 통합 --> 플레이북
- `roles`디렉토리 사용

```shell
mkdir roles
```

- 구조화된 형식을 자동으로 만들어주는 명령어 : `ansible-galaxy init`
  - 직접 mkdir로 만들어도 상관없으나, 이름은 정해져있음

```shell
ansible-galaxy init [역할이름] --init-path [역할 디렉토리 위치]
```



예시

```shell
ansible-galaxy init common --init-path roles
```

- `tree`명령어로 구조 확인 

```
.
└── roles
    └── common
        ├── defaults
        │   └── main.yml
        ├── files
        ├── handlers
        │   └── main.yml
        ├── meta
        │   └── main.yml
        ├── README.md
        ├── tasks
        │   └── main.yml
        ├── templates
        ├── tests
        │   ├── inventory
        │   └── test.yml
        └── vars
            └── main.yml
```

`roles/common`: 역할의 이름

- roles 내의 디렉토리명이 역할의 이름

`tasks/main.yml`: 작업이 위치

<br>

`handlers/main.yml`: 핸들러 작업이 위치

<br>

`tests/inventory`: 역할을 테스트 하기 위한 인벤토리
`tests/test.yml`: 역할을 테스트 하기 위한 플레이북

- tests : 단위 테스트를 위한 파일들 -> 자주 사용되지는 X

<br>

`defaults/main.yml`: 기본 역할 변수(우선 순위가 매우 낮음)

<br>`vars/main.yml`: 역할 변수(우선 순위가 매우 높음)

<br>

`files`: 파일 관련 모듈의 `src:` 파라미터에서 참조하는 파일의 위치

- 경로를 지정할 필요가 없음(파일 이름만)

`files/a.txt`: 경로 지정할 필요 없음

```
- copy:
	src: a.txt
```
<br>

`templates`: 템플릿 모듈의 `src:` 파라미터에서 참조하는 파일의 위치

- 템플릿 파일의 경로를 지정할 필요가 없음

`templates/a.j2`

```
- templates:
    src: a.j2
```

<br>

`meta/main.yml`: 역할을 설명하고 있는 파일

- 역할 버전
- 역할 이름
- 역할 만든 사람
- 역할 적용되는 플렛폼(리눅스 배포판)
- **역할의 의존성**
  - meta를 사용하는 가장 중요한 이유
  - 다른 역할에 대한 의존성을 정의해놓으면, 해당되는 역할도 함께 실행됨 

<br>

#### 플레이에서 작업 실행 순서

- 주의: 각 작업(pre_tasks, roles, tasks .. )이 끝날 때마다 핸들러가 실행됨
- 어떤 역할을 수행하기 전 혹은 수행한 후  간단한 작업을 해야할 때 `pre_tasks`, `post_tasks`를 사용할 수 있음

```yaml
# Play
- hosts:
  
  pre_tasks:
  
  roles:
  
  tasks:
  
  post_tasks:

  handlers:
```

1. pre_tasks
2. pre_tasks의 handlers
3. roles
4. roles의 handlers
5. tasks
6. tasks의 handlers
7. post_tasks
8. post_tasks의 handlers

<br>

- role을 활용한 main playbook 파일 예시 : [출처](https://github.com/ansible/ansible-examples/blob/master/lamp_simple/site.yml)

```yaml
---
# This playbook deploys the whole application stack in this site.

- name: apply common configuration to all nodes
  hosts: all
  remote_user: root

  roles:
    - common

- name: configure and deploy the webservers and application code
  hosts: webservers
  remote_user: root

  roles:
    - web

- name: deploy MySQL and configure the databases
  hosts: dbservers
  remote_user: root

  roles:
    - db
```

<br>

<br>

#### **실습**

- `ansible-galaxy init`명령을 통해 자동으로 구조 생성
  - 주의: 해당 명령으로 구조 자동화하면 '`yaml`' 아닌 '`yml`'로 생성됨 => 글쓴이는 뒤늦게 깨닫고 기존 yml 파일 삭제함

```shell
[vagrant@controller sample]$ ansible-galaxy init web --init-path roles
- Role web was created successfully
```

- **yaml 파일 작성 시 '`tasks: `', '`handlers:`','`vars:` 등 별도로 선언하지 않아도 됨**: 구조가 정해져있는 것

```shell
[vagrant@controller sample]$ code roles/web/tasks/main.yaml
```

```yaml
- yum:
    name: httpd
    state: installed
- replace:
    path: /etc/httpd/conf/httpd.conf
    regexp: '^Listen'
    replace: '#Listen'
- template:
    src: ports.conf.j2
    dest: /etc/httpd/conf.d/ports.conf
  notify:
    - Restart Web Service
- copy:
    src: index.html
    dest: /var/www/html/
- service:
    name: httpd
    state: started
    enabled: yes
```

```shell
[vagrant@controller sample]$ code roles/web/handlers/main.yaml
```

```yaml
- name: Restart Web Service
  service:
      name: httpd
      state: restarted
```

```shell
[vagrant@controller sample]$ code roles/web/vars/main.yaml
```

```yaml
---
web_port: 81
```

```shell
[vagrant@controller sample]$ cp web_config/ports.conf.j2 roles/web/templates/
[vagrant@controller sample]$ cp web_contents/index.html roles/web/files/
```

- main playbook 만들기

```shell
[vagrant@controller sample]$ code site.yaml
```

```shell
- hosts: 192.168.100.12
  become: yes

  roles:
    - web 
```

- 기존 것(필요없는 것) 삭제

```
[vagrant@controller sample]$ ls
roles  sample.yaml  site.yaml  web_config  web_contents
[vagrant@controller sample]$ rm -rf sample.yaml web_config/ web_contents/
```

- 결과 확인

```shell
[vagrant@controller sample]$ tree
.
├── roles
│   └── web
│       ├── defaults
│       │   └── main.yml
│       ├── files
│       │   └── index.html
│       ├── handlers
│       │   └── main.yaml
│       ├── meta
│       │   └── main.yml
│       ├── README.md
│       ├── tasks
│       │   └── main.yaml
│       ├── templates
│       │   └── ports.conf.j2
│       ├── tests
│       │   ├── inventory
│       │   └── test.yml
│       └── vars
│           └── main.yaml
└── site.yaml

10 directories, 11 files
```

```shell
[vagrant@controller sample]$ curl 192.168.100.12:81
<h1> hello ansible role </h1>
```

<br>

<br>

## ansible-galaxy

- [Ansible-Galaxy](https://galaxy.ansible.com/) : 역할(role)을 공유하는 사이트
- 공유하는 데이터
  - 역할(Role)
  - 컬랙션(Collection): 역할 + 3rd Party 모듈
    - 직접만든 모듈을 포함할 수 있음
  - 번들(Bundle): RedHat OpenShift <-- 역할

<br>

#### 역할 목록 확인

- 시스템에 설치되어있는 역할의 목록을 보여줌

```
ansible-galaxy list
```

- 찾는 순서

1. /home/vagrant/.ansible/roles
2. /usr/share/ansible/roles
3. /etc/ansible/roles

- 디렉토리 직접 지정해서 확인 가능

```shell
$ ansible-galaxy list --roles-path roles
# /home/vagrant/10_role/roles
# /usr/share/ansible/roles
# /etc/ansible/roles
```

- 특정 키워드로 검색 가능

```
ansible-galaxy search elasticsearch
```

- 다른 사람들이 만든 역할들을 설치해서 사용할 수 있음

```
ansible-galaxy list --roles-path roles
```

- 역할 설치, 목록 확인, 제거 과정

```
ansible-galaxy search elasticsearch
ansible-galaxy info geerlingguy.elasticsearch
ansible-galaxy install geerlingguy.elasticsearch
ansible-galaxy remove geerlingguy.elasticsearch
```
