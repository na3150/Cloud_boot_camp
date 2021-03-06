# [Ansible] Ansible Vault

<br>

### ðINDEX

- [Ansible Vaultë?](#ansible-vaultë)
- [ansible-vault ëªë ¹](#ansible-vault-ëªë ¹)
- [vault password file](#vault-password-file)
- [ë©í° í¨ì¤ìë](#ë©í°-í¨ì¤ìë)

<br>

<br>

## Ansible Vaultë?

- **ë°ì´í°ë¥¼ ìì íê² ë³´ê´íê¸° ìí ê¸°ì **(ìí¸í)

- íì¼, ì¼ë¶ íì¤í¸ë¥¼ ìí¸í

  - íì¼ ìì¤
    - íë ì´ë¶
    - **ë³ì íì¼**(group_vars, host_vars ë±)
    - include/import ìì íì¼

  - íì¤í¸ ìì¤
    - ë³ìì ê°

- Vault Password : AES(ëì¹­í¤) ìê³ ë¦¬ì¦ ì¬ì©

- ë¨ì¼ í¨ì¤ìë
	- --ask-vault-pass
	- --vault-password-file
- ë©í° í¨ì¤ìë
	- --vault-id

<br>

<br>

## ansible-vault ëªë ¹
```
ansible-vault <SUB-COMMAND> <FILE>
```

- SUB-COMMAND
  - create: ìí¸íë  ë¹ íì¼ ìì±
  - decrypt: ìí¸íë íì¼ ë³µí¸í
  - edit: ìí¸íë íì¼ ìì (vi)
  - view: ìí¸íë íì¼ íì¸
  - encrypt: íë¬¸ íì¼ ìí¸í
  - rekey: Vault í¨ì¤ìë ë³ê²½
  - encrypt_string: íì¤í¸ ìí¸í
- Option
  - `--ask-vault-password`: ê¸°ë³¸ ìµì(Vault í¨ì¤ìë ë¬¼ì)
  - `--vault-password-file`: Vault í¨ì¤ìë íì¼ ì§ì 

<br>

ìì

#### create

íì¼ ìì±

- `create`ë¡ ë¹ íì¼ ìì± í ì ì¥íê³  ëì¤ë©´ ìí¸íë¨
- ê¸°ë³¸ìëí° : `vi`

```shell
[vagrant@controller 11_vault]$ ansible-vault create encrypt.yaml
New Vault password: 
Confirm New Vault password: 
```

<br>

#### view

ë´ì© íì¸íê¸°

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

ë´ì©  í¸ì§íê¸°

```shell
[vagrant@controller 11_vault]$ ansible-vault edit encrypt.yaml 
Vault password:
```

<br>

#### decrypt

ìí¸í í´ì íê¸°

- `cat` ëªë ¹ì´ë¡ íì¸í  ì ìê²ë¨

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

- ë¤ì ìí¸ííê¸°

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

- í¤ ë¤ììì±íê¸°

```shell
[vagrant@controller 11_vault]$ ansible-vault rekey encrypt.yaml 
Vault password: 
New Vault password: 
Confirm New Vault password: 
Rekey successful
```

<br>

#### encrypt_string

ì¼ë¶ íì¤í¸ë§ ìí¸ííê¸°

```shell
ansible-vault encrypt_string
```
test.yaml : ë³ì`message`ì ê°ì ìí¸íí  ìì 

```
- hosts: 192.168.100.11
  vars:
    message: hello world

  tasks:
    - debug:
        msg: "{{ message }}"  
```

ìí¸íí  íì¤í¸(hello world) ìë ¥ í `ctrl+d` 2ë² í¹ì `enter ì¹ê³  ctrl+d`

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

`!vault`ë¶í° ë³µì¬í´ì `hello world`ì ë¶ì¬ë£ê¸°

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

playbook ì¤í : hello message íì¸

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

#### ìí¸íë íë ì´ë¶ ì¤í

- ìí¸íë íë ì´ë¶ì ì¤íìë¨ : `Attempting to decrypt but no vault secrets found`
- `--ask-vault-pass` ìµìì ì¬ì©íì¬ ì§ì  ìë ¥

```
ansible-playbook <Playbook> --ask-vault-pass
```

- `--ask-vault-file` ìµìì ì¬ì©íì¬ í¨ì¤ìë íì¼ ì§ì 

```
ansible-playbook <Playbook> --vault-password-file <Vault_Password_File>
```

=> ìµìì ì¬ì©íì¬ ì§ì íëê²ì´ ê·ì°®ë¤ë©´ ìëì `vault password file`ì¬ì©

<br>

<br>

<br>

## vault password file

ë§¤ë² ë¹ë°ë²í¸ë¥¼ ìë ¥íì§ ìê³ , **íì¼ì ë¹ë°ë²í¸ ì ì¥í´ë ë¤ ì¬ì©**í  ì ìì



ìì

- `vaultpass`íì¼ì í¨ì¤ìë ì ì¥

```
[vagrant@controller 11_vault]$ echo "P@ssw0rd" > vaultpass
```

- **create** : `--vault-password-file`ìµìì¼ë¡ í¨ì¤ìë íì¼ `vaultpass`ì§ì 

```
[vagrant@controller 11_vault]$ ansible-vault create a.yaml --vault-password-file vaultpass
```

- **view** :  `--vault-password-file`ìµìì¼ë¡ í¨ì¤ìë íì¼ `vaultpass`ì§ì 

```
[vagrant@controller 11_vault]$ ansible-vault view a.yaml --vault-password-file vaultpass
- hosts: 192.168.100.11
  tasks:
   - debug:
```

- í¤ íì¼ ë³ê²½íê¸° : **`--new-vault-password-file`**

```
[vagrant@controller 11_vault]$ ansible-vault rekey a.yaml --vault-password-file vaultpass --new-vault-password-file newvaultpass
Rekey successful
```

ì£¼ì) ë¤ë¥¸ ì¬ì©ìê° í ëë í ë¦¬ì ì ê·¼í  ì ìë¤ë ê²ì´ ë³´ì¥ëë¤ë©´ í¤ íì¼ ì¬ì© ê´ì°®ì¼ë, ê·¸ë ì§ ìë¤ë©´ ë¹ë°ë²í¸ë¥¼ ì¬ì©íë ê²ì´ ë³´ìì ë ëì ìë ìì

<br>

#### ansible ì¤ì  íì¼ì ì ìíê¸°

- ìµì ìì´ `encrypt`, `view`, `decript` ê°ë¥
- ìí¸íë playbook ì¤íììë ìëì¼ë¡ `ask-vault-pass`í¨ => í¸ë¦¬
- ê·¸ë¬ë í­ì ëì¼í í¨ì¤ìëë¥¼ ì¬ì©íë¤ë ë¬¸ì ê° ìì

<br>

ë°©ë²1 : í¨ì¤ìë íì¼ ë°ë¡ ì§ì íê¸°

```shell
[vagrant@controller 11_vault]$ vim ansible.cfg
```

```shell
[vagrant@controller 11_vault]$ cat ansible.cfg 
[defaults]
vault_password_file=vaultpass
```

<br>

ë°©ë²2 : ì¨ê¹ íì¼ë¡ ì¤ì 

ansible ì¤ì  íì¼ì ë°ë¡ íì¼ì ì§ì íë ê²(ë°©ë²1)ë³´ë¤ ë°©ë²2ê° ë ìì í¨

- **.**[file]  => íì¼ëª ìì `.`ì´ ë¶ì´ìì¼ë©´ ì¨ê¹ íì¼ì

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

## ë©í° í¨ì¤ìë

ë¤ë¥¸ í¨ì¤ìëë¡ ìì±í íê°ì playbook íì¼ì ì¤íí  ë°©ë²ì´ ìì

=> solution :  ë©í° í¨ì¤ìë ë°©ë² ì¬ì©

- ë³ëë¡ í¨ì¤ìëë¥¼ ìë ¥í´ì ë³µí¸í

- IDë¡ êµ¬ë³í´ì ë¤ë¥¸ í¨ì¤ìëë¥¼ ì¬ì©í  ì ìê² ë§ë¤ì´ì£¼ë ê²
- `--vault-id `ìµì ì¬ì©
- `--vault-id ID@source`
  - source
    - **prompt**: í¨ì¤ìëë¥¼ ëíìì íë¡¬íí¸
      - --vault-id user1@prompt
    - **file**: íì¼ìì í¨ì¤ìëë¥¼ ì°¸ì¡°
      - --vault-id user2@.vaultpass
    - **script**: í¨ì¤ìëë¥¼ ì°¸ì¡°í  ì ìë ì¤í¬ë¦½í¸
      - ì:  í¨ì¤ìëë MySQL ì ì¥, python ì½ëë¡ DBìì í¨ì¤ìëë¥¼ ê°ì ¸ì¬ ì ìë
      - --vault-id user3@getpass.py

<br>

ì°¸ê³ ) ansible ì¤ì íì¼ì `vault-password-file` ì ìëì´ìì¼ë©´ ìë¨

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

- ë³ëì ë³ì íì¼ ìì± í ê°ê° `--vault-id` ìµìì¼ë¡ ìí¸í

```
echo "message1: hello" > var1.yaml
echo "message2: world" > var2.yaml
```

```
ansible-vault encrypt var1.yaml --vault-id user1@prompt
ansible-vault encrypt var2.yaml --vault-id user2@prompt
```

- `--vault-id` ìµìì ì¬ì©íì¬ íë ì´ë¶ ì¤í
  - user1, user2 ê°ê° í¨ì¤ìë ìë ¥

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

- ë³ëì ë³ì íì¼ ìì±

```
echo "message1: hello" > var1.yaml
echo "message2: world" > var2.yaml
```

- ë³ëì í¨ì¤ìë íì¼ `user1pass`, `user2pass` ìì± ë° ê¶í ì¤ì 

```
echo "P@ssw0rd1" > user1pass
echo "P@ssw0rd2" > user2pass
chmod 600 user1pass 
chmod 600 user2pass 
```

- ê°ê° `--vault-id` ìµìì¼ë¡ ìí¸í

```
ansible-vault encrypt var1.yaml --vault-id user1@user1pass
ansible-vault encrypt var2.yaml --vault-id user1@user2pass
```

- `--vault-id` ìµìì ì¬ì©íì¬ íë ì´ë¶ ë°ë¡ ì¤í

```
ansible-playbook test.yaml --vault-id user1@user1pass --vault-id user1@user2pass
```

<br>

#### ìì íê³  í¸íê² vault ë©í° í¨ì¤ìëë¥¼ ì¬ì©íë ë°©ë²

ansibleì¤ì  íì¼ì`vault-identity-list` ì¤ì 

<br>

`ansible.cfg`

- `[id]@[í¨ì¤ìë íì¼]` ì ì½¤ë§ë¥¼ ì´ì©í´ì ë¦¬ì¤í¸ë¡ ì§ì 

```
[defaults]
vault_identity_list = user1@user1pass, user2@user2pass
```

ë³µí¸í

- ë³ëë¡ ìµì ì§ì íì§ ììë ë°ë¡ ë³¼ ì ìê³ , ì¤íí  ì ìì

- ìì´ëë¥¼ ì§ì íì§ ììë ììì ì°¾ìì ë³µí¸íí´ì¤

```
ansible-vault view var2.yaml
ansible-playbook test.yaml
```

ìí¸í

- encrypt(ìí¸í) í  ëë ë°ëì idë¥¼ ì§ì í´ì¤ì¼í¨

```
ansible-vault create var3.yaml --encrypt-vault-id user1
absible-vault encrypt var3.yaml --encrypt-vault-id user1
```
