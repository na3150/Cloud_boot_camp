# [Ansible] ์ญํ (Role)



### ๐INDEX

- [์ญํ (Role)](#์ญํ role)
  - [์ค์ต](#์ค์ต)
- [ansible-galaxy](#ansible-galaxy)

<br>

<br>

## ์ญํ (Role)

- [Roles](https://docs.ansible.com/ansible/latest/user_guide/playbooks_reuse_roles.html#playbooks-reuse-roles)
- ํตํฉ(ํต์ผ)๋ ํ๋ ์ด๋ถ์ ๋ง๋ค๊ธฐ์ํ ํต์ผํ๋ ๊ตฌ์กฐ : ์ญํ  ์์ฑ --> ํตํฉ --> ํ๋ ์ด๋ถ
- `roles`๋๋ ํ ๋ฆฌ ์ฌ์ฉ

```shell
mkdir roles
```

- ๊ตฌ์กฐํ๋ ํ์์ ์๋์ผ๋ก ๋ง๋ค์ด์ฃผ๋ ๋ช๋ น์ด : `ansible-galaxy init`
  - ์ง์  mkdir๋ก ๋ง๋ค์ด๋ ์๊ด์์ผ๋, ์ด๋ฆ์ ์ ํด์ ธ์์

```shell
ansible-galaxy init [์ญํ ์ด๋ฆ] --init-path [์ญํ  ๋๋ ํ ๋ฆฌ ์์น]
```



์์

```shell
ansible-galaxy init common --init-path roles
```

- `tree`๋ช๋ น์ด๋ก ๊ตฌ์กฐ ํ์ธ 

```
.
โโโ roles
    โโโ common
        โโโ defaults
        โ   โโโ main.yml
        โโโ files
        โโโ handlers
        โ   โโโ main.yml
        โโโ meta
        โ   โโโ main.yml
        โโโ README.md
        โโโ tasks
        โ   โโโ main.yml
        โโโ templates
        โโโ tests
        โ   โโโ inventory
        โ   โโโ test.yml
        โโโ vars
            โโโ main.yml
```

`roles/common`: ์ญํ ์ ์ด๋ฆ

- roles ๋ด์ ๋๋ ํ ๋ฆฌ๋ช์ด ์ญํ ์ ์ด๋ฆ

`tasks/main.yml`: ์์์ด ์์น

<br>

`handlers/main.yml`: ํธ๋ค๋ฌ ์์์ด ์์น

<br>

`tests/inventory`: ์ญํ ์ ํ์คํธ ํ๊ธฐ ์ํ ์ธ๋ฒคํ ๋ฆฌ
`tests/test.yml`: ์ญํ ์ ํ์คํธ ํ๊ธฐ ์ํ ํ๋ ์ด๋ถ

- tests : ๋จ์ ํ์คํธ๋ฅผ ์ํ ํ์ผ๋ค -> ์์ฃผ ์ฌ์ฉ๋์ง๋ X

<br>

`defaults/main.yml`: ๊ธฐ๋ณธ ์ญํ  ๋ณ์(์ฐ์  ์์๊ฐ ๋งค์ฐ ๋ฎ์)

<br>`vars/main.yml`: ์ญํ  ๋ณ์(์ฐ์  ์์๊ฐ ๋งค์ฐ ๋์)

<br>

`files`: ํ์ผ ๊ด๋ จ ๋ชจ๋์ `src:` ํ๋ผ๋ฏธํฐ์์ ์ฐธ์กฐํ๋ ํ์ผ์ ์์น

- ๊ฒฝ๋ก๋ฅผ ์ง์ ํ  ํ์๊ฐ ์์(ํ์ผ ์ด๋ฆ๋ง)

`files/a.txt`: ๊ฒฝ๋ก ์ง์ ํ  ํ์ ์์

```
- copy:
	src: a.txt
```
<br>

`templates`: ํํ๋ฆฟ ๋ชจ๋์ `src:` ํ๋ผ๋ฏธํฐ์์ ์ฐธ์กฐํ๋ ํ์ผ์ ์์น

- ํํ๋ฆฟ ํ์ผ์ ๊ฒฝ๋ก๋ฅผ ์ง์ ํ  ํ์๊ฐ ์์

`templates/a.j2`

```
- templates:
    src: a.j2
```

<br>

`meta/main.yml`: ์ญํ ์ ์ค๋ชํ๊ณ  ์๋ ํ์ผ

- ์ญํ  ๋ฒ์ 
- ์ญํ  ์ด๋ฆ
- ์ญํ  ๋ง๋  ์ฌ๋
- ์ญํ  ์ ์ฉ๋๋ ํ๋ ํผ(๋ฆฌ๋์ค ๋ฐฐํฌํ)
- **์ญํ ์ ์์กด์ฑ**
  - meta๋ฅผ ์ฌ์ฉํ๋ ๊ฐ์ฅ ์ค์ํ ์ด์ 
  - ๋ค๋ฅธ ์ญํ ์ ๋ํ ์์กด์ฑ์ ์ ์ํด๋์ผ๋ฉด, ํด๋น๋๋ ์ญํ ๋ ํจ๊ป ์คํ๋จ 

<br>

#### ํ๋ ์ด์์ ์์ ์คํ ์์

- ์ฃผ์: ๊ฐ ์์(pre_tasks, roles, tasks .. )์ด ๋๋  ๋๋ง๋ค ํธ๋ค๋ฌ๊ฐ ์คํ๋จ
- ์ด๋ค ์ญํ ์ ์ํํ๊ธฐ ์  ํน์ ์ํํ ํ  ๊ฐ๋จํ ์์์ ํด์ผํ  ๋ `pre_tasks`, `post_tasks`๋ฅผ ์ฌ์ฉํ  ์ ์์

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
2. pre_tasks์ handlers
3. roles
4. roles์ handlers
5. tasks
6. tasks์ handlers
7. post_tasks
8. post_tasks์ handlers

<br>

- role์ ํ์ฉํ main playbook ํ์ผ ์์ : [์ถ์ฒ](https://github.com/ansible/ansible-examples/blob/master/lamp_simple/site.yml)

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

#### **์ค์ต**

- `ansible-galaxy init`๋ช๋ น์ ํตํด ์๋์ผ๋ก ๊ตฌ์กฐ ์์ฑ
  - ์ฃผ์: ํด๋น ๋ช๋ น์ผ๋ก ๊ตฌ์กฐ ์๋ํํ๋ฉด '`yaml`' ์๋ '`yml`'๋ก ์์ฑ๋จ => ๊ธ์ด์ด๋ ๋ค๋ฆ๊ฒ ๊นจ๋ซ๊ณ  ๊ธฐ์กด yml ํ์ผ ์ญ์ ํจ

```shell
[vagrant@controller sample]$ ansible-galaxy init web --init-path roles
- Role web was created successfully
```

- **yaml ํ์ผ ์์ฑ ์ '`tasks: `', '`handlers:`','`vars:` ๋ฑ ๋ณ๋๋ก ์ ์ธํ์ง ์์๋ ๋จ**: ๊ตฌ์กฐ๊ฐ ์ ํด์ ธ์๋ ๊ฒ

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

- main playbook ๋ง๋ค๊ธฐ

```shell
[vagrant@controller sample]$ code site.yaml
```

```shell
- hosts: 192.168.100.12
  become: yes

  roles:
    - web 
```

- ๊ธฐ์กด ๊ฒ(ํ์์๋ ๊ฒ) ์ญ์ 

```
[vagrant@controller sample]$ ls
roles  sample.yaml  site.yaml  web_config  web_contents
[vagrant@controller sample]$ rm -rf sample.yaml web_config/ web_contents/
```

- ๊ฒฐ๊ณผ ํ์ธ

```shell
[vagrant@controller sample]$ tree
.
โโโ roles
โ   โโโ web
โ       โโโ defaults
โ       โ   โโโ main.yml
โ       โโโ files
โ       โ   โโโ index.html
โ       โโโ handlers
โ       โ   โโโ main.yaml
โ       โโโ meta
โ       โ   โโโ main.yml
โ       โโโ README.md
โ       โโโ tasks
โ       โ   โโโ main.yaml
โ       โโโ templates
โ       โ   โโโ ports.conf.j2
โ       โโโ tests
โ       โ   โโโ inventory
โ       โ   โโโ test.yml
โ       โโโ vars
โ           โโโ main.yaml
โโโ site.yaml

10 directories, 11 files
```

```shell
[vagrant@controller sample]$ curl 192.168.100.12:81
<h1> hello ansible role </h1>
```

<br>

<br>

## ansible-galaxy

- [Ansible-Galaxy](https://galaxy.ansible.com/) : ์ญํ (role)์ ๊ณต์ ํ๋ ์ฌ์ดํธ
- ๊ณต์ ํ๋ ๋ฐ์ดํฐ
  - ์ญํ (Role)
  - ์ปฌ๋์(Collection): ์ญํ  + 3rd Party ๋ชจ๋
    - ์ง์ ๋ง๋  ๋ชจ๋์ ํฌํจํ  ์ ์์
  - ๋ฒ๋ค(Bundle): RedHat OpenShift <-- ์ญํ 

<br>

#### ์ญํ  ๋ชฉ๋ก ํ์ธ

- ์์คํ์ ์ค์น๋์ด์๋ ์ญํ ์ ๋ชฉ๋ก์ ๋ณด์ฌ์ค

```
ansible-galaxy list
```

- ์ฐพ๋ ์์

1. /home/vagrant/.ansible/roles
2. /usr/share/ansible/roles
3. /etc/ansible/roles

- ๋๋ ํ ๋ฆฌ ์ง์  ์ง์ ํด์ ํ์ธ ๊ฐ๋ฅ

```shell
$ ansible-galaxy list --roles-path roles
# /home/vagrant/10_role/roles
# /usr/share/ansible/roles
# /etc/ansible/roles
```

- ํน์  ํค์๋๋ก ๊ฒ์ ๊ฐ๋ฅ

```
ansible-galaxy search elasticsearch
```

- ๋ค๋ฅธ ์ฌ๋๋ค์ด ๋ง๋  ์ญํ ๋ค์ ์ค์นํด์ ์ฌ์ฉํ  ์ ์์

```
ansible-galaxy list --roles-path roles
```

- ์ญํ  ์ค์น, ๋ชฉ๋ก ํ์ธ, ์ ๊ฑฐ ๊ณผ์ 

```
ansible-galaxy search elasticsearch
ansible-galaxy info geerlingguy.elasticsearch
ansible-galaxy install geerlingguy.elasticsearch
ansible-galaxy remove geerlingguy.elasticsearch
```
