# [Ansible] 변수

<br>

<br>

## 변수 정의 및 참조

- 변수는 {{ }} 쌍중괄호사이에
  - {{}} 사용할때는 쌍따옴표 또는 홑 따옴표로 감싸줘야함
- 문법 오류
  -  hello/abc.com을 원할 때
      - abc: hello
      - X : '{{ abc}}'/abc.com
      - O : '{{abc}}/abc.com'

```yaml
template:
  src: foo.cfg.j2
  dest: '{{ remote_install_path }}/foo.cfg'
  name: '{{ abc }}'
  dest: '{{ abc }}/abc.com'
  dest: '{{ abc }}'/abc.com #문법 오류
```

- 계층 형식의 변수를 표기할 때는 대괄호로 표시하는 것이 좋음

  - foo['변수']
  - X : foo.변수

- tasks와 host의 순서는 상관이 없지만, 관습적으로 hosts먼저 쓰고 한칸 듸고 tasks

  - 변수(vars)는 hosts아래에 붙여줌

- **`debug`모듈**

  - [공식 문서](https://docs.ansible.com/ansible/2.9/modules/debug_module.html#debug-module)

  - playbook 작성할 때 디버깅에 활용

    - 잘 활용하면 매무 효율적

  - 한 모듈에서 var와 msg를 사용할 수 없음?

    - var를 사용하면 msg를 사용할 수 없고, msg를 사용하면 var를 사용할 수 없음

    - 파라미터 설명잘보기

```yaml
- hosts: 192.168.100.11
  vars:
    msg: hello world
    
  tasks:
    - debug:
        var: msg #파라미터의 값으로 변수를 받는 것? 아주 특수한 경우
    - debug:
        msg: '{{ msg }} korea' #일반적으로는 이렇게 참조함
```

- 주의
    - ["대괄호"]
    - 바깥을 감싸는 것과 대괄호속 감사는 것을 다른 것으로

```yaml
- hosts: 192.168.100.11
  vars:
    msg: hello world
    web:
      message: hello web
    fruits:
      - apple
      - banana

  tasks:
    - debug:
        msg: '{{ msg }} korea'
    - debug:
        msg: "{{ web['message'] }}" #또는 "{{ web['message'] }}"
        #msg: '{{ web["message"] }}' O
        #msg: '{{ web['message'] }}' X
    - debug:
        msg: '{{ fruits[0] }} {{ fruits[1] }}'
```

<br>

**⭐참고)**

```shell

ansbile은 playbook과 똑같은 형태임. 결과도 같음

출력이 다름

ac-hoc 커맨드의 기본적인 목적은 path나 간단한 작업 위주로 하는 것

playbook -> 실행위주, return value X

ad-hoc -> test위주, return value가 화면에 표시됨
```

<br>

<br>

## 등록 변수

- registered variable

