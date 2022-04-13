# [Ansible] Ansible 명령어 옵션



### 📌INDEX

- [Ansible 옵션](#ansible-옵션)
- [ansible-config 명령](#ansible-config-명령)
- [모듈](#모듈)
- [ad-hoc 명령](#ad-hoc-명령)

<br>

<br>

## Ansible 옵션

**SSH 접속 옵션**

-  -u REMOTE_USER, --user REMOTE_USER : SSH 접속 계정(기본: 현재 사용자)
-  -k, --ask-pass : 옵션 사용 SSH 패스워드 인증
	- 옵션 사용하지 않으면 --> SSH 키 인증

> ansible의 기본 인증 방법: SSH 키 인증



**권한 상승 옵션**

- -b, --become : 권한 상승
	- 옵션 사용하지 않으면 --> 권한상승 하지 않음
- --become-method <sudo|su>
	- sudo: 기본값
	- su
- --become-user : 어떤 사용자?
	- root: 기본값
- -K, --ask-become-pass : sudo 패스워드 묻기
	- 옵션 사용하지 않으면 --> Passwordless sudo



**설정 파일**

- [설정 파일](https://nayoungs.tistory.com/121#%E-%-C%--%EF%B-%-F%--%EA%B-%AC%EC%--%B-%--%ED%-C%-C%EC%-D%BC)로 설정하기

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

## ansible-config 명령

- `ansible-config` 명령으로 설정 파일을 검증, 확인할 수 있음
- 해당 명령으로 디버깅도 가능



**`ansible-config list`  **

- 설정 가능한 모든 항목 표시

- [문서]([Ansible Configuration Settings — Ansible Documentation](https://docs.ansible.com/ansible/latest/reference_appendices/config.html))랑 동일한 내용



**`ansible-config dump`**

- 모든 설정의 기본 값 및 변경 값 표시(항목 확인)
- 초록색 : 이상 없고 변경 사항 없을 때
- 노란색 : 변경 되었을 때
- 빨간색 : 실행이 안되었을 때, 문제가 있을 때



**`ansible-config view`** 

- 현재 적용되는 설정 파일의 내용 표시

```shell
[vagrant@controller ~]$ ansible-config view
[defaults]
inventory=./inventory.ini
```

<br>

<br>

## 모듈

- [모듈 목록 확인](https://docs.ansible.com/ansible/2.9/modules/modules_by_category.html)

- 모듈 목록 

```
ansible-doc -l
```

- 모듈 상세 정보

```
ansible-doc <MODULE_NAME>
```

<br>

<br>

## ad-hoc 명령

```
ansible <HOST_PATTERN> -m <MODULE> -a <PARAMETER>
```

- 호스트 패턴을 지정할 수 있음

- 정규화 표현식 지정 가능

- [패턴 확인]([Patterns: targeting hosts and groups — Ansible Documentation](https://docs.ansible.com/ansible/latest/user_guide/intro_patterns.html))

- 메타문자를 사용할 때는 홑 따옴표(')로 감싸주기



예시

- 아래 인벤토리 파일로 진행

```
[vagrant@controller ~]$ cat inventory.ini
192.168.100.11
192.168.100.12

[web]
weba
webb

[db]
weba
dba
dbb
```

```
[vagrant@controller ~]$ ansible '192.168.100.*' --list-hosts
  hosts (2):
    192.168.100.11
    192.168.100.12
```

```
[vagrant@controller ~]$ ansible 192.168.100.11,192.168.100.12 --list-hosts
  hosts (2):
    192.168.100.11
    192.168.100.12
```

- 합집합

```
[vagrant@controller ~]$ ansible web:db --list-hosts 
  hosts (4):
    weba
    webb
    dba
    dbb
```

- 교집합

```
[vagrant@controller ~]$ ansible 'web:&db' --list-hosts 
  hosts (1):
    weba
```

- 차집합

```null
[vagrant@controller ~]$ ansible 'web:!db' --list-hosts
  hosts (1):
    webb
```



but, 패턴은 문제 발생 소지가 있으므로 되도록이면 사용하지 않는 것이 좋음

교집합과 같은 경우도 차라리 그룹을 새로 생성하는 것이 좋음



