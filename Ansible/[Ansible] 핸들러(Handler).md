# [Ansible] ํธ๋ค๋ฌ(Handler)

<br>

### ๐INDEX

- [Idempotent(๋ฉฑ๋ฑ์ฑ)](#idempotent๋ฉฑ๋ฑ์ฑ)
- [ํ๋ ์ด, ์์์ ์ด๋ฆ(name)](#ํ๋ ์ด-์์์-์ด๋ฆname)
- [ํธ๋ค๋ฌ(Handler)](#ํธ๋ค๋ฌhandler)

<br>

<br>

## Idempotent(๋ฉฑ๋ฑ์ฑ)

- ๋ช๋ น์ ์ฌ๋ฌ๋ฒ ์คํํด๋ ๊ฒฐ๊ณผ๊ฐ ๋ณํ์ง ์๋๋ค๋ ๊ฒ
- ์: `start/started` => ์ด๋ฏธ ํ์ฌ ์คํ๋๊ณ  ์์ผ๋ฉด ์๋ฌด ์์ ์ํจ(๋ค์ ์์ํ  ํ์X) 
  - but restarted๋ ๋ฉฑ๋ฑ์ฑ์ ํด์น๋, ๋ฐ๋์งํ์ง ์์ ๋ฐฉ๋ฒ์
  - ํด๊ฒฐ๋ฐฉ๋ฒ: ์กฐ๊ฑด๋ฌธ ์ฌ์ฉ
- ๊ฐ๋ฅํ๋ฉด **๋ฉฑ๋ฑ์ฑ์ ๋ง์กฑํ๋ ๋ฐฉํฅ์ผ๋ก ์ค๊ณ**ํด์ผํจ
  - ๋ชจ๋  ๋ชจ๋, ๋ชจ๋์ ํ๋ผ๋ฏธํฐ๊ฐ ๋ฉฑ๋ฑ์ฑ์ ๋ง์กฑ ํ์ง๋ ์์



๋ฌธ์ ๊ฐ ์๋ ์ฝ๋: 24/7 ์๋น์ค์ ๊ฒฝ์ฐ, ์ฐฐ๋์ ์๊ฐ์ด์ง๋ง ์๋น์ค๊ฐ ์ค๋จ๋จ + ์ธ์์ด ๋์ด์ง => ์ค์ง์ ์ธ ํด๊ฒฐ๋ฐฉ๋ฒ์ด ์๋, **๋ฉฑ๋ฑ์ฑ ์๋๊ฒ**

```yaml
- hosts: 192.168.100.11
  become: yes #๋ช๋ น์ด์ -b ์ต์ ์จ์ค ํ์๊ฐ ์์
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
        state: restarted #๋ฉฑ๋ฑ์ฑ์ด ์๋ ๊ฒ
        enabled: yes
```

๋ฌธ์ ๋ฅผ ํด๊ฒฐํ๊ธฐ ์ํ ์ฝ๋ : **์กฐ๊ฑด๋ฌธ ํ์ฉ => ๋ณ๊ฒฝ์ฌํญ์ด ์์ ๋๋ง restarted)**

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

## ํ๋ ์ด, ์์์ ์ด๋ฆ(name)

- tasks๋ ์๋ฐํ๊ฒ ์๊ธฐํ๋ฉด name์ด ํ์ํ์ง ์์
- ์ด๋ฆ์ด ์์ผ๋ฉด, task๊ฐ ์๋ฐฑ ์์ฒ๊ฐ๊ฐ ๋์์ ๋ ์ด๋์ ์ค๋ฅ๊ฐ ๋ฌ๋์ง ํ์ํ๊ธฐ ์ด๋ ค์ => ๊ฐ๋ฅํ๋ฉด ์ด๋ฆ์ ๋ถ์ด๋ ๊ฒ์ด ์ข์
- ์ด๋ฆ์ ์ง์ ํ๋๊ฒ์ด ๋๋ฒ๊น ๋ชฉ์ ์ด๋ , ํ์ฌ ์ด๋ ์์นยท์์์ด ์คํ๋๊ณ  ์๋์ง ํ๋ณํ๊ธฐ๊ฐ ๋ชํ

```yaml
- name: Name Test Playbook  #playbook์๋ ์ด๋ฆ ์ง์  ๊ฐ๋ฅ
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

## ํธ๋ค๋ฌ(Handler)

- [Handlers](https://docs.ansible.com/ansible/latest/user_guide/playbooks_handlers.html)
- ๋ณ๊ฒฝ์ฌํญ์ด ๋ฐ์ํ์ ๋ ์คํํ  ์์
- ์ฌ์ฉ ๋ชฉ์ (์ด์ ) : ํน์  ์์์ด **๋ณ๊ฒฝ์ฌํญ**์ ๋ฐ์ํ๋ ๊ฒฝ์ฐ์๋ง ์คํํ๊ธฐ ์ํ ์์์ ์ง์ 
- handlers์ tasks์ ์์๋ ์๊ด์์
- ํธ๋ค๋ฌ์ ์์์ **๋ฐ๋์ ์ด๋ฆ์ด ์์ด์ผ ํจ**
  - ์ด๋ฆ์ด ์์ผ๋ฉด ์๋ฆผ์ ์ ์กํ  ๋ฐฉ๋ฒ์ด ์์(์๋ ์ฐธ์กฐ)
- ํธ๋ค๋ฌ๋ ๋ฐ๋์ `notify`๋ผ๊ณ ํ๋ ์๋ฆผ์ด ์์ด์ผํจ
  - changed ์ํ์์๋ง handlers name์ ์๋ฆผ์ ์ ์ก
  - notify์ handler์ ์ด๋ฆ์ ๋ง์ถฐ์ฃผ์ด์ผํจ
- ํธ๋ค๋ฌ๊ฐ ์คํ๋๋ ์์
  - ์๋ฆผ์ ๋ฐ์ ํธ๋ค๋ฌ ์์๋ง ์์๋๋ก ์คํ
  - **๋ชจ๋  ์์(`tasks`)์ด ์๋ฃ๋์ด์ผ ํธ๋ค๋ฌ๊ฐ ์คํ**
  - ์๋ฆผ์ ๋ฐ์ ํ์์ ์๊ด ์์ด ํ๋ฒ๋ง ์คํ
- ์๋ฆผ์ ํ๊บผ๋ฒ์ ๋ฐ์ ์ ์๋๋ก `listen`์ผ๋ก ๊ตฌ์ฑํ  ์ ์์
  - ์ฌ๋ฌ๊ฐ์ง ์๋น์ค๊ฐ ๊ฐ์ด ์๋ํ๋ ๊ฒฝ์ฐ

<br>

์์1

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

์์2

- task1, task2 ๋๋๊ณ  ํธ๋ค๋ฌ ์คํ
- ์๋ฆผ์ ๋ฐ์ ํ์ ์๊ด์์ => ์๋ฆผ์ ๋ฐ์ handler๋ง ์์๋๋ก ์คํ

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

์์3

- listen์ผ๋ก ํ๋ฒ์ ์ฌ๋ฌ์์ ๋ฐ๊ธฐ

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

#### ํธ๋ค๋ฌ๊ฐ ์คํ๋์ง ์๊ณ  ํ์ ์์์์ ์คํจ ํ๊ฒฝ์ฐ

- ์๋ ์ต์ `ls -P`์ผ๋ก ์ผ๋ถ๋ฌ ์์ ์ค๋ฅ ์ฝ์

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
    - name: error #์ค๋ฅ
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

- ๊ฒฐ๋ก : ํธ๋ค๋ฌ๊ฐ ์คํ๋์ง ์์

- ๋ฐฉ์งํ๋ ๋ฐฉ๋ฒ

  - `meta` ๋ชจ๋ : (์์์ด ์คํจํด๋) ๊ฐ์ ๋ก ํธ๋ค๋ฌ๋ฅผ ์คํํ๊ฒ ํ๋ ์ค์ 

  ```yaml
  - name: Flush handlers
    meta: flush_handlers
  ```

  - `--forece-handlers` : tasks๊ฐ failํ๋๋ผ๋ handler ์ค
    - `meta` ๋ชจ๋์ ์ฌ์ฉํ๋ ๊ฒ๋ณด๋ค ๊น๋

  ```shell
  ansible-playbook test.yaml --force-handlers
  ```

  



