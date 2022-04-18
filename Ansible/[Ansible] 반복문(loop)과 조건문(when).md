# [Ansible] 반복문(loop)과 조건문(when)

<br>

### 📌INDEX

- [반복문(loop)](#반복문loop)
  - [리스트(목록) 반복문](리스트목록-반복문)
  - [사전 반복문](사전-반복문)
  - [프로세스 관점](프로세스-관점)

- [조건문(when)](조건문when)

<br>

<br>

## 반복문(loop)

- [공식 문서](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html#playbooks-loops)
- 키워드를 사용 : [키워드 문서](https://docs.ansible.com/ansible/latest/reference_appendices/playbooks_keywords.html#playbook-keywords)
- 반복은 기본적으로 task레벨에서 진행함 : play level에서는 불가, (loop)키워드가 있는 레벨
- 작업(Task)에서 `loop`, `'with_'`, `'until'`키워드로 반복문 구성
- 2.5버전부터 loop 추가됨: 글쓴이가 사용하는 건 2.9
- loop 지시어에 리스트가 들어가 있음
  - 반드시 이름이 `item`이어야함 .
    - for i에서 `i`와 비슷한 것

<br>

#### 리스트(목록) 반복문

`loop` 대신, `with_items`, `with_list`

- [with_items](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html#with-items), [with_list](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html#with-list)
- 리스트를 사용해 다양한 방법으로 활용 가능

```yaml
- hosts: 192.168.100.11
  gather_facts: no

  tasks:
    - debug:
        msg: "{{ item }}"
      with_items:
        - apple
        - banana
        - carrot
```

```yaml
- hosts: 192.168.100.11
  gather_facts: no
  vars:
    fruits:
      - apple
      - banana
      - carrot

  tasks:
    - debug:
        msg: "{{ item }}"
      with_items:
        "{{ fruits }}"
```

```yaml
- hosts: 192.168.100.11
  gather_facts: no
  vars:
    fruits:
      - apple
      - banana
      - carrot

  tasks:
    - debug:
        msg: "{{ item }}"
      loop:
        "{{ fruits }}"
```

- 결과 : playbook 실행

```shell
[vagrant@controller 02_loop]$ ansible-playbook test.yaml -b

PLAY [192.168.100.11] **********************************************************

TASK [debug] *******************************************************************
ok: [192.168.100.11] => (item=apple) => {
    "msg": "apple"
}
ok: [192.168.100.11] => (item=banana) => {
    "msg": "banana"
}
ok: [192.168.100.11] => (item=carrot) => {
    "msg": "carrot"
}

PLAY RECAP *********************************************************************
192.168.100.11             : ok=1    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0  
```



<br>

#### 사전 반복문

`loop` 대신 `with_dict`

- [with_dict](https://docs.ansible.com/ansible/latest/user_guide/playbooks_loops.html#with-dict)

- 리스트가 아닌 딕셔너리 형식의 변수도 활용 가능

- 딕셔너리는 중괄호 {}로 묶어야한다는 것 주의

```yaml
- name: Add several users
  user:
    name: "{{ item.name }}"
    state: present
    groups: "{{ item.groups }}"
  loop:
    - name: 'testuser1'
      groups: 'wheel'
    - name: 'testuser2'
      groups: 'root'
    #[ {name: 'testuser1', groups: 'wheel'}, {name: 'testuser2', group: 'root'} ]
```

```yaml
- hosts: 192.168.100.11
  gather_facts: no
  vars:
    fruits:
      - name: apple
        count: 2
      - name: banana
        count: 3

  tasks:
    - debug:
        msg: "{{ item.name }} / {{ item.count }}"
      loop:
        '{{ fruits }}'
```

<br>

#### 프로세스 관점

- (경우1) 명령을 한번에
  - 프로세스를 한번만 실행하면 됨

```shell
sudo yum install httpd,php,mariadb-server
```

- (경우2) 명령을 반복해서
  - 프로세스를 3번을 실행해야함

```
sudo yum install httpd
sudo yum install php
sudo yum install mariadb-server
```

- 한번 작업하는 것보다 3번 작업하는 것이 시간적으로 오래걸림
- 즉, **패키지 설치와 같은 형태에서는 반복문을 쓰는 것이 효율적으로 더 떨어짐**

- systemctl과 같은 경우에는 어차피 여러개의 서비스를 동시에 제어할 수 없기 때문에, 반복문을 통해 코드양을 줄이는 것이 더 효율적
- replace도 반복문을 통해 코드 양을 줄일 수는 있지만, template을 사용하는 것이 좋음

<br>
<br>

## 조건문(when)

- [basic-conditionals-with-when](https://docs.ansible.com/ansible/latest/user_guide/playbooks_conditionals.html#basic-conditionals-with-when)
- [playbooks-tests](https://docs.ansible.com/ansible/latest/user_guide/playbooks_tests.html#playbooks-tests)
- [playbooks-filters](https://docs.ansible.com/ansible/latest/user_guide/playbooks_filters.html#playbooks-filters)

- 작업에서 `when` 키워드 사용, 조건을 정의 `test`, `filter` 사용
- 조건 정의시  `{{ }}`  중괄호 사용 X 
  - even 변수를 참조하는 경우에도
- 참고) shell 모듈 : 정말 모듈이 없어서 명령어라도 써야할 때
- skipping : 조건을 만족하지 않아서 skip

<br>

예시

```yaml
- hosts: 192.168.100.11
  vars:
    switch: "on"
  tasks:
    - debug:
        msg: "hello switch on"
      when: switch == "on"
    - debug:
        msg: "hello switch off"
      when: switch == "off"
```

<br>

**조건문에 많이 사용하는 팩트 변수** : [commonly-used-facts](https://docs.ansible.com/ansible/latest/user_guide/playbooks_conditionals.html#commonly-used-facts)

- 팩트 변수 수집

```
ansible [ip주소] -m setup
```

- `ansible_facts["distribution"]` == `ansible_facts['os_family']` == `ansible_distribution`

```7yaml
- hosts: wp
  tasks:
    - debug:
        msg: "hello CentOS"
      when: ansible_facts["distribution"] == "CentOS"
    - debug:
        msg: "hello Ubuntu"
      when: ansible_facts["distribution"] == "Ubuntu"
```

