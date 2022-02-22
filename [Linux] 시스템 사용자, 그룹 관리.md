<h1> [Linux] 시스템 사용자, 그룹 관리</h1>



<h3>📌INDEX</h3>

- [계정 관련 파일들](#계정-관련-파일들)
-  [사용자](#사용자)
-  [/etc/passwd](#etcpasswd)
-  [/etc/shadow](#etcshadow)
- [사용자 전환](#사용자-전환)
  - [관리자 권한 사용](#관리자-권한-사용)
- [사용자 관리](#사용자-관리)
  - [사용자 생성](#사용자-생성)
  - [사용자 수정](#사용자-수정)
  - [사용자 삭제](#사용자-삭제)

- [그룹 관리](#그룹-관리)
  - [그룹 생성](#그룹-생성)
  - [그룹 수정](#그룹-수정)
  - [그룹 삭제](#그룹-삭제)
- [패스워드(password) 관리](#패스워드password-관리)
  - [chage](#chage)

<br>

<br>

<h2>계정 관련 파일들</h2>

- **/etc/passwd** : **사용자 정보**를 담고 있는 기본 파일
- **/etc/shadow** : 사용자의 **암호화된 패스워드**를 담고 있는 파일
- **/etc/group** : 사용 **그룹의 정보**를 담고 있는 파일
- **/etc/gshadow** : **그룹의 암호 정보** 담고 있는 파일
- **/home** : 사용자 별** 홈 디렉토리가 생성되는 기본**
- **/etc/login.defs , /etc/default/useradd , /etc/skel** : 계정 생성 시 참고하는 **기본설정 정보**



<br>

<br>

<h2>사용자</h2>

- 시스템 사용 주체

- 파일 소유주

- 모든 실행 및 접근 권한의 1차적 기준

- 일반 유저, 시스템 유저, 슈퍼 유저로 구분

- **슈퍼 유저** 

  - root 사용자
  - UID 0번
  - 시스템 관리 권한
  - 고정 하드 드라이브 관리 가능

- **일반 유저**

  - 부여된 권한에 따른 명령어 실행 및 파일 접근 가능
  - 이동식 장치 제어 가능
  - 일반적으로 UID 1000번 부터 할ㄹ당

- UID 범위

  - 0번 : 슈퍼 유저(root)에 할당
  - 1~200 번: 정적 할당된 시스템 사용자
  - 201 ~999번: 파일을 소유하지 않은 시스템 사용자

- **/etc/passwd 파일에 정보 저장**

- 사용자 정보 확인 명령어

  - **id** : 현재 사용자의 정보 출력

  ```shell
  [root@localhost ~]# id
  uid=0(root) gid=0(root) groups=0(root) context=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023
  ```

  - **who** : 접속 중인 사용자 목록

  ```shell
  [root@localhost ~]# who
  root     tty2         2022-02-22 12:10
  root     pts/0        2022-02-22 12:10 
  ```

  - **whoami** : 현재 사용자 이름

  ```shell
  [root@localhost ~]# whoami
  root
  ```

  - **who am i** : 접속 사용자 이름

  ```shell
  [root@localhost ~]# who am i
  root     pts/0        2022-02-22 12:10 
  ```

  

<br>

<br>

<h2>/etc/passwd</h2>

- 사용자 정보는 /etc/passwd에 저장됨

- <h4>/etc/passwd 구조</h4>



<img src="https://user-images.githubusercontent.com/64996121/155144635-ad4b319b-1b19-4ec3-bfac-17fb8a0399ab.PNG" width=650 hegiht=80 />




- 사용자 이름(Name) : 시스템에 등록된 사용자를 구분하는 문자
- 패스워드(passward) : x로 표시된 경우 /etc/shadow 파일에 암호저장(logID가 생성되는 기준)
- UID : 시스템에 등록된 사용자를 구분하는 숫자 (범위  100~60000: 유저 ID, 단위수 별로 따짐)
- GID : 사용자가 실행한 명령어에서 기본으로 사용할 그룹 (범위 100~60000 : etc밑에 값이 있어야 사용)

- GECOS(comment) : 이름, 전화번호 등의 사용자의 다양한 정보 저장
- Home(home_directory) : 시스템에 로그인할 때 최초로 위치하는 디렉토리 
  - 사용자 계정의 개별 홈 디렉토리 위치
- Shell(login_shell) : 사용자의 명령어를 해석하는 shell

- 예시

```shell
[root@localhost ~]# tail -3 /etc/passwd
user03:x:3000:1000:user:/home/user3:/bin/csh
user04:x:3001:3001::/home/user04:/bin/bash
user05:x:3002:3002::/home1/user05:/bin/bash
```

<br>

<br>

<h2>/etc/shadow</h2>

- 사용자의 암호화된 패드워드와 패스워드 설정 정책 기재
- 이 파일은 공개되면 모든 사용자의 비밀번호가 유출될 수 있기 때문에 주의해야한다.

```shell
[root@localhost ~]# ls -l /etc/shadow
----------. 1 root root 1454  2월 22 15:20 /etc/shadow
```

- <h4>/etc/shadow 구조</h4>



<img src="https://user-images.githubusercontent.com/64996121/155145117-9f0b3711-f86f-4fdb-86c1-bdb11f4feaec.PNG" width=650 hegiht=80 />



- 사용자 이름(Name) : 시스템에 등록된 사용자를 구분하는 문자
- 해시pw(hash_pw) : 사용자의 해시 암호 값 저장
  - !! 값을 가지는 경우는, 암호가 부여되지 않았을 때 나타나는 초기값
  - ![해쉬암호] : 계정이 lock 되었다는 의미
- lastchange : 현재 사용중인 암호가 설정된 시기
  - 1970년 1월 1일 UNIX 시스템이 시작됐던 날 부터 계저으이 비밀번호가 수정된 날짜를 일수로 표기한 것
- min : 암호 설정 후 변경 불가 기간
- max : 암호 변경 없이 사용 가능한 최대 기간
- warning : 암호 만료 전 경고 기간
- inactive : 패스워드 만료일부터 계정 만료가지의 유예 기간
  - -1 : 기능 정지
  - 0 : 사용 정지
  - n : 만료인로부터 n일 수 만큼 유예 기간 지급 
- expire : 사용자 계정 만료 시기
- 아래 예시 처럼 암호화된 상태로 보인다

```shell
centos:$6$e9Dd1hgZnOm7RM8M$ebNQ9gqkwBBFwRVszRUKuzOZRqVFH/daShoGijET7KeteoBNLD5y3vd1YJ61Y314Vepdwh9OBsRE.wUX/y1Ko.::0:99999:7:::
```

<br>

<br>

<h2>사용자 전환</h2>

- 모든 사용자는 슈퍼 유저 혹은 다른 일반 유저로 전환 가능
- 전환 시 권한 및 환경 변수 등을 획득
- 명령어
  - su : 현재 계정을 로그아웃 하지 않고 사용자만 전환
    - 인증 방식: 대상 아이디의 패스워드 입력
    - default : root
  - su - : 사용자 환경까지 획득(환경 변수 적용)
    - 인증 방식: 대상 아이디의 패스워드 입력
  - sudo -i : su - 와 동일
    - 인증 방식: 본인 패스워드 입력
  - sudo : 관리자 권한 임시 획득(일시적으로 root가 됨)
    - 인증 방식: 현재 로그인한 본인 패스워드 입력
    - sudo 명령어를 통해 생성한 파일/디렉터리는 root의 소유가 됨
    - wheel 그룹에 속해있어야 sudo 명령어 사용가능
      - /etc/sudoers 에 지정됨

- <h4>관리자 권한 사용</h4>

  - **sudo** 명령어를 통해 권한 획득
  - **wheel 그룹 구성원**
  - /etc/sudoers 참조
  - /var/log/secure에 기록
  - 사용 예

  ```shell
  [student@server0 ~]$ sudo usermod -L username
  [sudo] password for student: student
  [student@server0 ~]$ sudo tail -5 /var/log/secure
  ...Output omitted...
  Feb 1 19:45:26 server0 sudo: student : TTY=pts/1 ; PWD=/home/student ; 
  USER=root ; COMMAND=/sbin/usermod -L username
  Feb 1 19:45:26 server0 usermod[13570]: lock user 'username' password
  Feb 1 19:45:43 server0 sudo: student : TTY=pts/1 ; PWD=/home/student ; 
  USER=root ; COMMAND=/bin/tail -5 /var/log/secure
  ```

<br>

<br>

<h2>사용자 관리</h2>

- 
  <h4>사용자 생성</h4>

  - **useradd [option] [username]** 
  - 옵션
    - -s : 사용자 shell 지정
    - -b : 사용자 홈 디렉토리 변경
    - -f : INACTIVE 변경
    - -u : uid 지정
    - -d : 특정 디렉토리 지정(홈 디렉토리) , 최종 디렉토리만 생성
    - -g : 기본 그룹 지정
    - -G : 보조 그룹 지정
    - -D : 사용자 생성 default값 확인 및 default 값 수정 시 사용
    -  생성시 /etc/default/useradd & /etc/login.defs 파일 참조
  - /sbin/nologin : 사용할 수 있는 shell을 주지 않음으로써 로그인할 수 없게 만듦
  - 특정 서비스만 사용하여 인증만 필요한 사용자들에겐 shell을 주지 않음
  - /etc/default/useradd 의 내용과 useradd -D 의 내용 동일

  

  **사용 예**

  - user01 사용자 생성

  ```shell
  [root@localhost ~]# useradd user01
  [root@localhost ~]# tail -2 /etc/passwd
  centos:x:1000:1000:centos:/home/centos:/bin/bash
  user01:x:1001:1001::/home/user01:/bin/bash
  ```

  - uid 번호가 2000인 user02 사용자 생성

  ```shell
  [root@localhost ~]# useradd -u 2000 user02
  [root@localhost ~]# tail -2 /etc/passwd
  user01:x:1001:1001::/home/user01:/bin/bash
  user02:x:2000:2000::/home/user02:/bin/bash
  ```

  - uid 번호가 3000, gid 번호가 3000, comment가 user, 디렉토리가 /home/user3, shell이 /bin/csh인 user03 사용자 생성

  ```shell
  [root@localhost ~]# useradd -u 3000 -g 1000 -c user -d /home/user3 -s /bin/csh user03
  [root@localhost ~]# tail -1 /etc/passwd
  user03:x:3000:1000:user:/home/user3:/bin/csh
  ```

  - 보조그룹으로 wheel에 속한 user04 사용자 생성
    - wheel 그룹에 속하게 됨으로써 sudo 명령어를 사용할 수 있게됨
    - /etc/group에서 확인 가능

  ```shell
  [root@localhost ~]# useradd -G wheel user04
  [root@localhost ~]# less /etc/group
  ...
  wheel:x:10:centos,user04
  ...
  ```

  -  홈 디렉토리가 /home1 인 user05 사용자 생성

  ```shell
  [root@localhost ~]# useradd -b /home1 user05
  [root@localhost ~]# tail -1 /etc/passwd
  user05:x:3002:3002::/home1/user05:/bin/bash
  ```

  - useradd -D 와 /etc/default/useradd 내용이 동일함을 확인

  ```shell
  [root@localhost ~]# useradd -D
  GROUP=100
  HOME=/home
  INACTIVE=-1
  EXPIRE=
  SHELL=/bin/bash
  SKEL=/etc/skel
  CREATE_MAIL_SPOOL=yes
  ```

  ```shell
  [root@localhost ~]# cat /etc/default/useradd
  # useradd defaults file
  GROUP=100
  HOME=/home
  INACTIVE=-1
  EXPIRE=
  SHELL=/bin/bash
  SKEL=/etc/skel
  CREATE_MAIL_SPOOL=yes
  ```





- <h4>사용자 수정</h4>

  - **usermod [option] [username]**
  - 옵션
    - -a : 보조그룹을 추가
    - -d : 홈 디렉토리 변경
      - **설정만 바뀔 뿐, 실제로 디렉토리가 옮겨지진 않는다.**
      - 실제적으로 옮기려면  **-md 옵션** 사용
    - -m : (move) 홈 디렉토리 변경할 때 사용(-d와 함께 사용)
    - -l : (login) 계정명 변경
    - -G : 보조 그룹 변경
    - -L : 사용자 계정 잠금
    - -U : 계정 잠금 해제
  - 보조그룹을 **추가** 할 때에는 -aG 옵션을 사용
  - -G 옵션만 사용하면, 추가되는 것이 아니라 기존 보조그룹이 삭제(덮어씌워짐)된다.
  - -L 옵션과 -U 옵션을 이용하여 사용자 계정을 잠금 및 해제 가능

  

  **사용 예**

  - -G 옵션을 사용하여 보조 그룹을 변경하면 기존 보조그룹이 삭제됨을 확인할 수 있다.
    - 기존 보조그룹 : wheel -> 변경된 보조그룹: adm, nobody

  ```shell
  [root@localhost ~]# id user04
  uid=3001(user04) gid=3001(user04) groups=3001(user04),10(wheel)
  [root@localhost ~]# usermod -G adm,nobody user04
  [root@localhost ~]# id user04
  uid=3001(user04) gid=3001(user04) groups=3001(user04),4(adm),99(nobody)
  ```

  -  -d 옵션을 사용하여 홈 디렉토리를 /home1 변경

  ```shell
  [root@localhost ~]# usermod -d /home1/user05 user05
  [root@localhost ~]# tail -1 /etc/passwd
  user05:x:3002:3002::/homeuser05:/bin/bash
  ```

  - -d 옵션으로 홈 디렉토리를 /home으로 다시 변경
    - /etc/passwd 에는 /home 으로 잘 설정되어 있으나 ls 명령어를 통해 살펴보면 user05는  /home이 아닌 /home1 에 들어있음 -> /etc/passwd의 설정만 바뀌었을 뿐, 실질적으로 이동되지 않는다

  ```select
  [root@localhost ~]# usermod -d /home/user05 user05
  [root@localhost ~]# tail -1 /etc/passwd
  user05:x:3002:3002::/home/user05:/bin/bash
  ```

  ```
  [root@localhost ~]# tail -1 /etc/passwd
  user05:x:3002:3002::/home/user05:/bin/bash
  ```

  ```
  [root@localhost ~]# ls /home
  centos  user01  user02  user04  user3
  ```

  ```
  [root@localhost ~]# ls /home1
  user05
  ```

  - -md 명령어를 사용하여 홈 디렉토리를 /home1로 변경 -> 잘 이동됨

  ```
  [root@localhost ~]# usermod -md /home user05
  [root@localhost ~]# ls /home
  centos  user01  user02  user04  user05  user3
  ```

  - user03의 coment를 없애고, 디렉토리를 /home으로 이동 시킨 뒤 shell을 /bin/bash 밑에 생성

  ```shell
  [root@localhost ~]# tail -3 /etc/passwd
  user03:x:3000:1000:user:/home/user3:/bin/csh
  user04:x:3001:3001::/home/user04:/bin/bash
  user05:x:3002:3002::/home:/bin/bash
  [root@localhost ~]# usermod -c "" -md /home/user03 -s /bin/bash user03
  [root@localhost ~]# tail -3 /etc/passwd
  user03:x:3000:1000::/home/user03:/bin/bash
  user04:x:3001:3001::/home/user04:/bin/bash
  user05:x:3002:3002::/home:/bin/bash
  ```

  -  user05의 사용자명을 testuser로 바꾸고, 홈 디렉토리도 변경
    - testuser로 바꾸고 /etc/shadow의  패스워드 영역이 !!으로 되어있어, 아직 활성화되어있지 않음을 확인 가능

  ```
  [root@localhost ~]# usermod -md /home/testuser -l testuser user05
  [root@localhost ~]# tail -1 /etc/passwd
  testuser:x:3002:3002::/home/testuser:/bin/bash
  ```

  ```
  [root@localhost ~]# tail -1 /etc/shadow
  testuser:!!:19045:0:99999:7:::
  
  ```

  - testuser의 계정을  lock 해보자.
    - 패스워드 영역이 ! 로 시작하므로, lock 된 것을 확인 가능

  ```shell
  [root@localhost ~]# usermod -L testuser
  [root@localhost ~]# tail -1 /etc/shadow
  testuser:!$6$7wmgRiWS$HYo0BGe0ybz4UlwYfwlYhiBPNKhVQEqg6cLYqUziNbntNxA8VOliAv8rMsnhdxRXtmZJZoJ5HnPBHbUp3gx0J1:19045:0:99999:7:::
  ```

  - testuser의 계정을 다시 unlock 해보자.

  ```shell
  [root@localhost ~]# usermod -U testuser
  [root@localhost ~]# tail -1 /etc/shadow
  testuser:$6$7wmgRiWS$HYo0BGe0ybz4UlwYfwlYhiBPNKhVQEqg6cLYqUziNbntNxA8VOliAv8rMsnhdxRXtmZJZoJ5HnPBHbUp3gx0J1:19045:0:99999:7:::
  ```

  

- <h4>사용자 삭제</h4>

  - **userdel [option] [username]**
  - 옵션 
    - -r : (remove) 사용자와 함께 사용자 디렉토리, 사용자 메일함 삭제
    - -f : (force) 사용자를 강제로 삭제

  - 주의 : **-r 옵션을 사용하지 않고 사용자(여기서 user01 라고 지칭하겠다)를 삭제하면 홈 디렉토리가 남아있게 된다.**

    - user01의 파일들의 소유자가 바뀌고, 일반 다른 유저가 user01만 볼 수 있던 파일(권한이 없어서 볼 수 없던 파일)을 볼 수 있게된다.

    - 보안상 위험하므로 -r 옵션을 사용해야한다
    - /var/spool/mail에서도 확인 가능

  

  **사용 예**

  - testuser 사용자 삭제

  ```
  [root@localhost ~]# userdel -r testuser
  [root@localhost ~]# tail -3 /etc/passwd
  user02:x:2000:2000::/home/user02:/bin/bash
  user03:x:3000:1000::/home/user03:/bin/bash
  user04:x:3001:3001::/home/user04:/bin/bash
  ```

  

<br>

<br>

<h2>그룹 관리</h2>

- 그룹 : 실행 및 **접근 권한의 2차적 기준**
  - 파일이나 디렉토리에 접근할 때, 소유자 그룹&보조 그룹 권한 모두 검사
- 기본 그룹과 보조 그룹

<img src="https://user-images.githubusercontent.com/64996121/155144917-5a3df042-5e22-4f78-8666-e49d1baa8f58.PNG" width=500 height=250 />


- /etc/group 구조

  ```shell
  Name:Password:GID:Member
  ```

- <h4>그룹 생성</h4>

  - **groupadd [option] [groupname]**
  - 옵션
    - -g : 특정 gid 값 지정
    - -o : 그룹의 gid를 중복으로 사용
    - gid 지정 시 /etc/login.defs 파일 참조
  - **/etc/group에 그룹 정보 표시**

  

  사용 예

  - testgroup을 생성하고 /etc/group에서 확인해보자

  ```shell
  [root@localhost ~]# groupadd testgroup
  [root@localhost ~]# tail -1 /etc/group
  testgroup:x:3003:
  ```

  - gid가 4000인 testgroup1을 생성해보자

  ```shell
  [root@localhost ~]# groupadd -g 4000 testgroup1
  [root@localhost ~]# tail -1 /etc/group
  testgroup1:x:4000:
  ```

  

- <h4>그룹 수정</h4>

  - **groupmod [option] [groupname]**
  - 옵션
    - -n : 그룹의 이름을 변경
    - -g : 새로운 gid 값을 부여
    - -o : 그룹의 gid를 중복으로 사용

  

  사용 예

  - testgroup1의 gid를 5000으로 수정하고 그룹명을 test로 바꿔보자

  ```shell
  [root@localhost ~]# groupmod -g 5000 -n test testgroup1
  [root@localhost ~]# tail -1 /etc/group
  test:x:5000:
  ```

  

- <h4>그룹 삭제</h4>

  - **groupdel [option] [groupname]**

  

  사용 예

  - test 그룹을 삭제해보자

  ```shell
  [root@localhost ~]# groupdel test
  [root@localhost ~]# tail -1 /etc/group
  testgroup:x:3003:
  ```

  

<br>

<br>

<h2>패스워드(password) 관리</h2>

- 암호 설정

  - passwd 명령어 사용
  - 로그인 한 사용자 본인의 암호 변경
  - root 사용자의 경우 모든 계정 변경 가능

- 암호 속성 변경

  - chage 명령어 사용
  - root 사용자만 설정 가능
  - 암호 사용 기간 및 변경 기한 등 설정
  - /etc/shadow 파일 참조 및 변경

- <h4>chage</h4>

  - 패스워드에 대한 유효기간을 부여하여 주기적으로 사용자가 패스워드를 변경하도록 하는 보안상 상당히 유용한 도구
  - **chage [option] [username]**
  - 옵션 
    - -l : chage의 설정 확인(계정 암호 속성 확인)
    - -d : 암호 변경일 설정
    - -M : 패스워드 사용의 최대 기간 수정
    - -m : 패스워드를 변경할 수 있는 최소 기간 수정
    - -I(대문자 i) : (inactive) 패스워드 만기 후 계정을 사용하지 못하는 기간
    - -E : 사용자 계정의 만료 날짜 설정
    - -d : 사용자의 새 패스워드 변경 일
    - -W : 패스워드의 유효기간이 만료하기 전 사용자에게 경고하는 기간 수정

  

  사용 예

  - user01의 암호 정보를 확인해보자

  ```shell
  [root@localhost ~]# chage -l user01
  마지막으로 암호를 바꾼 날                                       : 2월 22, 2022
  암호 만료                                       :안함
  암호가 비활성화 기간                                    :안함
  계정 만료                                               :안함
  암호를 바꿀 수 있는 최소 날 수          : 0
  암호를 바꿔야 하는 최대 날 수           : 99999
  암호 만료 예고를 하는 날 수             : 7
  ```

  -  user01의 패스워드최소변경일을 1일로, 패스워드 최대사용기간을 7일로, 패스워드유효 경고 기간을 10일로 변경해보자

  ```shell
  [root@localhost ~]# chage -m 1 -M 7 -W 10 user01
  [root@localhost ~]# chage -l user01
  마지막으로 암호를 바꾼 날                                       : 2월 22, 2022
  암호 만료                                       : 3월 01, 2022
  암호가 비활성화 기간                                    :안함
  계정 만료                                               :안함
  암호를 바꿀 수 있는 최소 날 수          : 1
  암호를 바꿔야 하는 최대 날 수           : 7
  암호 만료 예고를 하는 날 수             : 10
  ```

  - user01의 암호 변경일을 0으로 바꿔보자
    - user01 로그인하는 순간 바로 암호를 변경하게 함

  ```
  [root@localhost ~]# chage -d 0 user01
  ```

  
