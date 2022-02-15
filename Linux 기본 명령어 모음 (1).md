<h1>Linux   기본 명령어 모음 (1)</h1>


<h3>📌INDEX</h3>

- [Windows Terminal로 실행하기](#windows-terminal로-실행하기)
- [pwd](#pwd)
- [cd](#cd)
-  [ls](#ls)
- [cat](#cat)
- [more](#more)
- [less](#less)
- [head와 tail](#head와-tail)
- [grep](#grep)
- [touch](#touch)
- [<, <<를 이용한 파일 생성](#-를-이용한-파일-생성)



<br><br>

<h2>Windows Terminal로 실행하기</h2>

- 나는 VMware Workstation 16 Player와 CentOS 8을 이용하였다. (설치과정은 생략)

  <img src="C:\Users\USER\Desktop\유선 연결.PNG" style="zoom:50%;" />

- 위의 사진 처럼 VMware를 "유선 연결됨" 상태로 만들어준다.

- 그 다음 "ip a"를 입력하여 자신의 ip주소를 확인한다.

  ```
  [root@localhost ~]# ip a
  1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
      link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
      inet 127.0.0.1/8 scope host lo
         valid_lft forever preferred_lft forever
      inet6 ::1/128 scope host 
         valid_lft forever preferred_lft forever
  2: ens160: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
      link/ether 00:0c:29:e2:b4:90 brd ff:ff:ff:ff:ff:ff
      inet 192.168.238.128/24 brd 192.168.238.255 scope global dynamic noprefixroute ens160
         valid_lft 1388sec preferred_lft 1388sec
      inet6 fe80::3060:abba:19e9:9a44/64 scope link noprefixroute 
         valid_lft forever preferred_lft forever
  3: virbr0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
      link/ether 52:54:00:3b:d5:a1 brd ff:ff:ff:ff:ff:ff
      inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
         valid_lft forever preferred_lft forever
  4: virbr0-nic: <BROADCAST,MULTICAST> mtu 1500 qdisc fq_codel master virbr0 state DOWN group default qlen 1000
      link/ether 52:54:00:3b:d5:a1 brd ff:ff:ff:ff:ff:ff
  [root@localhost ~]# 
  ```

- Windows Terminal을 실행시키고 ip에 연결한다.

```
PS C:\Users\USER> ssh root@192.168.238.128
root@192.168.238.128's password:
Activate the web console with: systemctl enable --now cockpit.socket

Last login: Mon Feb 14 00:20:59 2022 from 192.168.238.1
[root@localhost ~]#
```

- 다음 사진과 같이 된다면 설정 완료!

<img src="C:\Users\USER\Desktop\윈도우 터미널 설정 완료.PNG" style="zoom:50%;" />



<br><br>

<h2>pwd</h2>

- Print Working Directory의 약자로, 현재 디렉토리의 전체 경로를 화면에 보여준다.
- **현재 위치한 경로를 절대경로로 보여주는 명령어**
- 사용 예)

```
[root@localhost ~]# pwd
/root
```



<br><br>

<h2>cd</h2>

- Change Directory의 약자로, **디렉터리를 이동하는 명령**
- **절대 경로: '/'**이 기준, 루트(root)라고 읽는다.
- **상대 경로: 현재 자신이 위치한 디렉토리**가 기준 
- 단지 cd : 현재 로그인한 사용자의 홈 디렉토리로 이동

```
[root@localhost user]# cd
[root@localhost ~]#
```

- **cd - : 방금 전(이전) 디렉토리로 이동**, 토글 방식

```
[root@localhost ~]# cd /etc
[root@localhost etc]# cd -
/root
[root@localhost ~]#
```

- **cd ~ : '~' 뒤에 아무것도 적지 않는 다면 단순한 "cd" 만 작성하는 것과 동일하지만, 뒤에 '사용자(문자)'가 작성된다면, 사용자의 홈 디렉토리로 이동**한다. 
  - 예시: user 사용자의 홈 디렉토리로 이동

```
[root@localhost ~]# cd ~user
[root@localhost user]#
```

- **'.'** 와  **'..'**
  - **.  : 현재 디렉토리**
  - **..  : 현재 디렉토리의 상위 디렉토리**

<br><br>

<h2>ls</h2>

- List의 약자로, Windows의 'dir'과 같은 역할을 한다. 즉 **해당 디렉토리(=폴더)에 있는 파일의 목록을 나열**한다. 

```
[root@localhost ~]# ls
anaconda-ks.cfg  initial-setup-ks.cfg  공개  다운로드  문서  바탕화면  비디오  사진  서식  음악
```

- 옵션:  -l -a -i -F -R -d  -t (lt , lct, lut) 등
- **ls -a**: 현재 디렉토리의 목록(**숨김(히든)파일 포함**)

```
[root@localhost ~]# ls -a
.              .bash_history  .bashrc  .cshrc     .local    .tcshrc               공개      바탕화면  서식
..             .bash_logout   .cache   .dbus      .mozilla  anaconda-ks.cfg       다운로드  비디오    음악
.ICEauthority  .bash_profile  .config  .esd_auth  .pki      initial-setup-ks.cfg  문서      사진
```

- **ls -l**: 헌재 디렉토리의 목록을 자세히 보여줌

  ```
  [root@localhost ~]# ls -l
  합계 8
  -rw-------. 1 root root 1220  2월 14 07:02 anaconda-ks.cfg
  -rw-r--r--. 1 root root 1447  2월 14 07:12 initial-setup-ks.cfg
  drwxr-xr-x. 2 root root    6  2월 14 07:16 공개
  drwxr-xr-x. 2 root root    6  2월 14 07:16 다운로드
  drwxr-xr-x. 2 root root    6  2월 14 07:16 문서
  drwxr-xr-x. 2 root root    6  2월 14 07:16 바탕화면
  drwxr-xr-x. 2 root root    6  2월 14 07:16 비디오
  drwxr-xr-x. 2 root root    6  2월 14 07:16 사진
  drwxr-xr-x. 2 root root    6  2월 14 07:16 서식
  drwxr-xr-x. 2 root root    6  2월 14 07:16 음악
  ```

  - 각각의 요소 알아보기

  ```
  -rw-------. 1 root root 1220  2월 14 07:02 anaconda-ks.cfg
  ==========================================================
  - 속성  - 파일, d 디렉토리 l 심볼릭링크 c 케릭터 파일 b 블록파일 
  
  ▪️ rw-------   
  소유자 , 그룹, other 가 가지는 이 파일 (또는 디렉토리)에서의 권한 -> 3개씩 끊어서
  rw- : 소유자
  --- : 그룹
  --- : other
  
  ▪️ 1
  링크 카운드 (파일의 default 링크 카운트는 1, 디렉토리의 default 링크 카운트는 2)
  
  ▪️ root root
  소유자 그룹을 나타냄. 이름이 같지만 다른 정보
  
  ▪️ 1220
  크기를 나타냄. byte 단위로 표기
  
  ▪️ 2월 14 07:02 
  시간을 나타냄. ls -l 명령어 뒤에 기본적으로 t는 생략됨
  
  ▪️ anaconda-ks.cfg
  파일 또는 디렉토리 이름
  ```

  - **mac Time**

    - ls -lt  : Modify time

      ```
      [root@localhost ~]# ls -lt
      합계 24
      -rw-r--r--. 1 root root 1447  2월 14  2022 initial-setup-ks.cfg
      -rw-------. 1 root root 1220  2월 14  2022 anaconda-ks.cfg
      -rw-r--r--. 1 root root    9  2월 14 03:35 bbb
      -rw-r--r--. 1 root root    3  2월 14 03:31 aaa
      -rw-r--r--. 1 root root   53  2월 14 03:19 ddd
      -rw-r--r--. 1 root root    8  2월 14 03:15 ccc
      ```

    - ls -lut : Access time

      ```
      [root@localhost ~]# ls -lut
      합계 24
      -rw-r--r--. 1 root root 1447  2월 14  2022 initial-setup-ks.cfg
      -rw-------. 1 root root 1220  2월 14  2022 anaconda-ks.cfg
      -rw-r--r--. 1 root root    9  2월 14 03:35 bbb
      -rw-r--r--. 1 root root    3  2월 14 03:32 aaa
      -rw-r--r--. 1 root root   53  2월 14 03:19 ddd
      -rw-r--r--. 1 root root    8  2월 14 03:15 ccc
      ```

    - ls -lct : Change time

      ```
      [root@localhost ~]# ls -lct
      합계 24
      -rw-r--r--. 1 root root 1447  2월 14  2022 initial-setup-ks.cfg
      -rw-------. 1 root root 1220  2월 14  2022 anaconda-ks.cfg
      -rw-r--r--. 1 root root    9  2월 14 03:35 bbb
      -rw-r--r--. 1 root root    3  2월 14 03:31 aaa
      -rw-r--r--. 1 root root   53  2월 14 03:19 ddd
      -rw-r--r--. 1 root root    8  2월 14 03:15 ccc
      ```

- **ls -i** : inode 정보 확인

  - **inode** : 파일이나 디렉토리 식별을 위한 identity number

    - inode가 다르면 다른 파일

    - 파일 이름이 달라도 inode가 같다면 같은 파일

      ```
      [root@localhost ~]# ls -i
      69239106 aaa              68392070 bbb  69239119 ddd
      67157637 anaconda-ks.cfg  69239117 ccc  68392072 initial-setup-ks.cfg
      ```

- **ls -F** : 속성 확인

  ```
  [root@localhost ~]# ls -F
  aaa  anaconda-ks.cfg  bbb  ccc  ddd  initial-setup-ks.cfg
  ```

- **ls -A** : . 와 .. 을 제외하고 출력

```
[root@localhost ~]# ls -A
.bash_history  .cache   .xauthjh3PNe     ccc
.bash_logout   .cshrc   aaa              ddd
.bash_profile  .dbus    anaconda-ks.cfg  initial-setup-ks.cfg
.bashrc        .tcshrc  bbb
```



<br>

<br>

<h2>cat</h2>

- conCATenate의 약자로, **파일 내용을 화면에 보여준다**. 여러 개의 파일을 나열하면 파일을 연결해서 보여준다.
- ASCII text 파일만 여러볼 수 있다.

```
[root@localhost ~]# cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
halt:x:7:0:halt:/sbin:/sbin/halt
mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
operator:x:11:0:operator:/root:/sbin/nologin
games:x:12:100:games:/usr/games:/sbin/nologin
ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
nobody:x:65534:65534:Kernel Overflow User:/:/sbin/nologin
....
```

- **cat -n: ** 라인 넘버와 함께 보여준다.

```
[root@localhost ~]# cat -n /etc/passwd
1  root:x:0:0:root:/root:/bin/bash
2  bin:x:1:1:bin:/bin:/sbin/nologin
3  daemon:x:2:2:daemon:/sbin:/sbin/nologin
4  adm:x:3:4:adm:/var/adm:/sbin/nologin
5  lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
6  sync:x:5:0:sync:/sbin:/bin/sync
7  shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
8  halt:x:7:0:halt:/sbin:/sbin/halt
9  mail:x:8:12:mail:/var/spool/mail:/sbin/nologin
10  operator:x:11:0:operator:/root:/sbin/nologin
11  games:x:12:100:games:/usr/games:/sbin/nologin
12  ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
13  nobody:x:65534:65534:Kernel Overflow User:/:/sbin/nologin
14  dbus:x:81:81:System message bus:/:/sbin/nologin
15  systemd-coredump:x:999:997:systemd Core Dumper:/:/sbin/nologin
....
```

<br>

<br>

<h2>more</h2>

- 텍스트 형식으로 작성된 **파일을 페이지 단위로 화면에 출력**한다. 
- 스페이스 바(space bar)를 누르면 다음 페이지로 이동하며 B를 누르면 앞 메이지로 이동한다.
- Q를 누르면 종료

```
[root@localhost ~]# more /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
....
pulse:x:171:171:PulseAudio System Daemon:/var/run/pulse:/sbin/nologin
libstoragemgmt:x:995:989:daemon account for libstoragemgmt:/var/run/lsm
:/sbin/nologin
qemu:x:107:107:qemu user:/:/sbin/nologin
--More--(46%)
```

<br>

<br>

<h2>less</h2>

- more 명령과 용도가 비슷하지만 기능이 더 확장되어있다.
- more에서 사용하는 키도 사용할 수 있으며 추가로 화살표 키나 "page up", "page down" 키도 사용할 수 있다.
- **파일과 디렉토리를 모두 볼 수 있지만**, less 명령어는 **more에 비해서 무거우며 오류가 발생할 수 있다.**
  - 명령의 결과를 다른 변수에 담아서 처리하는 형태의 프로그래밍의 경우, 오류가 더욱 발생할 수 있다.

```
[root@localhost ~]# less /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
.............
```

- '+' 와 함께 사용하기 : 예시(100행부터 출력)

```
[root@localhost ~]# less +100 /etc/passwd
```

- 파이프라인(|)과 함께 사용하기

  - **파이프라인(pipeline)은 앞의 선행 프로세스 결과를 후행 프로세스의 입력으로 넣어준다.**

  ```
  [root@localhost ~]# ls -al /etc | more
  합계 1376
  drwxr-xr-x. 139 root root      8192  2월 14  2022 .
  dr-xr-xr-x.  17 root root       224  2월 14 06:43 ..
  -rw-------.   1 root root         0  2월 14 06:44 .pwd.lock
  -rw-r--r--.   1 root root       208  2월 14 06:43 .updated
  -rw-r--r--.   1 root root      4536  4월 26  2020 DIR_COLORS
  -rw-r--r--.   1 root root      5214  4월 26  2020 DIR_COLORS.256color
  ....
  ```

  <br><br>

<h2>head와 tail</h2>

- **head**: 텍스트 형식으로 작성된 파일의 앞에서 n번째 줄 또는 n 번째 줄까지 나열

- 예시: 위에서 5번째 줄까지만 출력

```
[root@localhost ~]# head -5 /etc/passwd
root:x:0:0:root:/root:/bin/bash
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
```

- **tail**: 텍스트 형식을 작성된 파일의 뒤에서 n번째 줄 또는 n 번째 줄 까지 나열
- **tail -f a** : a파일의 변화를 **모니터링**한다.
- 예시: 뒤에서 5번째 줄까지만 출력 ( - 활용)

```
[root@localhost ~]# tail -5 /etc/passwd
gnome-initial-setup:x:976:975::/run/gnome-initial-setup/:/sbin/nologin
sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin
rngd:x:975:974:Random Number Generator Daemon:/var/lib/rngd:/sbin/nologin
tcpdump:x:72:72::/:/sbin/nologin
user:x:1000:1000:user:/home/user:/bin/bash
```

- 예시: 41번째 줄부터 출력  ( + 활용)

```
[[root@localhost ~]# tail -n +41 /etc/passwd
gdm:x:42:42::/var/lib/gdm:/sbin/nologin
clevis:x:977:976:Clevis Decryption Framework unprivileged user:/var/cache/clevis:/sbin/nologin
gnome-initial-setup:x:976:975::/run/gnome-initial-setup/:/sbin/nologin
sshd:x:74:74:Privilege-separated SSH:/var/empty/sshd:/sbin/nologin
rngd:x:975:974:Random Number Generator Daemon:/var/lib/rngd:/sbin/nologin
tcpdump:x:72:72::/:/sbin/nologin
user:x:1000:1000:user:/home/user:/bin/bash
```

- **-n num** : num 수 만큼 출력한다. 
- head와 tail 모두 **default는 10줄**이다.
- **cat과 head를 파이프라인으로 연결**해보기 : number와 함께 5번째 줄까지 출력

```
[root@localhost ~]# cat -n /etc/passwd | head -5
     1  root:x:0:0:root:/root:/bin/bash
     2  bin:x:1:1:bin:/bin:/sbin/nologin
     3  daemon:x:2:2:daemon:/sbin:/sbin/nologin
     4  adm:x:3:4:adm:/var/adm:/sbin/nologin
     5  lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
```

- 문제 1: /etc/passwd 는 47라인으로 구성되어있다. 이중 10번째 라인부터 20번재 라인까지만 출력하시오. (힌트: 파이프라인, cat, tail, head의 교섭 구간, 답은 여러가지 가능)

```
[root@localhost ~]# cat -n /etc/passwd | tail -n +10 | head -11
    10  operator:x:11:0:operator:/root:/sbin/nologin
    11  games:x:12:100:games:/usr/games:/sbin/nologin
    12  ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
    13  nobody:x:65534:65534:Kernel Overflow User:/:/sbin/nologin
    14  dbus:x:81:81:System message bus:/:/sbin/nologin
    15  systemd-coredump:x:999:997:systemd Core Dumper:/:/sbin/nologin
    16  systemd-resolve:x:193:193:systemd Resolver:/:/sbin/nologin
    17  tss:x:59:59:Account used by the trousers package to sandbox the tcsd daemon:/dev/null:/sbin/nologin
    18  polkitd:x:998:996:User for polkitd:/:/sbin/nologin
    19  geoclue:x:997:995:User for geoclue:/var/lib/geoclue:/sbin/nologin
    20  rtkit:x:172:172:RealtimeKit:/proc:/sbin/nologin
```

```
[root@localhost ~]# cat -n /etc/passwd | head -n +20 | tail -n +10
    10  operator:x:11:0:operator:/root:/sbin/nologin
    11  games:x:12:100:games:/usr/games:/sbin/nologin
    12  ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
    13  nobody:x:65534:65534:Kernel Overflow User:/:/sbin/nologin
    14  dbus:x:81:81:System message bus:/:/sbin/nologin
    15  systemd-coredump:x:999:997:systemd Core Dumper:/:/sbin/nologin
    16  systemd-resolve:x:193:193:systemd Resolver:/:/sbin/nologin
    17  tss:x:59:59:Account used by the trousers package to sandbox the tcsd daemon:/dev/null:/sbin/nologin
    18  polkitd:x:998:996:User for polkitd:/:/sbin/nologin
    19  geoclue:x:997:995:User for geoclue:/var/lib/geoclue:/sbin/nologin
    20  rtkit:x:172:172:RealtimeKit:/proc:/sbin/nologin
```

```
[root@localhost ~]# cat -n /etc/passwd | head -n 20 | tail
    11  games:x:12:100:games:/usr/games:/sbin/nologin
    12  ftp:x:14:50:FTP User:/var/ftp:/sbin/nologin
    13  nobody:x:65534:65534:Kernel Overflow User:/:/sbin/nologin
    14  dbus:x:81:81:System message bus:/:/sbin/nologin
    15  systemd-coredump:x:999:997:systemd Core Dumper:/:/sbin/nologin
    16  systemd-resolve:x:193:193:systemd Resolver:/:/sbin/nologin
    17  tss:x:59:59:Account used by the trousers package to sandbox the tcsd daemon:/dev/null:/sbin/nologin
    18  polkitd:x:998:996:User for polkitd:/:/sbin/nologin
    19  geoclue:x:997:995:User for geoclue:/var/lib/geoclue:/sbin/nologin
    20  rtkit:x:172:172:RealtimeKit:/proc:/sbin/nologin
```

 일단 맨 앞 20줄을 출력하라

그리고 그 결과를 입력으로 넣고, 뒤에서 10줄만 출력하라(tail의 default가 10이므로)

- 문제 2: /etc/passwd 에서 10번째 라인만 출력하라.

```
[root@localhost ~]# head -10 /etc/passwd | tail -1
operator:x:11:0:operator:/root:/sbin/nologin
```

<br><br>

<h2>grep</h2>

- 텍스트 파일에서 **원하는 문자열이 들어간 행을 찾아 출력**하는 명령어
- 주로 log파일에서 특정 날짜, 문자로 기록된 **error 메시지를 찾는데 유용**하게 사용
- 예시: root가 들어간 파일 찾기

```
[root@localhost ~]# grep root /etc/passwd
root:x:0:0:root:/root:/bin/bash
operator:x:11:0:operator:/root:/sbin/nologin
```

- 예시: root로 시작하는 파일 찾기

```
[root@localhost ~]# grep ^root /etc/passwd
root:x:0:0:root:/root:/bin/bash
```

- 예시: bash로 끝나는 파일 찾기

```
[root@localhost ~]# grep bash$ /etc/passwd
root:x:0:0:root:/root:/bin/bash
user:x:1000:1000:user:/home/user:/bin/bash
```

- **grep -l** : 문자가 들어간 파일이름을 출력

```
[root@localhost ~]# grep -l root /etc/passwd
/etc/passwd
```

```
[root@localhost ~]# grep -l umask /etc/*  2> /dev/null
/etc/bashrc
/etc/csh.cshrc
/etc/login.defs
/etc/profile
```

- **grep -n** : -n : 줄의 번호와 내용을 같이 출력

```
[root@localhost ~]# grep -n root /etc/passwd
1:root:x:0:0:root:/root:/bin/bash
10:operator:x:11:0:operator:/root:/sbin/nologin
```

- **grep -i** : 대소문자를 구분하지 않는다.

```
[root@localhost ~]# grep -i ROOT /etc/passwd
root:x:0:0:root:/root:/bin/bash
operator:x:11:0:operator:/root:/sbin/nologin
```

- **grep -v** : 문자가 포함되지 않는 행 출력

```
[root@localhost ~]# grep -v bash /etc/passwd
bin:x:1:1:bin:/bin:/sbin/nologin
daemon:x:2:2:daemon:/sbin:/sbin/nologin
adm:x:3:4:adm:/var/adm:/sbin/nologin
lp:x:4:7:lp:/var/spool/lpd:/sbin/nologin
sync:x:5:0:sync:/sbin:/bin/sync
shutdown:x:6:0:shutdown:/sbin:/sbin/shutdown
halt:x:7:0:halt:/sbin:/sbin/halt
....
```

- 예시: root가 들어가고 bash가 들어가지 않은 파일들을 번호를 붙여서 출력

```
[root@localhost ~]# grep -n root /etc/passwd | grep -v bash
10:operator:x:11:0:operator:/root:/sbin/nologin
```

<br><br>

<h2>touch</h2>

- 0 byte의 파일을 생성하는 명령어

```
[root@localhost ~]# touch aaa
[root@localhost ~]# ls -l aaa
-rw-r--r--. 1 root root 3  2월 14 07:46 aaa
```

```
[root@localhost ~]# touch aaa
[root@localhost ~]# ls -l aaa
-rw-r--r--. 1 root root 0  2월 14 12:07 aaa
[root@localhost ~]# date

2022. 2. 14. (월) 12:07:41 EST

[root@localhost ~]# date

2022. 2. 14. (월) 12:08:01 EST
             [root@localhost ~]#
             [root@localhost ~]# ls -l aaa
             -rw-r--r--. 1 root root 0  2월 14 12:07 aaa
             [root@localhost ~]# date
2022. 2. 14. (월) 12:08:32 EST
             [root@localhost ~]# touch aaa      <--- 기존에 존재하는 파일 또는 디렉토리를 touch 하면 현재 시간으로 동기화 해줌
             [root@localhost ~]# ls -lt aaa
             -rw-r--r--. 1 root root 0  2월 14 12:08 aaa
             [root@localhost ~]# ls -lut aaa
             -rw-r--r--. 1 root root 0  2월 14 12:08 aaa
             [root@localhost ~]# ls -lct aaa
             -rw-r--r--. 1 root root 0  2월 14 12:08 aaa
```

- 기존에 존재하는 파일 또는 디렉토리를 touch하면 현재 시간으로 동기화해준다. 

<br><br>

<h2>echo</h2>

- 표준화면에 출력하는 명령어

```
[root@localhost ~]# echo hi
hi
[root@localhost ~]# echo hahaha
hahaha
```

<br><br>

<h2>>, >>를 이용한 파일 생성</h2>

- '>' : 파일 생성, 이미 존재하면 overwrite된다(덮어진다.) 따라서 매우 주의해서 사용해야함
- '>>' : append : 파일에 추가해준다.

- 예시: 'hi'가 입력된 bbb파일을 생성후 출력해 확인

```
[root@localhost ~]# echo hi > bbb
[root@localhost ~]# cat bbb
hi
```

- 예시: 'hi'가 입력된 bbb파일에 'hahaha' append(추가) 후 출력해 확인

```
[root@localhost ~]# echo hahaha >> bbb
[root@localhost ~]# cat bbb
hi
hahaha
```

<br><br>



<h2>참고사항</h2>

- **/dev/null 의 의미**
  - **표준 출력을 /dev/null로 redirection**
- **2 >&1 의 의미.**
  - n >&m: 표준출력과 표준에러를 서로 바꾸기
  - 0, 1, 2는 각각 표준입력, 표준출력, 그리고 표준에러를 의미
  - 2>&1의 의미는 **표준 출력의 전달되는 곳으로 표준에러를 전달**하라라는 의미
- **/dev/null 2>&1 의 의미**
  - **표준에러를 표준출력으로 redirection 하라는 의미**
  -  /dev/null로 버리는데, 표준에러는 표준출력으로 redirection 한다.
  - 결국 결과는 표준출력이 되기 때문에 /dev/null로 버려지고, **화면에 결과가 뿌려지지 않게 되는 것**입니다.
