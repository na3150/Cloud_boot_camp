# [Ansible] Ansible Vault

<br>

### 📌INDEX

- [Ansible Vault란?](#ansible-vault란)
- [ansible-vault 명령](#ansible-vault-명령)
- [vault password file](#vault-password-file)
- [멀티 패스워드](#멀티-패스워드)

<br>

<br>

## Ansible Vault란?

- **데이터를 안전하게 보관하기 위한 기술**(암호화)

- 파일, 일부 텍스트를 암호화

  - 파일 수준
    - 플레이북
    - **변수 파일**(group_vars, host_vars 등)
    - include/import 작업 파일

  - 텍스트 수준
    - 변수의 값

- Vault Password : AES(대칭키) 알고리즘 사용

- 단일 패스워드
	- --ask-vault-pass
	- --vault-password-file
- 멀티 패스워드
	- --vault-id

<br>

<br>

## ansible-vault 명령
```
ansible-vault <SUB-COMMAND> <FILE>
```

- SUB-COMMAND
  - create: 암호화될 빈 파일 생성
  - decrypt: 암호화된 파일 복호화
  - edit: 암호화된 파일 수정(vi)
  - view: 암호화된 파일 확인
  - encrypt: 평문 파일 암호화
  - rekey: Vault 패스워드 변경
  - encrypt_string: 텍스트 암호화
- Option
  - `--ask-vault-password`: 기본 옵션(Vault 패스워드 물음)
  - `--vault-password-file`: Vault 패스워드 파일 지정

<br>

예시

#### create

파일 생성

- `create`로 빈 파일 생성 후 저장하고 나오면 암호화됨
- 기본에디터 : `vi`

```shell
[vagrant@controller 11_vault]$ ansible-vault create encrypt.yaml
New Vault password: 
Confirm New Vault password: 
```

<br>

#### view

내용 확인하기

```shell
[vagrant@controller 11_vault]$ ansible-vault view encrypt.yaml 
Vault password: 
- hosts: 192.168.100.11
  tasks:
     debug:
       msg: "hello world"
```

<br>

#### edit

내용  편집하기

```shell
[vagrant@controller 11_vault]$ ansible-vault edit encrypt.yaml 
Vault password:
```

<br>

#### decrypt

암호화 해제하기

- `cat` 명령어로 확인할 수 있게됨

```shell
[vagrant@controller 11_vault]$ ansible-vault decrypt encrypt.yaml 
Vault password: 
Decryption successful
```

```shell
[vagrant@controller 11_vault]$ cat encrypt.yaml 
- hosts: 192.168.100.11
  tasks:
     debug:
       msg: "hello world"
```

- 다시 암호화하기

```shell
[vagrant@controller 11_vault]$ ansible-vault encrypt encrypt.yaml 
New Vault password: 
Confirm New Vault password: 
Encryption successful
```

```shell
[vagrant@controller 11_vault]$ cat encrypt.yaml 
$ANSIBLE_VAULT;1.1;AES256
30643937396630316630303162373231383139393735376664343232333339376263656563613838
3262343361353361626564313533313965626439303339640a393861343663333263633535356538
63336232353533663462646239303235623564316636663161333230653731313963316561303436
6365613466346239610a366538336462386364613864303361643535333332393232336461633036
66646365666332353638613061313935346639373664623935376163333632333732323332626166
38663535313437303031626335613830343465656231303533383739383638306236303132333538
35346363623239363764633636326134313165353661306339666334353864663563633038356230
33343131373438656431
```

<br>

#### rekey

- 키 다시생성하기

```shell
[vagrant@controller 11_vault]$ ansible-vault rekey encrypt.yaml 
Vault password: 
New Vault password: 
Confirm New Vault password: 
Rekey successful
```

<br>

#### encrypt_string

일부 텍스트만 암호화하기

```shell
ansible-vault encrypt_string
```
test.yaml : 변수`message`의 값을 암호화할 예정

```
- hosts: 192.168.100.11
  vars:
    message: hello world

  tasks:
    - debug:
        msg: "{{ message }}"  
```

암호화할 텍스트(hello world) 입력 후 `ctrl+d` 2번 혹은 `enter 치고 ctrl+d`

```shell
[vagrant@controller 11_vault]$ ansible-vault encrypt_string
Reading plaintext input from stdin. (ctrl-d to end input)
hello world!vault |
          $ANSIBLE_VAULT;1.1;AES256
          33386136623736613266656666303736623131313333383162653134613063313462346433383036
          3466323031303738303633353964333631383963633563390a373133313636386637333032383430
          63653366643032386165323732636439383031646162366665656632633339643961373536666264
          6265623966343063340a636635373564623062393362396239363533336461666661313432326637
          6337
Encryption successful
```

`!vault`부터 복사해서 `hello world`에 붙여넣기

```
- hosts: 192.168.100.11
  vars:
    message: !vault |
          $ANSIBLE_VAULT;1.1;AES256
          33386136623736613266656666303736623131313333383162653134613063313462346433383036
          3466323031303738303633353964333631383963633563390a373133313636386637333032383430
          63653366643032386165323732636439383031646162366665656632633339643961373536666264
          6265623966343063340a636635373564623062393362396239363533336461666661313432326637
          6337

  tasks:
    - debug:
        msg: "{{ message }}"  
```

playbook 실행 : hello message 확인

```
[vagrant@controller 11_vault]$ ansible-playbook test.yaml 

PLAY [192.168.100.11] *******************************************************************

TASK [Gathering Facts] ******************************************************************
ok: [192.168.100.11]

TASK [debug] ****************************************************************************
ok: [192.168.100.11] => {
    "msg": "hello world"
}

PLAY RECAP ******************************************************************************
192.168.100.11             : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

<br>

<br>

#### 암호화된 플레이북 실행

- 암호화된 플레이북은 실행안됨 : `Attempting to decrypt but no vault secrets found`
- `--ask-vault-pass` 옵션을 사용하여 직접 입력

```
ansible-playbook <Playbook> --ask-vault-pass
```

- `--ask-vault-file` 옵션을 사용하여 패스워드 파일 지정

```
ansible-playbook <Playbook> --vault-password-file <Vault_Password_File>
```

=> 옵션을 사용하여 지정하는것이 귀찮다면 아래의 `vault password file`사용

<br>

<br>

<br>

## vault password file

매번 비밀번호를 입력하지 않고, **파일에 비밀번호 저장해둔 뒤 사용**할 수 있음



예시

- `vaultpass`파일에 패스워드 저장

```
[vagrant@controller 11_vault]$ echo "P@ssw0rd" > vaultpass
```

- **create** : `--vault-password-file`옵션으로 패스워드 파일 `vaultpass`지정

```
[vagrant@controller 11_vault]$ ansible-vault create a.yaml --vault-password-file vaultpass
```

- **view** :  `--vault-password-file`옵션으로 패스워드 파일 `vaultpass`지정

```
[vagrant@controller 11_vault]$ ansible-vault view a.yaml --vault-password-file vaultpass
- hosts: 192.168.100.11
  tasks:
   - debug:
```

- 키 파일 변경하기 : **`--new-vault-password-file`**

```
[vagrant@controller 11_vault]$ ansible-vault rekey a.yaml --vault-password-file vaultpass --new-vault-password-file newvaultpass
Rekey successful
```

주의) 다른 사용자가 홈 디렉토리에 접근할 수 없다는 것이 보장된다면 키 파일 사용 괜찮으나, 그렇지 않다면 비밀번호를 사용하는 것이 보안상 더 나을 수도 있음

<br>

#### ansible 설정 파일에 정의하기

- 옵션 없이 `encrypt`, `view`, `decript` 가능
- 암호화된 playbook 실행시에도 자동으로 `ask-vault-pass`함 => 편리
- 그러나 항상 동일한 패스워드를 사용한다는 문제가 있음

<br>

방법1 : 패스워드 파일 바로 지정하기

```shell
[vagrant@controller 11_vault]$ vim ansible.cfg
```

```shell
[vagrant@controller 11_vault]$ cat ansible.cfg 
[defaults]
vault_password_file=vaultpass
```

<br>

방법2 : 숨김 파일로 설정

ansible 설정 파일에 바로 파일을 지정하는 것(방법1)보다 방법2가 더 안전함

- **.**[file]  => 파일명 앞에 `.`이 붙어있으면 숨김 파일임

```shell
[vagrant@controller 11_vault]$ cat ansible.cfg 
[defaults]
vault_password_file=./.vaultpass
```

```shell
[vagrant@controller 11_vault]$ vim .vaultpass
[vagrant@controller 11_vault]$ chmod 600 .vaultpass 
```

```shell
[vagrant@controller 11_vault]$ cat ansible.cfg 
[defaults]
vault_password_file=./.vaultpass
```

<br>

<br>

## 멀티 패스워드

다른 패스워드로 생성한 한개의 playbook 파일은 실행할 방법이 없음

=> solution :  멀티 패스워드 방법 사용

- 별도로 패스워드를 입력해서 복호화

- ID로 구별해서 다른 패스워드를 사용할 수 있게 만들어주는 것
- `--vault-id `옵션 사용
- `--vault-id ID@source`
  - source
    - **prompt**: 패스워드를 대화식의 프롬프트
      - --vault-id user1@prompt
    - **file**: 파일에서 패스워드를 참조
      - --vault-id user2@.vaultpass
    - **script**: 패스워드를 참조할 수 있는 스크립트
      - 예:  패스워드는 MySQL 저장, python 코드로 DB에서 패스워드를 가져올 수 있는
      - --vault-id user3@getpass.py

<br>

참고) ansible 설정파일에 `vault-password-file` 정의되어있으면 안됨

<br>

#### prompt

`test.yaml`

```
- hosts: 192.168.100.11
  vars_files:
    - var1.yaml
    - var2.yaml
  tasks:
    - debug:
        msg: "{{ message1 }} {{ message2 }}"
```

- 별도의 변수 파일 생성 후 각각 `--vault-id` 옵션으로 암호화

```
echo "message1: hello" > var1.yaml
echo "message2: world" > var2.yaml
```

```
ansible-vault encrypt var1.yaml --vault-id user1@prompt
ansible-vault encrypt var2.yaml --vault-id user2@prompt
```

- `--vault-id` 옵션을 사용하여 플레이북 실행
  - user1, user2 각각 패스워드 입력

```
ansible-playbook test.yaml --vault-id user1@prompt --vault-id user2@prompt
```

```shell
[vagrant@controller 11_vault]$ ansible-playbook test.yaml --vault-id user1@prompt --vault-id user2@prompt
Vault password (user1): 
Vault password (user2): 

PLAY [192.168.100.11] **********************************************************

TASK [Gathering Facts] *********************************************************
ok: [192.168.100.11]

TASK [debug] *******************************************************************
ok: [192.168.100.11] => {
    "msg": "hello world"
}

PLAY RECAP *********************************************************************
192.168.100.11             : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
```

<br>

#### vault file

- 별도의 변수 파일 생성

```
echo "message1: hello" > var1.yaml
echo "message2: world" > var2.yaml
```

- 별도의 패스워드 파일 `user1pass`, `user2pass` 생성 및 권한 설정

```
echo "P@ssw0rd1" > user1pass
echo "P@ssw0rd2" > user2pass
chmod 600 user1pass 
chmod 600 user2pass 
```

- 각각 `--vault-id` 옵션으로 암호화

```
ansible-vault encrypt var1.yaml --vault-id user1@user1pass
ansible-vault encrypt var2.yaml --vault-id user1@user2pass
```

- `--vault-id` 옵션을 사용하여 플레이북 바로 실행

```
ansible-playbook test.yaml --vault-id user1@user1pass --vault-id user1@user2pass
```

<br>

#### 안전하고 편하게 vault 멀티 패스워드를 사용하는 방법

ansible설정 파일에`vault-identity-list` 설정

<br>

`ansible.cfg`

- `[id]@[패스워드 파일]` 을 콤마를 이용해서 리스트로 지정

```
[defaults]
vault_identity_list = user1@user1pass, user2@user2pass
```

복호화

- 별도로 옵션 지정하지 않아도 바로 볼 수 있고, 실행할 수 있음

- 아이디를 지정하지 않아도 알아서 찾아서 복호화해줌

```
ansible-vault view var2.yaml
ansible-playbook test.yaml
```

암호화

- encrypt(암호화) 할 때는 반드시 id를 지정해줘야함

```
ansible-vault create var3.yaml --encrypt-vault-id user1
absible-vault encrypt var3.yaml --encrypt-vault-id user1
```
