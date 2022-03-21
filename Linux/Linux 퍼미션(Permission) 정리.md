<h1>[Linux] 리눅스(Linux) 퍼미션(Permission) 정리</h1>



<h3>📌INDEX</h3>

- [퍼미션(Permission)이란?](#퍼미션permission이란)
- [read·write·execution 동작 관련된 명령어](#readwriteexecution-동작-관련-명령어)
- [chmod](#chmod)
- [Specia Permission](#special-permission)
  - [SetUID와 SetGID](#setuid와-setgid)
  - [StickyBit](#stickybit)
- [umask](#umask)

<br><br>

<h2>퍼미션(Permission)이란?</h2>

- 특정 파일이나 디렉토리에 대하여 **읽기/쓰기/삭제 등의 권한을 설정하여 파일 접근 권한을 제어하고 파일을 보호**하기 위해 사용
- 파일의 퍼미션은 ls 또는 stat으로 확인할 수 있다.
- 퍼미션의 종류

<img src="https://user-images.githubusercontent.com/64996121/154481894-9301c09c-3841-4463-a93d-cfc00ac61b00.PNG" width=800 height=300/>

- 퍼미션 해석

  - 맨 앞의 타입을 제외하고 **3자리씩 끊어서 해석**

  - 예시 

  ```shell
  drw-r-xr--
  ```

  - 맨 앞의 타입을 제외하고 **3자리씩 끊어서 해석**

  ```
  d | rw- | r-x | r--
  d : 타입 (여기서 d는 디렉토리)
  rw- : 소유자(user) 권한
  r-x : 그룹(group) 소유자 권한
  r-- : 일반 사용자(other) 권한
  ```

- 타입

  - '-' : 일반 파일
  - d : 디렉토리
  - l : 심볼릭 링크
  - p : Named pipe
  - s : 소켓
  - b, c : 디바이스 파일

- 퍼미션은 **숫자(넘버릭)으로 표현 가능**하다.

  - r  = 2^2 = 4
  - w = 2^1 = 2
  - w = 2^0 = 1
  - '-' = none 

  ```
  rw- = 4+2 = 6
  r-x = 4+1 = 5
  r-- = 4 
  
  따라서 rw-r-xr-- 는 654와 같다
  ```

  - 예시 그림 정리

  <img src="https://user-images.githubusercontent.com/64996121/154482170-c8f96bf6-1507-4888-8255-f138216f6461.jpg" width=400 height=200 />


<br><br>

<h2>read·write·execution 동작 관련 명령어</h2>

- 파일의 읽기·쓰기·실행

  - 파일의 읽기(read)   : cat, more, less, tail, grep
  - 파일의 쓰기(write) : vi 에디터, >, >>
  - 파일의 실행(execution) : **파일의 실행은 파일의 내용에 접근한다는 의미**이다.

  [cat, more, less, tail, grep 설명보러가기]: https://nayoungs.tistory.com/62

- 디렉토리의 읽기·쓰기·실행

  - 디렉토리의 읽기(read) : ls
  - 디렉토리의 쓰기(write) : touch, >, >>, mkdir, rmdir, cp, mv, rm
    - **삭제·생성·이동·복사 등등 모두 data 블럭에 접근**할 수 있어야하고, 이는 **쓰기 권한(w)이 있어야한다.**
  - 디렉토리의 실행(execution): 디렉토리의 실행은 디렉토리의 내용에 접근한다는 의미이다.
    - 즉, **cd를 사용(ACCESS)할 수 있느냐 없느냐**의 여부이다. 

  [mkdir, rmdir, cp, mv, rm 설명보러가기]: https://nayoungs.tistory.com/64

  

<br><br>



<h2>chmod</h2>

- 기존 파일 또는 디렉토리에 대한 **접근 권한 변경 시 사용**하는 명령어

- 사용법: chmod [option] [mode] [file]

- 옵션

  - -v : 모든 파일에 대해 모드가 적용되는 진단(diagnostic) 메세지 출력
  - -f : 에러 메세지를 출력하지 않음
  - -c : 기본 파일 모드가 변경되는 경우만 진단(diagnostic) 메세지 출력
  - -R : 지정한 모드를 파일과 디렉토리에 대해 재귀적으로 ( recursively) 적용

- 파일에 적용할 **모드(mode) 조합**

  - u, g, o, a : 소유자(u), 그룹(g), 그 외 사용자(o), 모든 사용자(a) 지정
  - +, -, = : 현재 모드에 권한 추가(+), 현재 모드에서 권한 제거(-), 현재 모드로 권한 지정(=)
  - r, w, x : 읽기 권한(r), 쓰기 권한(w), 실행 권한(x)
  - X : "디렉토리" 또는 "실행 권한(x)이 있는 파일"에 실행 권한(x) 적용
  - s :  실행 시 사용자 또는 그룹 ID 지정(s). "setuid", "setgid"
  - t : 공유모드에서의 제한된 삭제 플래그를 나타내는 sticky(t) bit
  - 0~7 : 8진수(octet) 형식 모드 설정 값(넘버릭)

- 예시

  ```shell
  [root@localhost ~]# ls -l aaa
  -rw-r--r--. 1 root root 2658  2월 16 19:02 aaa
  ```

  - 위와 같은 aaa 파일에서 그룹 권한에 쓰기(write) 권한을 추가해보자

    ```shell
    [root@localhost ~]# chmod g+w aaa
    [root@localhost ~]# ls -l aaa
    -rw-rw-r--. 1 root root 2658  2월 16 19:02 aaa
    ```

  - 다시 그룹 권한에서 쓰기(write) 권한을 제거해보자

    ```
    [root@localhost ~]# chmod g-w aaa
    [root@localhost ~]# ls -l aaa
    -rw-r--r--. 1 root root 2658  2월 16 19:02 aaa
    ```

  - 현재 aaa 파일의 퍼미션을 숫자(넘버릭)으로 표현하면, 644이다. 그룹에 쓰기(write)권한을 추가했을 때의 숫자(넘버릭) 664로 변경해보자.

    ```shell
    [root@localhost ~]# chmod 664 aaa
    [root@localhost ~]# ls -l aaa
    -rw-rw-r--. 1 root root 2658  2월 16 19:02 aaa
    ```

  - aaa 파일에서 소유자(user)권한에서 쓰기(write)권한을 없애고, 이 외 사용자(other) 권한에 쓰기(write)권한을 추가해보자.

    ```shell
    [root@localhost ~]# chmod u-w,o+w aaa
    [root@localhost ~]# ls -l aaa
    -r--rw-rw-. 1 root root 2658  2월 16 19:02 aaa
    ```

  - aaa 파일에서 소유자 권한과 그룹 권한에서 쓰기 읽기(read) 권한을 제거해보자.

    ```shell
    [root@localhost ~]# chmod ug-r aaa
    [root@localhost ~]# ls -l aaa
    -----w-rw-. 1 root root 2658  2월 16 19:02 aaa
    ```

  - aaa 파일에서 소유자, 그룹, 이외 사용자 권한 모두에서 읽기(read) 권한을 제거해보자.

    ```shell
    [root@localhost ~]# chmod a-r aaa
    [root@localhost ~]# ls -l aaa
    -----w--w-. 1 root root 2658  2월 16 19:02 aaa<br>
    ```

- 생각해보기) 만약 write 권한을 가진 사용자가 read 권한이 없다면?
  - 파일을 읽을 수 없어, 내용을 확인하지 못하고 작성만 할 수 있다.
  - **read 권한이 없는 사용자가 write하면 파일은 overwrite**된다.
  - 따라서 내용과 내부 위치를 보기 위해 read 권한이 있어야한다.

<br>

<br>

<h2>Special Permission</h2>

- 특수 권한(Special Permission)에는 **setuid, setgid, stickybit**가 있다.

- 기본적으로는 접근하는 사용자의 권한은 앞에서 설정한 접근 권한을 따르게 된다.

- 시스템에서 프로세스에 다섯 가지 번호를 부여한다.

  - 프로세스 식별자(PID)
  - 실제 사용자 ID(RUID)
  - 유효 사용자 ID(EUID)
  - 유효 사용자 그룹 ID(EGID)
  - 실제 사용자 그룹(RGID)
  - 사용 용도
    - 계정 관리에 사용: RUID, RGID
    - **접근 권한 결정**에 사용: **EUID, EGID(보안에 주의)**
    - 일반적으로 실제 번호와 유효 번호는 동일 (RUID = EUID)

- 특수 권한으로, root 사용자가 아닌 사용자도 ping과 같은 명령을 사용할  수 있게 된다.

- <h4>SetUID와 SetGID</h4>

  - **setuid(4000)** : other 유저에 실행권이 있는 상태에서 setuid 선언하면 other 유저 실행 시 상속받는 **EUID가 파일의 소유자(user) 권한에 set **되어 실행됨
  
    - 쉽게 설명하면, **setuid가 지정되어 있는 파일을 실행하면 해당 파일은 파일 소유자(user)의 권한으로 실행**된다.
  
  - **setgid(2000)** :  other 유저에 실행권이 있는 상태에서 setuid 선언하면 other 유저 실행 시 상속받는 **EGID가 파일의 그룹 권한에 set **되어 실행됨
  
    - 쉽게 설명하면, **setgid가 지정되어 있는 파일을 실행하면 해당 파일에 지정되어 있는 그룹(group)의 권한으로 실행**됨
  
  - setuid 예시 
  
    ```shell
    -rwsr-xr-x. 1 root root 33600  4월  6  2020 /usr/bin/passwd
    ```
  
    -  일반 사용자는 자신의 비밀번호 변경이 가능하고, 이는 비밀번호가 저장되어있는 passwd 파일을 실행할 때, 일반 사용자가 소유자(user) 권한(setuid 설정)을 갖기 때문이다.
  
      ```shell
      [user@localhost ~]$ passwd
      user 사용자의 비밀 번호 변경 중
      Current password:
      ```
  
    - 숫자(넘버릭)으로 표현할 때는 접근 권한 3자리(755) 앞에 4를 붙여준다. => 4755
  
  - 실습해보기 : 일반 사용자(other)가 접근하지 못하는 /etc/shadow 에 접근할 수 있도록 해보자.
  
    ```shell
    [user@localhost ~]$ more /etc/shadow | head -3
    more: cannot open /etc/shadow: 허가 거부
    ```
  
    - 두 개의 터미널(root, user)을 열어서 작업
  
    - more(명령어)는 원래 일반 사용자(other)가 읽기(read) 권한을 가지지 않는다.
  
      ```shell
      [root@localhost ~]# ls -l /usr/bin/more
      -rwxr-xr-x. 1 root root 46128  7월 21  2020 /usr/bin/more
      ```
  
    - more 파일에 setuid 권한을 추가하여, 일반 사용자(other)가 more로 실행할 때 소유자(user)의 권한을 갖게 하자 (2가지 방법)
  
      ```
      [root@localhost ~]# chmod u+s /usr/bin/more
      [root@localhost ~]# ls -l /usr/bin/more
      -rwsr-xr-x. 1 root root 46128  7월 21  2020 /usr/bin/more
      ```
  
      ```shell
      [root@localhost ~]# chmod 4755 /usr/bin/more
      ```
  
    - 일반 사용자로 로그인된 터미널에서 more 명령어로 /etc/passwd 에 접근해보자. 
  
      ```shell
      [user@localhost ~]$ more /etc/shadow | head -3
      root:$6$6DgzXF8q3HGxTAwT$/258zFLNfUORzn0u2qi/XIGUmjmoyPn9x8nEusSE6.EOw8hkKetRyJJtiCxMfyYoVqrqC8bFhNmFBvTF/Pw6N1::0:99999:7:::
      bin:*:18397:0:99999:7:::
      daemon:*:18397:0:99999:7:::
      ```
  
    - 일반 사용자(other)가 접근할 수 있는 것을 확인할 수 있다.
  
  - setuid 비트 설정 시 보안 취약점
  
    - root 권한이 필요없는 프로그램에 소유주가 root로 되어있고, setuid가 설정된 경우는 보안상으로 매우 취약하다.
    - 일반 사용자로 접근하는 경우도 setuid 설정으로 실행가능해지기 때문이다.
    - 따라서 setuid 프로그램의 수는 최소화해야하고, 최근에는 setuid, setgid 사용을 점차 줄여가고 있다.
  
    

- <h4>StickyBit</h4>

  -  생각해보기) 만약 일반사용자(other)가 write권한이 있다면?

    - tmp 디렉토리의 경우 , 목적상 other 영역에 write 권한이 있다.
    - 문제는 **other 영역의 write 권한은 생성, 삭제, 복사, 이동에 영향**을 준다는 것이다.
    - 결국 tmp 디렉토리는 자신의 소유가 아닌 파일도 영향을 줄 수 있게 설정되어있기 때문에 보호가 필요하다.
    - 잘못 사용하는 경우, 프로그램의 무결성에 손상을 주고, 나아가 프로그램의 동작을 손상시킬 수 있다.
    - 이러한 문제를 해결하기 위해 고안한 것이 바로 **stickybit**이다.

  - **StickyBit**(1000) : 파일을 삭제, 이동, 덮어쓰기 등을 할 때, 자신의 소유가 아닐 경우 실행하지 못하게 하는 보호 기능을 부여한다.

  - stickybit가 설정된 디렉토리 내에서는 누구나 파일과 디렉토리를 생성할 수 있지만, **자신의 소유가 아닌 파일은 삭제할 수 없다.**

  - 퍼미션 문자 : **t**

  - **other 권한의 접근권한(x) 자리에 x대신 t**가 들어가면 이를 StickyBit라 한다.

  - 퍼미션 넘버 : 접근 권한 3자리 앞에 1을 붙인다. (1000)

    ```shell
    [root@localhost ~]# stat /tmp/
      File: /tmp/
      Size: 4096            Blocks: 8          IO Block: 4096   디렉토리
    Device: 10303h/66307d   Inode: 148         Links: 20
    Access: (1777/drwxrwxrwt)  Uid: (    0/    root)   Gid: (    0/    root)
    ```

  - 실습: 일반 사용자(other)로 로그인된 상태에서 /tmp 하위에 kbs/aaa 파일을 만들고, kbs 디렉토리의 stickybit를 추가한 뒤, 삭제를 시도해보자.

    ```shell
    [root 설정]
    [root@localhost kbs]# cp /etc/passwd /tmp/kbs/aaa
    [root@localhost kbs]# chmod o+t /tmp/kbs
    [root@localhost kbs]# chmod 1777 /tmp/kbs
    [root@localhost ~]# ls -ld /tmp/kbs
    drwxrwxrwt. 2 root root 17  2월 16 20:30 /tmp/kbs
    ```

    ```shell
    [other에서 확인]
    [user@localhost kbs]$ ls
    aaa
    [user@localhost kbs]$ rm -f aaa
    rm: cannot remove 'aaa': 명령을 허용하지 않음
    ```

    - 일반 사용자(other)는 stickybit가 설정된 디렉토리 내의 파일을 삭제할 수 없다

- Special Permission 찾기

  - find 명령어 이용
  - -perm 옵션: 퍼미션으로 찾기
    - 필터링
      - -4000 : setuid 설정 되어있는 것
      - -2000 : setgid 설정 되어있는 것
    - -o : or(또는)

  ```shell
  [root@localhost tmp]# find / -type f -user 0 \( -perm -4000 -o -perm -2000 \) -ls
  101193095     40 -rwsr-xr-x   1  root     root        38680  5월 11  2019 /usr/bin/fusermount
  101479839     80 -rwsr-xr-x   1  root     root        79648  8월 12  2020 /usr/bin/chage
  101479840     84 -rwsr-xr-x   1  root     root        84296  8월 12  2020 /usr/bin/gpasswd
  101479843     44 -rwsr-xr-x   1  root     root        43560  8월 12  2020 /usr/bin/newgrp
  101480556     52 -rwsr-xr-x   1  root     root        50456  7월 21  2020 /usr/bin/mount
  101480571     52 -rwsr-xr-x   1  root     root        50320  7월 21  2020 /usr/bin/su
  101480574     36 -rwsr-xr-x   1  root     root        33648  7월 21  2020 /usr/bin/umount
  101480583     24 -rwxr-sr-x   1  root     tty         21232  7월 21  2020 /usr/bin/write
  ...
  ```

  

<br><br>

<h2>umask</h2>

- umask는 **파일이나 디렉토리 생성 시 초기 접근 권한을 설정**할 때 사용
- 초기 파일의 default 권한 : 666
- 초기 디렉토리 default 권한 : 777
- umask 명령어로 umask 값 확인가능
- default 권한 - umask = 생성된 파일 혹은 디렉터리의 권한

```shell
[root@localhost tmp]# umask
0022
```

- 파일과 디렉토리를 생성해보자

```shell
[root@localhost ~]# touch aa
[root@localhost ~]# mkdir kb
[root@localhost ~]# ls -ld aa kb
-rw-r--r--. 1 root root 0  2월 17 07:04 aa        -> 644
drwxr-xr-x. 2 root root 6  2월 17 07:04 kb        -> 755
```

- 파일은 644, 디렉토리는 755 의 퍼미션을 갖는다.

```
	 666		 777
    0022		0022
	----		----
	 644		 755
```

- umask 변경 : umask [변경할 umask]

```shell
[root@localhost ~]# umask 027
[root@localhost ~]# umask
0027
```

- 변경된 umask로 파일과 디렉토리를 다시 생성해보자

```shell
[root@localhost ~]# touch bb
[root@localhost ~]# mkdir mb
[root@localhost ~]# ls -ld bb mb
-rw-r-----. 1 root root 0  2월 17 07:09 bb           -> 640
drwxr-x---. 2 root root 6  2월 17 07:09 mb           -> 750
```

```
	 666		 777
    0027		0027
	----		----
	 640		 750
```

- **umask를 통해서 default 생성되는 파일은 절대로 실행권한을 받을 수 없다.**

- umask는 **프로파일(환경설정 파일)에 선언**
  - 일반적으로 프로파일은 로그인 시 적용
  - /etc/ : 시스템 환결설정 디렉토리(전체에 영향을 주는 설정을 함)
  - umask(명령어)로 변경해도, 로그아웃 한 뒤 다시 로그인하면 umask는 원래 값(환경설정 파일에 작성 되어있는)으로 변경됨
- 사용자의 홈 디렉토리에도 사용자의 환경설정 파일이 존재
  - **$HOME/.bash_profile** :  (사용자에게 영향을 주는 프로파일) 사용자 프로파일
  - 여기에 umask를 수정하면, 로그아웃 한 뒤 다시 로그인해도 그대로

- 실습: **사용자 프로파일에 umask 값을 반영**하고 확인해보자

  - 사용자 파일()$HOME/.bash_profile)에 umask값 작성

    ```shell
    [user@localhost ~]$ echo "umask 0027" >> $HOME/.bash_profile
    [user@localhost ~]$ tail -5 $HOME/.bash_profile
    fi
    
    # User specific environment and startup programs
    umask 0027
    [user@localh
    ```

  - 변경된 **umask 값이 반영되어 퍼미션이 생성**되어있는지 확인

    ```shell
    [user@localhost ~]$ umask
    0027
    [user@localhost ~]$ touch bbb
    [user@localhost ~]$ ls -l bbb
    -rw-r-----. 1 user user 0  2월 17 07:21 bbb      
    ```

  - 번경된 umask(0027)로 퍼미션(640)이 잘 생성된 것을 확인할 수 있다. 

