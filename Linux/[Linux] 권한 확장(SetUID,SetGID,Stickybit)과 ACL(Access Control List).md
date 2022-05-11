<h2> [Linux] 권한 확장(SetUID,SetGID,Stickybit)과 ACL(Access Control List)



<h3>📌INDEX</h3>

- [확장된 권한(setuid, setgid, stickybit)](#확장된-권한)
-  [ACL(access control list)](#acl)
    - [getfacl](#getfacl)
    - [setfacl](#setfacl)
-  [ACL 실습(문제)](#acl-실습문제)



<br>

<br>

<h2>확장된 권한</h2>

- 권한 확장은 **실행권한이 있다는 전제**하에 진행된다.

- **⭐파일 권한과 디렉토리 권한은 분리되어있다⭐**

  - **파일을 읽는 것은 (상위 디렉토리 권한이 아니라) 파일 자체에 대한 권한**이다.
    - 즉, 디렉토리 내부의 파일 목록을 보는 것은 디렉토리의 읽기 권한이지만 디렉토리에 읽기 권한이 없어도, 디렉토리 내의 파일에 읽기 권한이 있으면 파일 내용을 볼 수 있다

- Special Permission 자세히 알아보기: https://nayoungs.tistory.com/68#c14

- 확장된 권한(Special Permission)의 종류

  - **Setuid** 

    - 파일의 **소유자 권한으로 명령어 실행**
    - 소유주가 root가 아닐 때에는 의미 없음
      - root가 아니면 어차피 일반 사용자이기 때문
    - 확장권한 설정 : `chmod u+s [파일명]` 또는 `chmod +4000 [파일명]`

  - **Setgid**

    - 파일의 **소유 그룹의 권한으로 명령어 실행**
    - 파일(file) : 파일의 소유 그룹 권한으로 실행
    - **디렉토리(directory)** : setgid 부여된 디렉토리 파일들에 대해서 소유 그룹이 계속해서 소유 그룹 권한을 행사함
      - 즉, **디렉토리의 setgid는 하위에 새로 만들어지는 디렉토리와 파일에 상속**된다
    - 확장권한 설정 : `chmod g+s [파일/디렉토리명]` 또는 `chmod +2000 [파일명/디렉토리명]`

  - **Stickybit**

    - **root와 소유자만 파일을 삭제**할 수 있도록 하는 것
    - 삭제 뿐만 아니라, **파일의 구조를 수정하지 못하도록, 변화가 생기지 않도록** 한다.
      - 따라서 삭제,이동,덮어쓰기와 같은 명령도 불가능 
    - ex) /tmp

    - 확장권한 설정: `chmod o+t [디렉토리명]` 또는 `chmod +1000 [디렉토리명]`

- 특수 권한은
  - 실행권한 있을 때 : 소문자로 표시 ex) s, t
  - 실행권한 없을 때 : 대문자로 표시 ex) S, T

- 확장된 권한(특수권한)의 효과(영향)



<img src="https://user-images.githubusercontent.com/64996121/155300791-a24de4af-9d96-4b09-844d-68a464efc239.PNG" width=400 height=150/>



- **setuid** 권한이 주어진 파일이나 디렉토리를 검색해보자

```shell
[root@localhost ~]# find / -perm -4000 2> /dev/null -ls
67305163   32 -rwsr-xr-x   1 root     root        32008  4월 11  2018 /usr/bin/fusermount
67499480   60 -rwsr-xr-x   1 root     root        61328  4월 11  2018 /usr/bin/ksu
67482413   28 -rwsr-xr-x   1 root     root        27832  6월 10  2014 /usr/bin/passwd
67684970   24 -rws--x--x   1 root     root        24048  4월 11  2018 /usr/bin/chfn
67684973   24 -rws--x--x   1 root     root        23960  4월 11  2018 /usr/bin/chsh
...
```

- **setgid** 권한이 주어진 파일이나 디렉토리를 검색해보자

```shell
[root@localhost ~]# find / -perm -2000 2> /dev/null -ls
  7574    0 drwxr-sr-x   3 root     systemd-journal       60  2월 23 09:00 /run/log/journal
  7575    0 drwxr-s---   2 root     systemd-journal       60  2월 23 09:00 /run/log/journal/bb9afee5d305ab46b7f34ffc7d08f145
67459857   16 -r-xr-sr-x   1 root     tty         15344  6월 10  2014 /usr/bin/wall
67685031   20 -rwxr-sr-x   1 root     tty         19624  4월 11  2018 /usr/bin/write
68074803   16 -rwxr-sr-x   1 root     cgred       15624  4월 11  2018 /usr/bin/cgclassify
...
```

- **stickybit** 권한이 주어진 파일이나 디렉토리를 검새해보자

```shell
[root@localhost ~]# find / -perm -1000 2> /dev/null -ls
  6955    0 drwxrwxrwt   2 root     root           40  2월 23 09:00 /dev/mqueue
  7049    0 drwxrwxrwt   2 root     root           40  2월 23 09:00 /dev/shm
100663361    4 drwxrwxrwt  23 root     root         4096  2월 23 09:01 /var/tmp
103058169    0 drwxrwxrwt   2 root     root            6  2월 22 11:16 /var/tmp/systemd-private-ca8550dc11894cada750e3a61c68f0e6-rtkit-daemon.service-DbByKE/tmp
103058170    0 drwxrwxrwt   2 root     root            6  2월 22 11:16 /var/tmp/systemd-private-ca8550dc11894cada750e3a61c68f0e6-chronyd.service-J00QdG/tmp
...
```



<br>

<br>

<h2>ACL</h2>

- 접근제어목록(Access Control List : ACL)은 권한이 없는 **사용자가 특정 파일에 접근하는 것을 허용하기 위한 방법**이다

- ACL은 특정 사용자, 특정 그룹의 구성원에게 **권한을 별도로 부여하기 위해 사용**한다

- ACL이  설정되지 않은, 일반적인 기본 권한의 경우에는 파일/디렉토리에 접근(access)할 때 **소유주 - 소유 그룹 - 기타 사용자** 순서로 권한을 확인한다
  - 이는 세분화가 불가능하다는 단점이 있다.
  - 특정사용자, 특정 그룹의 구성원에게 별도의 권한 부여 불가능
- **ACL**을 설정할 경우 **소유주 - 특정 사용자 - 소유 그룹 - 특정 그룹 - 기타 사용자** 순서로 권한을 확인한다

- 따라서 ACL의 영향을 받는 대상은 특정 사용자 소유 그룹, 특정 그룹이다

  - 소유주와 기타 사용자는 ACL(mask)의 영향을 받지 않는다

- acl 권한의 확인 방법

  - 아래의 예시처럼 **권한 옆(11번째 자리)에 + 기호**가 생긴다

  ```shell
  -rw-rw-r--+ 1 root root
  ```

  - 권한 옆에 +가 아닌, ' . ' 또는 공백이면 ACL이 설정되지 않았다는 것이다

- ACL이 설정되면 기존 **소유 그룹의 권한(8~10번)이 마스크(mask) 권한으로 대체**된다

- **ACL 엔트리: 항목 형식(acl_entries)**



<img src="https://user-images.githubusercontent.com/64996121/155300980-91e6cc3a-257e-43d6-a935-1936ec54c695.PNG" width=500 height=300/>



- mask의 권한은 acl 대상이 받을 수 있는 최대 권한으로, **acl 대상의 권한과 mask 권한을 and 연산**하여 결과가 나온다
- **일반 ACL과 기본(default) ACL**
  - **일반 ACL : ACL이 설정되어 있는 그 자체에 대해서 권한 행사**
  - 기본(default) ACL
    - 디렉토리에만 지정 가능 (필수 사항X)
    - 기본 acl이 설정되어 있는 디렉토리에 대해서는 아무런 권한을 행사할 수 없음
    - 대신 기본 acl이 설정되어있는 디렉토리에, 파일이나 디렉토리를 생성할 경우 기본  acl 설정이 생성 파일이나 디렉토리에 부여됨
      - 즉, 기본 acl이 설정된 현재 디렉토리가 아닌 **하위(파일,디렉토리)에 상속(부여)** 된다는 것이다
    - **생성된 디렉토리에는 기본 acl이 상속**된다



- <h4>getfacl</h4>

  - **Get F**ile **A**ccess **C**ontrol **L**ist 
  -  파일 또는 디렉토리의 **ACL 정보를 확인**하는 명령어
  - 마스크(mask)가 없으면 acl이 설정되지 않은 것이다
  - **getfacl [파일이름]**

  

  사용 예

  ```shell
  [root@localhost ~]# getfacl /ptest/dir01
  # file: ptest/dir01
  # owner: root
  # group: root
  user::---
  user:centos:rwx
  group::---
  mask::rwx
  other::---
  ```

  ```shell
  [root@localhost ~]# getfacl /ptest
  # file: ptest
  # owner: root
  # group: root
  user::rwx
  group::rwx
  other::rwx
  ```

  



- <h4>setfacl</h4>

  - **Set F**ile **A**ccess **C**ontrol **L**ist
  - 파일 또는 디렉토리의 ACL 정보를 설정하는 명령어
  - **setfacl [option] [acl entries] [파일명/디렉토리명]**
  - 옵션
    - -m : acl 설정(파일의 acl 항목 작성 및 수정)
    - -x : 해당 acl 엔트리 삭제
    - -b : acl 설정 초기화(모든 acl 설정 없앰, 파일 전체 acl 해제)
    - -k : default acl 설정 초기화(해제)

  

  사용 예

  -  dir01에 대해, centos 사용자가 읽기,쓰기,실행 권한(7)을 갖고, user01 그룹이 읽기,실행 권한(5)을 갖도록 acl을 설정해보자

    - 그룹 권한이 마스크(mask)로 대체된 것을 확인할 수 있다

    ```shell
    [root@localhost ptest]# getfacl dir01
    # file: dir01
    # owner: root
    # group: root
    user::---
    group::---
    other::---
    
    [root@localhost ptest]# setfacl -m u:centos:7,g:user01:5 dir01
    [root@localhost ptest]# getfacl dir01
    # file: dir01
    # owner: root
    # group: root
    user::---
    user:centos:rwx
    group::---
    group:user01:r-x
    mask::rwx
    other::---
    
    [root@localhost ptest]# ls -l
    합계 0
    d---rwx---+ 2 root root 6  2월 23 18:51 dir01
    ```

  -  dir01에서 centos 사용자에 대한 acl 설정을 삭제해보자

    ```shell
    [root@localhost ptest]# setfacl -x u:centos dir01
    [root@localhost ptest]# getfacl dir01
    # file: dir01
    # owner: root
    # group: root
    user::---
    group::---
    group:user01:r-x
    mask::r-x
    other::---
    ```

  - dir01에 설정된 acl을 모두 해제해보자

    ```shell
    [root@localhost ptest]# setfacl -b dir01
    [root@localhost ptest]# getfacl dir01
    # file: dir01
    # owner: root
    # group: root
    user::---
    group::---
    other::---
    ```

  

  

<br>

<br>

<h2>ACL 실습(문제)</h2>

1. user02를 aclgroup 구성원으로 넣어보자(사전 작업)

```shell
[root@localhost ptest]# useradd user02
[root@localhost ptest]# groupadd aclgroup
[root@localhost ptest]# usermod -G aclgroup user02
```

2. /ptest의 모든 내용을 삭제하고 777로 권한을 변경한 뒤 소유 그룹을 다시 root로 변경하자(사전 작업)

```
[root@localhost ~]# rm -rf /ptest
[root@localhost ~]# mkdir -m 777 /ptest
[root@localhost ~]# chown root: /ptest
```

3. **/ptest에 user03은 접근할 수 없도록 설정해보자**
   - getfacl 로 확인

```shell
[root@localhost ~]# setfacl -m u:user03:0 /ptest
[root@localhost ~]# getfacl /ptest
# file: ptest
# owner: root
# group: root
user::rwx
user:user03:---
group::rwx
mask::rwx
other::rwx
```

4. /ptest에 파일 aclfile01과 디렉토리 acldir01을 생성해보자(사전 작업)

```
[root@localhost ~]# touch /ptest/aclfile01
[root@localhost ~]# mkdir /ptest/acldir01
```

5. **aclfile01은 user01 만이 읽기, 쓰기, 실행이 가능하도록 설정하고 나머지는 읽기, 쓰기만 실행가능하도록 설정해보자**

```shell
[root@localhost ~]# chmod 666 /ptest/aclfile01
[root@localhost ~]# setfacl -m u:user01:7 /ptest/aclfile01
[root@localhost ~]# getfacl /ptest/aclfile01
# file: ptest/aclfile01
# owner: root
# group: root
user::rw-
user:user01:rwx
group::rw-
mask::rwx
other::rw-
```

6. **⭐acldir01은 aclgroup 만이 읽기, 쓰기가 가능하도록하고 나머지는 읽기만 가능하도록 설정해보자⭐**
   - 나머지가 읽기만 가능하도록 하려면 권한을 4(r)로 설정해야할 것 같지만, **디렉토리 이므로 읽기가 가능하려면(접근하려면) 실행 권한이 있어야한다**. 따라서 5(r+x) 로 권한을 설정
   - 디렉토리의 읽기,쓰기가 가능하게하려는 aclgroup에도 실행권한이 있어야하기 때문에, aclgroup에 권한을 7(r+w+x)로 설정

```
[root@localhost ~]# chmod 555 /ptest/acldir01
[root@localhost ~]# setfacl -m g:aclgroup:7 /ptest/acldir01
[root@localhost ~]# getfacl /ptest/acldir01
# file: ptest/acldir01
# owner: root
# group: root
user::r-x
group::r-x
group:aclgroup:rwx
mask::rwx
other::r-x
```

