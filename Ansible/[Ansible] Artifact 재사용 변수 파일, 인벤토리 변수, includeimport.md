# [Ansible] Artifact 재사용 : 변수 파일, 인벤토리 변수, include/import

<br>

### 📌INDEX

- [Artifact란?](#artifact란)
- [변수 파일](#변수-파일)
-  [인벤토리 변수](#인벤토리-변수)
-  [작업 재사용: import vs. include](#작업-재사용-import-vs-include)

<br>

<br>

## Artifact란?

Artefact, Artifact: 인공물

- 애플리케이션이 작동해서 생성한 데이터
- 사람이 직접 작성한 코드

**파일을 용도별로 구분을 해서 재사용**하기 위함

- Ansible에서 재사용할 수 있는 분야
  - 변수 파일
  - 작업 파일
  - 플레이/플레이북 파일
  - 역할(Role)

<br>

<br>

## 변수 파일
#### vars_files 

- 모듈이 아닌, 플레이의 키워드
- 변수를 playbook에 직접지정하는 것이 아니라, 별도의 파일에 지정하는 것
- `vars_files`의 값으로 기본적으로 리스트를 받음

```yaml
- hosts: x
  vars_files:
    - vars/a.yaml

  tasks:
  ...
```

<br>

#### include_vars 모듈

- 변수를 YAML/JSON 형태에서 동적으로 읽어옴
- `dir` : 변수 파일을 모아놓은 디렉토리 지정(디렉토리에 모아놓은 경우)
- `file` : 특정 파일명 (1개만 만든경우)

```yaml
- hosts: x

  tasks:
    - include_vars:
        dir: vars/
```

```yaml
- hosts: 192.168.100.11

  tasks:
    - include_vars: var.yaml
    - debug:
        msg: "{{ message }}" 
```

- `include_vars`모듈이 실행되기 전에는 변수를 사용(참조)할 수 없음⭐

```yaml
- hosts: 192.168.100.11

  tasks:
  	- debug:
  		msg: "{{ message }}" #오류 발생: undefined
    - include_vars: var.yaml
    - debug:
        msg: "{{ message }}"
```

<br>

<br>

## 인벤토리 변수

참고) `tree` 명령어: 관계를 확인해볼 수 있음

```shell
[vagrant@controller 08_artifact_vars]$ tree
.
├── ansible.cfg
└── inven.ini

0 directories, 2 files
```

<br>

#### 인벤토리 내부 파일에 변수 설정

**호스트 변수** : 호스트에 따라 달라져야하는 경우

```ini
node1 message="hello world"
```

**그룹 변수** : 호스트마다 동일한 구성을 하는 경우

```ini
[wordpress]
node1
node2

[wordpress:vars]
message="hello world"
```

<br>

#### 인벤토리 외부 파일에 변수 설정⭐

- [Variable precedence](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#variable-precedence-where-should-i-put-a-variable)
- 인벤토리 파일 또는 플레이북 파일이 있는 디렉토리에 다음 디렉토리가 있는 경우
  - `group_vars/<GROUP NAME>`
  - `hosts_vars/<HOST NAME>`
- 존재하면 해당 디렉토리 파일을 읽게 됨 
- 재사용성을 위해 대부분 외부 파일에 변수를 설정 
- 하위에 파일 대신 디렉토리를 구성하는 것도 가능 => 용도에 따라서 분리시킬 수 있음 => 변수가 많을 때 더 효과적으로 관리
- 즉, **<GROUP NAME>, <HOST NAME> 디렉토리 또는 파일 생성**



예시

**`ansible.cfg`**

```
[defaults]
inventory = inven.ini
```

**`inven.ini`** : **<GROUP NAME>, <HOST NAME>은 인벤토리 파일에 정의된 이름과 동일해야함⭐**

```ini
[nodes]
192.168.100.11
192.168.100.12
```

**`host_vars\192.168.100.11`** : 파일로 생성

```yaml
---
message: hello node1
```

**`host_vars\192.168.100.12\var.yaml`** : 디렉토리로 생성

```yaml
---
message: hello node2
```

**`group_vars\nodes`** 

```yaml
service_port: 8080
message: hello world
```

**`test.yaml`**

```yaml
---
- hosts: nodes
  tasks:
    - debug:
        msg: "{{ message }} - {{ service_port }}"
```

```shell
[vagrant@controller 08_artifact_vars]$ ansible-playbook test.yaml  
PLAY [nodes] *******************************************************************

TASK [Gathering Facts] *********************************************************
ok: [192.168.100.11]
ok: [192.168.100.12]

TASK [debug] *******************************************************************
ok: [192.168.100.11] => {
    "msg": "hello node1 - 8080"
}
ok: [192.168.100.12] => {
    "msg": "hello node2 - 8080"
}

PLAY RECAP *********************************************************************
192.168.100.11             : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
192.168.100.12             : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   

```

- `tree` 명령으로 구조 확인

```
.
├── ansible.cfg
├── group_vars
│   └── nodes
├── host_vars
│   ├── 192.168.100.11
│   └── 192.168.100.12
│       └── var.yaml
└── inven.ini
```

<br>

#### 우선순위

- [우선 순위](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#understanding-variable-precedence)
- 인벤토리 파일과 플레이북 파일이 항상 같은 위치에 있다고 보장할 수 없음
  - 같은 위치에 있다고 가정할 경우 inventory 우선순위가 높음(같은 변수 overwrite됨)
- 호스트 변수 > 그룹 변수

1. command line values (for example, `-u my_user`, these are not variables)
2. role defaults (defined in role/defaults/main.yml) [1](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#id13)
3. inventory file or script group vars [2](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#id14)
4. inventory group_vars/all [3](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#id15)
5. playbook group_vars/all [3](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#id15)
6. inventory group_vars/* [3](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#id15)
7. playbook group_vars/* [3](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#id15)
8. inventory file or script host vars [2](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#id14)
9. inventory host_vars/* [3](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#id15)
10. playbook host_vars/* [3](https://docs.ansible.com/ansible/latest/user_guide/playbooks_variables.html#id15)



예시

```
ansible-inventory --list
ansible-inventory --host <HOST>
```

- `group_vars\nodes`에 `message: hello world`라고 선언되어있음에도 불구하고 `host_vars\192.168.100.11`의 `message: hello node1`로 확인됨
  -  호스트 변수가 그룹 변수 보다 우선순위가 높기 때문

```shell
[vagrant@controller 08_artifact_vars]$ ansible-inventory --host 192.168.100.11
{
    "message": "hello node1", 
    "service_port": 8080
}
```

<br>

<br>

## 작업 재사용: import vs. include

- [Re-Using Ansible Architacts](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse.html#re-using-ansible-artifacts)
- include 
  - include_vars: 변수 가져오기
  - include_role: 역할 가져오기
  - **include_tasks**: 작업 가져오기

- import
  - import_playbook: 플레이북 가져오기
  - import_role: 역할 가져오기
  - **import_tasks**: 작업 가져오기

<br>

#### include vs. import

| |include|import|
|-|-|-|
|적용 시점|동적|정적|
|언제 실행되는가|해당 되는 모듈에 가서 읽음(처음에는 모름)|전처리(ansible이 playbook읽을 때 미리 읽음)|
|루프 사용 가능| 가능 | 불가능 |
| 핸들러 호출 가능 | 불가능 | 가능 |

<br>

#### import에서 루프 불가능

- `with_sequence` : 반복문(ioop)

```yaml
- hosts: 192.168.100.11
  tasks:
    - debug:
        msg: in play
    - import_tasks:
        file: task.yaml
      with_sequence: start=1 end=3  #안됨
    - debug:
        msg: in play
```

- 오류 발생

```shell 
ERROR! You cannot use loops on 'import_tasks' statements. You should use 'include_tasks' instead.

The error appears to be in '/home/vagrant/09_artifact_tasks/import.yaml': line 5, column 7, but may
be elsewhere in the file depending on the exact syntax problem.

The offending line appears to be:

        msg: in play
    - import_tasks:
      ^ here
```

#### 해결방법

```yaml
- hosts: 192.168.100.11
  tasks:
    - debug:
        msg: in play
    - import_tasks:
        file: task.yaml
    - debug:
        msg: in play
```

`task.yaml`

- 파일 내부에 루프(loop) 생성

```yaml
- debug:
  with_sequence: start=1 end=3
```

<br>

#### include에서 핸들러 호출 불가능

```yaml
- hosts: 192.168.100.11
  tasks:
    - command: hostname
      notify:
        - hello notify
  handlers:
    - include_tasks: task.yaml
```

`task.yaml`

```yaml
- name: hello notify
  debug:
    msg: hello notify
```

- include_tasks를 만나기 전에 어디로 notify를 보낼지 알 수 없음

```
TASK [command] ******************************************************************
ERROR! The requested handler 'hello notify' was not found in either the main handlers list nor in the listening handlers list
```

#### 해결방법

- `include_tasks`모듈에 이름(name)을 부여해주면 가능

```yaml
- hosts: 192.168.100.11
  tasks:
    - command: hostname
      notify:
        - hello notify
  handlers:
    - name: hello notify
	  include_tasks: task.yaml
```