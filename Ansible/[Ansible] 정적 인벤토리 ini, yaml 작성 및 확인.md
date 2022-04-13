# [Ansible] 정적 인벤토리 ini, yaml 작성 및 확인



### 📌INDEX

- [정적 인벤토리](#정적-인벤토리)
-  [인벤토리 그룹](#인벤토리-그룹)
-  [호스트 범위](#호스트-범위)
- [인벤토리 변수](#인벤토리-변수)
- [인벤토리 파일 확인](#인벤토리-파일-확인)





## 정적 인벤토리

- [inventory 공식 문서](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#intro-inventory)

- 기본 인벤토리 파일: `/etc/ansible/hosts` -> 되도록이면 사용하지 않는다

- 기본 위치에 있는 인벤토리 파일 아니면: `-i` 옵션 사용

- 포맷: **ini**, yaml
  - 기본적으로 ini 사용
  - playbook은 yaml으로 생성해야함

- ini 형식 예시

```ini
key=value

[Section]
key=value
key
```

<br>

<br>

## 인벤토리 그룹

- `[ ]`: 인벤토리 그룹

- 하나의 노드가 여러 그룹에 속할 수 있음 => 1:1 매칭 관계는 아니다
- ansible 명령 시 ip주소 대신 그룹을 지정할 수 있음
  - inventory 파일에 정의되어 있어야함
- ini 예시

```ini
mail.example.com

[webservers]
foo.example.com
bar.example.com
three.example.com

[dbservers]
one.example.com
two.example.com
three.example.com
```

- yaml 예시

```yaml
all:
  hosts:
    mail.example.com:
  children:
    webservers:
      hosts:
        foo.example.com:
        bar.example.com:
    dbservers:
      hosts:
        one.example.com:
        two.example.com:
        three.example.com:
```

- 기본 그룹
  - all : 모든 호스트 노드를 가진 그룹
    - all은 무조건 존재하는 그룹
  - ungrouped : 그룹에 속해있지 않는 노드들의 그룹

- 그룹에 호스트를 분류
  - what
  - where
  - when
  - 그룹을 만들 때는 what, where, when을 고려

<br>

<br>

## 호스트 범위

유사한 패턴을 가진 호스트가 많은 경우 각 호스트 이름을 별도로 나열하는 대신 범위로 추가할 수 있음

- [공식 문서](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#adding-ranges-of-hosts)



예시

- 호스트 숫자의 범위를 지정할 수 있음

```ini
[webservers]
www[01:50].example.com
192.168.100.[10:19]
```

- 숫자 범위를 지정할 때, 증분값을 지정할 수 있음
  - 1부터 50까지 2씩 증가

```
[webservers]
www[01:50:2].example.com
```

- 알파벳 범위를 지정할 수 있음

```shell
[databases]
db-[a:f].example.com
```

<br>

<br>

## 인벤토리 변수

- 인벤토리 변수

```ini
[webservers]
www[01:50].example.com A=100 B=200
192.168.100.[10:19]
```

- 인벤토리 그룹 변수

```ini
[atlanta]
host1
host2

[atlanta:vars]
ntp_server=ntp.atlanta.example.com
proxy=proxy.atlanta.example.com
```

- 중첩 그룹
  - `children` 지시어가 있으면 거기에는 그룹만 들어와야함

```ini
[atlanta]
host1
host2

[raleigh]
host2
host3

[southeast:children]
atlanta
raleigh

[usa:children]
southeast
```

<br>

<br>

## 인벤토리 파일 확인

- 생성한 인벤토리 파일 계층 구조 확인
  - `@`가 붙어있는게 그룹, 안붙어있는게 호스트

```
ansible-inventory -i <INVENTORY_FILE> --graph
```

```
[vagrant@controller ~]$ ansible-inventory -i inventory.ini --graph
@all:
  |--@ungrouped:
  |  |--192.168.100.11
  |  |--192.168.100.12
[vagrant@controller ~]$ vi a.ini
[vagrant@controller ~]$ ansible-inventory -i a.ini --graph
@all:
  |--@alpha:
  |  |--@abc:
  |  |  |--b
  |  |  |--c
  |  |--@xyz:
  |  |  |--x
  |  |  |--y
  |  |  |--z
  |--@ungrouped:
  |  |--a
```

- JSON 형식 및 호스트/그룹 변수

```
ansible-inventory -i <INVENTORY_FILE> --list
```

- 호스트에 설정된 변수 확인

```
ansible-inventory -i <INVENTORY_FILE> --host <HOST>
```

- 호스트 매칭 확인(목록 보기)
  - [호스트 패턴](https://docs.ansible.com/ansible/latest/user_guide/intro_patterns.html)
  - 특정 그룹만 보는 것도 가능 : <HOST_PATTERN>에 그룹명

```
ansible <HOST_PATTERN> -i <INVENTORY_FILE> --list-hosts
```

```
ansible all -i a.ini --list-hosts
```

```
ansible abc -i a.ini --list-hosts
```

