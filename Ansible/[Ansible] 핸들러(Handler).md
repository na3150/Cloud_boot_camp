# [Ansible] 핸들러(Handler)

<br>

### 📌INDEX

- [Idempotent(멱등성)](#idempotent멱등성)
- [플레이, 작업의 이름(name)](#플레이-작업의-이름name)
- [핸들러(Handler)](#핸들러handler)

<br>

<br>

## Idempotent(멱등성)

- 명령을 여러번 실행해도 결과가 변하지 않는다는 것
- 예: `start/started` => 이미 현재 실행되고 있으면 아무 작업 안함(다시 시작할 필요X) 
  - but restarted는 멱등성을 해치는, 바람직하지 않은 방법임
  - 해결방법: 조건문 사용
- 가능하면 **멱등성을 만족하는 방향으로 설계**해야함
  - 모든 모듈, 모듈의 파라미터가 멱등성을 만족 하지는 않음



문제가 있는 코드: 24/7 서비스의 경우, 찰나의 순간이지만 서비스가 중단됨 + 세션이 끊어짐 => 실질적인 해결방법이 아님, **멱등성 없는것**

```yaml
- hosts: 192.168.100.11
  become: yes #명령어에 -b 옵션 써줄 필요가 없음
  vars:
    web_svc_port: "80"
  tasks:
    - yum:
        name: httpd
        state: installed
    - lineinfile:
        path: /etc/httpd/conf/httpd.conf
        regexp: '^Listen'
        line: 'Listen {{ web_svc_port }}' 
    - service:
        name: httpd
        state: restarted #멱등성이 없는 것
        enabled: yes
```

문제를 해결하기 위한 코드 : **조건문 활용 => 변경사항이 있을 때만 restarted)**

```yaml
- hosts: 192.168.100.11
  become: yes
  vars:
    web_svc_port: "80"
  tasks:
    - yum:
        name: httpd
        state: installed
    - lineinfile:
        path: /etc/httpd/conf/httpd.conf
        regexp: '^Listen'
        line: 'Listen {{ web_svc_port }}' 
      register: result
    - service:
        name: httpd
        state: started
        enabled: yes
    - service:
        name: httpd
        state: restarted
        enabled: yes
      when: result is changed
```

<br>

<br>

## 플레이, 작업의 이름(name)

- tasks는 엄밀하게 얘기하면 name이 필요하지 않음
- 이름이 없으면, task가 수백 수천개가 되었을 때 어디서 오류가 났는지 파악하기 어려움 => 가능하면 이름을 붙이는 것이 좋음
- 이름을 지정하는것이 디버깅 목적이든, 현재 어디 위치·작업이 실행되고 있는지 판별하기가 명확

```yaml
- name: Name Test Playbook  #playbook에도 이름 지정 가능
  hosts: 192.168.100.11
  tasks:
    - name: task1
      debug:
        msg: hello world
    - name: task2
      debug:
        msg: hello world
    - name: task3
      debug:
        msg: hello world
    - debug:
        msg: hello world
      name: task4
```

<br>

<br>

## 핸들러(Handler)

- [Handlers](https://docs.ansible.com/ansible/latest/user_guide/playbooks_handlers.html)
- 변경사항이 발생했을 때 실행할 작업
- 사용 목적(이유) : 특정 작업이 **변경사항**을 발생하는 경우에만 실행하기 위한 작업을 지정
- handlers와 tasks의 순서는 상관없음
- 핸들러의 작업은 **반드시 이름이 있어야 함**
  - 이름이 없으면 알림을 전송할 방법이 없음(아래 참조)
- 핸들러는 반드시 `notify`라고하는 알림이 있어야함
  - changed 상태에서만 handlers name에 알림을 전송
  - notify와 handler의 이름을 맞춰주어야함
- 핸들러가 실행되는 순서
  - 알림을 받은 핸들러 작업만 순서대로 실행
  - **모든 작업(`tasks`)이 완료되어야 핸들러가 실행**
  - 알림을 받은 횟수와 상관 없이 한번만 실행
- 알림을 한꺼번에 받을 수 있도록 `listen`으로 구성할 수 있음
  - 여러가지 서비스가 같이 작동하는 경우

<br>

예시1

```yaml
- name: Handler Example
  hosts: 192.168.100.11
  become: yes 
  vars:
    web_svc_port: "80"
  
  tasks:
    - name: Install httpd Package
      yum:
        name: httpd
        state: installed
    - name: Reconfigure httpd service port
      lineinfile:
        path: /etc/httpd/conf/httpd.conf
        regexp: '^Listen'
        line: 'Listen {{ web_svc_port }}' 
      notify:
        - Restart httpd Service
    - name: Start httpd Service
      service:
        name: httpd
        state: started
        enabled: yes 
  handlers:
    - name: Restart httpd Service
      service:
        name: httpd
        state: restarted
        enabled: yes
```

예시2

- task1, task2 끝나고 핸들러 실행
- 알림을 받은 횟수 상관없음 => 알림을 받은 handler만 순서대로 실행

```yaml
- name: handler example
  hosts: 192.168.100.11
  
  tasks:
    - name: task1
      file:
        path: /tmp/test1
        state: touch
      notify:
        - handle2
        - handle1
    - name: task2
      file:
        path: /tmp/test2
        state: touch
      notify:
        - handle1

  handlers:
    - name: handle1
      debug:
        msg: "handle1"
    - name: handle2
      debug:
        msg: "handle2"
```

예시3

- listen으로 한번에 여러작업 받기

```yaml
handlers:
  - name: Restart memcached
    ansible.builtin.service:
      name: memcached
      state: restarted
    listen: "restart web services"

  - name: Restart apache
    ansible.builtin.service:
      name: apache
      state: restarted
    listen: "restart web services"

tasks:
  - name: Restart everything
    ansible.builtin.command: echo "this task will restart the web services"
    notify: "restart web services"
```

<br>

#### 핸들러가 실행되지 않고 후속 작업에서 실패 한경우

- 없는 옵션 `ls -P`으로 일부러 작업 오류 삽입

```yaml
- name: handler example
  hosts: 192.168.100.11
  
  tasks:
    - name: task1
      file:
        path: /tmp/test1
        state: touch
      notify:
        - handle2
        - handle1
    - name: error #오류
      command: ls -P
    - name: task2
      file:
        path: /tmp/test2
        state: touch
      notify:
        - handle1

  handlers:
    - name: handle1
      debug:
        msg: "handle1"
    - name: handle2
      debug:
        msg: "handle2"
```

- 결론: 핸들러가 실행되지 않음

- 방지하는 방법

  - `meta` 모듈 : (작업이 실패해도) 강제로 핸들러를 실행하게 하는 설정

  ```yaml
  - name: Flush handlers
    meta: flush_handlers
  ```

  - `--forece-handlers` : tasks가 fail하더라도 handler 실
    - `meta` 모듈을 사용하는 것보다 깔끔

  ```shell
  ansible-playbook test.yaml --force-handlers
  ```

  



