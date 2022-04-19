# [Ansible] Template 주석: ansible_managed



## 템플릿 주석

관습적으로 파일 앞에 주석 붙여놓음 => **경고의 목적**

- 예시

```
#이 파일은 Ansible에 의해 만들어 졌습니다.
#직접 수정하지 마세요.
```

- 기법을 사용해서 수정 가능 
  - **`Ansible managed`** : Ansible이 관리하고 있는 파일이라는 뜻. 직접 수정하지 않도록 사용자에게 경고를 줌
  - 어떤 값을 넣을지는 사용자가 설정할 수 있음
  - 일반적으로 ansible 설정 파일에 선언

`ansible.cfg`

- 언제, 어떤 시스템(호스트)에서, 어떤 사용자(uid)에 의해 만들어졌는지 남게됨

```yaml
[defaults]
ansible_managed = Ansible managed: {file} modified on %Y-%m-%d %H:%M:%S by {uid} on {host}
```

`templates/port.cnf.j2`

- `comment`필터를 사용하여 앞에 주석을 만들어줌 : 필터를 사용하지 않으면 글자가 그냥 값으로 들어감

```jinja2
{{ ansible_managed | comment }}
[mysqld]
port={{ database["svc_port"] }}
```

<br>

<br>

#### ▫️ 기타 참고사항

1. ansible 참조하기 좋은 github 주소

- [one](https://github.com/sovereign/sovereign)

- [two](https://github.com/ansible/ansible-examples)
- [three](https://github.com/kubernetes-sigs/kubespray)

2. 관습적으로 `site.yaml` 이 메인 yaml 파일

3. `lineinfile` 모듈

- `insertbefore`, `insertafter` : 앞 또는 뒤에 라인 추가(삽입)
  - but 파일에 계속 한문장씩 추가되므로 꼬일 수 있음(좋지 않음)

4. **추가 설정파일**

- 추가 설정파일로 추가 구성을 간편하게 할 수 있음
- httpd의 설정파일은  `/etc/httpd/conf/httpd.conf`이고, `/etc/httpd/conf.d` 에 추가 설정파일을 넣어둘 수 있음
- `[~].d` 는 일반적으로 추가 설정(구성)파일
  - 예시
    - /etc/my.cnf.d
    - /etc/sudoers.d

- 수정 후에는 시스템 재시작할 것
