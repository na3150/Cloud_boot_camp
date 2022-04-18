# [Ansible] 블록(Block), 태그(Tag)와 작업제어(Step)

<br>

### 📌INDEX

- [블록(Block)](#블록block)

- [태그(Tag)](#태그tag)
- [작업 제어(Step)](#작업-제어step)

<br>

<br>

## 블록(Block)

- [Blocks](https://docs.ansible.com/ansible/latest/user_guide/playbooks_blocks.html)
- 블록이란? 여러 작업(task)을 묶어 놓은 그룹
  - playbook 키워드

- 블록의 기능

1. 여러 작업에 공통의 키워드를 부여할 수 있음(ex: 조건문)
2. `block`, `rescue`, `always` 블록을 이용해 오류 처리를 할 수 있음 => 자주 사용되지는 X

- `block` 블록은 항상 실행
- `rescue` 는 `block` 블록의 오류가 있을 때만 실행
  - playbook은 원래 중간에 task가 실패하면 play가 중단됨
  - 실패했을 때, 중단되지 않고 rescue로 넘어감(rescue 실행)
  - 예: 어떠한 작업이 실패할 가능성이 있다고 판단되는 경우 block으로 묶고, 오류를 해결하기 위한 작업을 `rescue`에
- `always` 는 항상 실행
  - 실패와 상관없이 항상 실행

```yaml
- hosts: 192.168.100.11

  tasks:
    - block:
        - debug:
            msg: hello world
        - command: /usr/bin/false #항상 실패
        - debug:
            msg: hello world2

      rescue:
        - debug:
            msg: It's rescue

      always:
        - debug:
            msg: It's Always
```



**참고) `ignore_errors` **

- 기본적으로 값은 block
- 오류가 발생할 수 있다고 판단되고, 오류가 발생하더라도 후속작업을 해야하는 경우 유용
- 특정 작업에서 오류를 처리 가능

```yaml
- hosts: 192.168.100.11

  tasks:
    - block:
        - debug:
            msg: hello world
        - command: /usr/bin/false #항상 실패
        - debug:
            msg: hello world2
      ignore_errors: yes #msg와 같은 level에 작성하는 것도 가능

      rescue:
        - debug:
            msg: It's rescue

      always:
        - debug:
            msg: It's Always
```



<br><br>

## 태그(Tag)

- [Tags](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tags.html)

- 아주 큰 playbook을 작성할 때 사용
- 작업에 태그를 부여하고, 특정 태그의 작업만 실행할 수 있음

```yaml
- hosts: 192.168.100.11
  gather_facts: no

  tasks:
    - debug:
        msg: "web server stage"
      tags:
        - stage
    - debug:
        msg: "web server product"
      tags:
        - prod
    - debug:
        msg: "web server all"
```

- 태그 종류
  - all 태그: 모든 작업이 속함(태그가 없는 것 까지 실행)
  - untagged 태그: 태그가 설정되어 있지 않는 작업 속함

```shell
ansible-playbook test.yaml --tags=all
```

```shell
ansible-playbook test.yaml --tags=stage,prod
```

- 태그 관련 확인 옵션

```shell
ansible-playbook test.yaml --list-tasks
ansible-playbook test.yaml --list-tags
```

<br>

<br>

## 작업 제어(Step)

디버깅할 때 많이 사용



#### step

- 하나씩 실행해가면서 확인해볼 수 있음

```shell
ansible-playbook test.yaml --step
```

#### 특정 작업 부터 시작

- 이름(name)을 부여하여 특정 작업을 실행

```shell
ansible-playbook test.yaml --start-at-task="task3"
```

```shell
ansible-playbook test.yaml --start-at-task="task3" --step
```

```shell
ansible-playbook test.yaml --start-at-task="task3" --limit 192.168.100.12
```