- [공식 문서](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#registering-variables)

- Play
  - play level에서 사용할 수 있는 지시어
  - hosts, tasks, vars... 등

- Role

- Block

- Task
  - register: task의 키워드
  - 변수명을 지정함
  - 모듈의 return value들이 모두 yum_result에 저장됨

```shell
- hosts: 192.168.100.11

  tasks: 
    - yum:
        name: httpd
        state: installed
      register: yum_result


    - debug:
        var: yum_result  
```

- return code만 보이게 하기

```yaml
- hosts: 192.168.100.11

  tasks:
    - yum:
        name: httpd
        state: installed
      register: yum_result #등록 변수

    - debug:
        var: yum_result
    - debug:
        var: yum_result["rc"] #return code만
```

<br>

<br>

## 변수 정의 위치

- 플레이북
- 인벤토리
- 외부 참조 파일
- 역할
- 명령 -e 옵션

<br>

### 플레이북에서 변수 정의

#### vars
```
- hosts: a
  vars:
    message: hello
```

#### vars_prompt

- [공식 문서](https://docs.ansible.com/ansible/latest/user_guide/playbooks_prompts.html#interactive-input-prompts)
- 변수의 값을 대화 형태로 입력할 수 있음
- private
  - yes가 default
  - yes이면, 입력형태가 안보이게 됨

```
---
- hosts: 192.168.100.11
  vars_prompt:
    - name: username
      prompt: What is your username?
      private: no

    - name: password
      prompt: What is your password?

  tasks:
    - debug:
        msg: 'Logging in as {{ username }}, password is {{ password }}'
```

- 실행결과

```shell
What is your username?: admin
What is your password?: 

PLAY [192.168.100.11] ***********************************************************

TASK [Gathering Facts] **********************************************************
ok: [192.168.100.11]

TASK [debug] ********************************************************************
ok: [192.168.100.11] => {
    "msg": "Logging in as admin, password is dkagh1."
}

PLAY RECAP **********************************************************************
192.168.100.11             : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

- ansible의 주 목적은 자동화기 때문에, 일반적으로 잘 사용되지 않음

#### vars_files

- 변수를 playbook에 직접지정하는 것이 아니라, 별도의 파일에 지정하는 것
- vars_files의 값으로 기본적으로 리스트를 받음
  - vars.yaml 파일에 변수 정의

```
- hosts: a
  vars_files:
    - vars.yaml

  tasks:
    - debug:
        var: msg
```

`vars.yaml`
```yaml
msg: hello world
```

<br>

<br>

### 인벤토리에서 변수 정의

> 변수의 미치는 범위
> 특정 호스트 또는 그룹에게 영향을 줌

- 설정파일에서 어떤 인벤토리를 가리키고 있는지 확인 => 다른 걸 가리키고 있으면 정의되지 않은 변수라고 할 수 있음
- `-i` 옵션을 통해 지정해주거나, 현재 디렉토리에 `ansible.cfg` 파일을 생성해서 적용되도록

```ini
[nodes]
192.168.100.11 msg=seoul
192.168.100.12 msg=busan

[nodes:vars]
message="hello world"
```

- 그룹 
- 호스트명 바로 옆에서 변수 정의할 수 있고, [그룹명:vars]에도 변수 정의할 수 있음

```yaml
- hosts: nodes
  tasks:
    - debug:
        var: msg
    - debug:
        var: message     
```

```ini
[nodes] 
192.168.100.11 msg=hello

[nodes:vars]
message="hello world"
```

- 변수가 미치는 범위(scope)을 잘 생각해보기
  - playbook에 설정하는것은 playbook을 실행하는 모든 호스트들에 적용됨 

```ini
[nodes] 
192.168.100.11 msg=seoul
192.168.100.12 msg=busan

[nodes:vars]
message="hello world"
```

- playbook을 실행하는 호스트 모두 공통적인 변수로 정의하고 싶다면 vars, vars promt나 vars_file 등을 이용
- 특정 호스트나 그룹에게만 부여하고 싶은 변수가 있다면 인벤토리 변수를 선언해야함

<br>

<br>

### 명령에서 변수 정의

```
ansible-playbook test.yaml -e msg=korea
```

- inventory파일에 어떻게 설정되어있든 msg=korea로 설정됨
- 즉, 변수가 어디에 정의되느냐에 따라 우선순위가 있음

<br>

<br>

## 변수의 우선순위

> https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#understanding-variable-precedence

- 변수를 선언할 수 있는 위치가 정의되어있음
- 같은 변수명이 서로 다른 위치에 정의되어있을 때, 우선순위가 높은것이 적용됨

- 변수의 우선순위 꼭 기억해야함

낮음

- 인벤토리 변수
- 플레이 vars
- 플레이 vars_prompt
- 플레이 vars_files
- 명령 -e, --extra-vars
높음

<br>

<br>

## 변수의 범위

- 글로벌: 명령의 -e
- 플레이: vars, vars_files, vars_prompt
- 호스트: 인벤토리 변수

<br>

<br>

## 필터

변수에서 필요한 내용만 취득
변수에서 값을 가공/형식변경(transform)

- [공식 문서](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html)

```yaml
{{ msg | filter }}
{{ 변수명 | 필터명 }}
```

- 예시: 변수에 값이 없으면 '5'라는 값을 넣어라

```
{{some_varible | default(5) }}
```

- 예시: dict2items : dict의 값을 list로 바꿔줌
  - items2dict : item(list)를 dict(딕셔너리)로 바꿔줌

```
{{ dict | dict2items }}
```

- random : 한개를 랜덤으로 pop 함
- 예시 : 사용자 만들기
  - password는 그대로 작성하는 것이 아니라 암호화해서 넣어야함
  - `inventory_hostname`은 특수 변수

```yaml
- hosts: 192.168.100.11
  vars:
    pwd: P@ssw0rd
  tasks:
    - user:
        name: devops
        password: "{{ pwd | password_hash('sha512', 65534 | random(seed=inventory_hostname) | string) }}"
        state: present
```

node1 사용자 생성확인

```
[vagrant@node1 ~]$ sudo cat /etc/shadow
...
devops:$6$17235$Ew5SJfWabTTFnosCV0/te630c0sENLoYWoZ.D7icqI71nKHKHuZRquwwPNe6jtsviILDbWc1hJJBt2DN4YY4w0:19098:0:99999:7:::
```

<br>

<br>

## 팩트 변수

- `setup` 모듈에 의해 수집(하드웨어, OS 관련 정보) 되는 호스트의 변수

```
[vagrant@controller filter]$ ansible 192.168.100.11 -m setup
192.168.100.11 | SUCCESS => {
    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "10.0.2.15", 
            "192.168.100.11"
        ], 
        "ansible_all_ipv6_addresses": [
            "fe80::5054:ff:fe4d:77d3", 
            "fe80::a00:27ff:fef9:abb0"
        ], 
        "ansible_apparmor": {
            "status": "disabled"
        }, 
        "ansible_architecture": "x86_64", 
        "ansible_bios_date": "12/01/2006", 
        "ansible_bios_version": "VirtualBox", 
        "ansible_cmdline": {
            "BOOT_IMAGE": "/boot/vmlinuz-3.10.0-1127.el7.x86_64", 
            "LANG": "en_US.UTF-8", 
            "biosdevname": "0", 
            "console": "ttyS0,115200n8", 
            "crashkernel": "auto", 
            "elevator": "noop", 
            "net.ifnames": "0", 
        ....
```

- 변수를 정의하지 않아도 변수의 값이 나옴

```yaml
- hosts: 192.168.100.11
  tasks:
    - debug: 
        msg: "{{ ansible_hostname }}"
    - debug:
        msg: "{{ ansible_all_ipv4_addresses }}"
```

- 실행 항상 첫 작업 `gathering facts` 작업에 의해서 수집
  - 팩트 변수를 안쓸것이라면 굳이 수집할 필요가 없음=> gather_facts: no

```yaml
- hosts: 192.168.100.11
  gather_facts: no
```

- 사용 예시
  - 모든 운영체제를 지원하는 wordpress를 배포하고 싶을 때
    - fact 변수를 수집하여, 어떤 운영체제인지 구별할 때 사용할 수 있음
    - 조건문을 통해 ubuntu일 때는 어떻게 하고, CentOS일 때는 어떻게 하고~
  - 데이터베이스를 할 때, 메모리 크기에 따라서 나눠서 진행
  - sdb,sda 또는 파일 시스템 여부에 따라 작업 진행

- 즉, 운영체제나 하드웨어 정보를 고려해서 작업을 진행할지 말건지에 대한 스위치로 작용할 수 있음

<br>

<br>

## 특수 변수

- [공식 문서](https://docs.ansible.com/ansible/latest/reference_appendices/special_variables.html)

- 특수한 목적을 띤 변수이며 시스템이 자동으로 값을 산출

- hosts보다 높은 우선순위를 가지게 정의할 수도 있음
- 종류 예시
  - groups
    - 호스트가 속한 그룹
    - 인벤토리의 그룹을 취득할 때, groups 변수를 참조하면 변수의 명이 나옴?
  - hostvars
  - inventory_hostname
    - 인벤토리에 있는 호스트의 이름을 취득할 수 있음
  - ...

<br>

<br>

## 템플릿

jinja 템플릿

- [공식 문서](https://jinja.palletsprojects.com/en/2.10.x/)
- copy 모듈과 파라미터가 동일
  - 즉, 기본적으로 복사하는 것
- copy : 말그대로, 파일을 그대로 복사
- template
  - 변수의 대치가 됨
  - 동적 template, dynamic template이라 함
  - text 파일을 동적으로 만드는 데 사용
  - 동적으로 렌더링할 때 사용하는 것?
- 하나하나 replace하는 것보다, 템플릿으로 작업하면 훨씬 더 빠르게 진행할 수 있음
- 다수의 내용들을 변경하는 데 유용함

```
- hosts: 192.168.100.11
  vars:
    message: korea
  tasks:
    - copy:
        src: origin.txt
        dest: /tmp/copy.txt
    - template:
        src: origin.txt
        dest: /tmp/template.txt
```

`origin.txt`
```
hello {{ message }} world
```

> jinja 템프릿 파일 확장자(필수는 아니나 관습적으로)
> `.j2` , `.jinja2`

- 기존의 wordpress구성에서 replace

```
 - replace:
        path: /var/www/html/wordpress/wp-config.php
        regexp: database_name_here
        replace: wordpress
    - replace:
        path: /var/www/html/wordpress/wp-config.php
        regexp: username_here
        replace: wpadm
    - replace:
        path: /var/www/html/wordpress/wp-config.php
        regexp: password_here
        replace: P@ssw0rd
```

- template 파일생성 : wp-config.php.j2

```php
...
define ('DB_NAME', '{{ mysql["dbname"] }}' )
define ('DB_USER', '{{ mysql["dbuser"] }}' )
define ('DB_PASSWORD','{{ mysql["dbpwd"] }}' )
...
```

- playbook
  - 변수는 `wordpress_vars.yaml`에 정의되어 있음??

```yaml
- template:
	src: wp-config.php.j2
	dest: /var/www/html/wordpress/wp-config.php
```

