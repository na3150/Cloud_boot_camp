<h1>Linux 시스템 명령어 모음 (2)</h1>

<br>



<h3>📌INDEX</h3>

- [hostname](#hostname)
- [uname](#uname)
-  [stat](#stat)
-  [find](#find)
-  [참고: exec, xargs, sort](#참고)

<br><br>

<h2>hostname</h2>

- **시스템의 이름을 확인하거나 바꿀 때 사용**하는 명령어
- 사용법: hostname [옵션]... FILE

```shell
[root@localhost ~]# hostname
localhost.localdomain
```

- 옵션
  - -a : 별칭명을 출력
  - -d : 도메인 명을 출력
  - -i : 호스트의 ip주소를 출력
  - 등등



<br><br>

<h2>uname</h2>

- **시스템의 정보를 확인**하는 명령어
- 옵션을 지정하지 않으면 -s 옵션이 default

```shell
[root@localhost ~]# uname
Linux
```

- 옵션
  - -a : 모든 시스템 정보를 출력
  - -s : 커널 이름을 출력
  - -n : 네트워크 호스트네임을 출력
  - -r : 커널의 릴리스 버전을 출력
  - -v : 커널 버전을 출력
  - -m : 시스템의 하드웨어 아키텍처를 출력
  - -p : 프로세스타입을 출력, 확인할 수 없는 경우 unknown 출력
  - -i : 하드웨어 플랫폼 정보를 출력
  - -o : 운영체제 이름을 출력

<br><br>

<h2>stat</h2>

- **디렉터리나 파일의 상세 정보를 출력**하는 명령어
- 사용법: stat [옵션] [파일명]

```shell
[root@localhost ~]# ls -li aaa
69239132 -rw-r--r--. 1 root root 2658  2월 15 22:53 aaa
[root@localhost ~]# stat aaa
  File: aaa
  Size: 2658            Blocks: 8          IO Block: 4096   일반 파일
Device: 10303h/66307d   Inode: 69239132    Links: 1
Access: (0644/-rw-r--r--)  Uid: (    0/    root)   Gid: (    0/    root)
Context: unconfined_u:object_r:admin_home_t:s0
Access: 2022-02-15 22:53:03.649898358 -0500
Modify: 2022-02-15 22:53:03.649898358 -0500
Change: 2022-02-15 22:53:03.650898363 -0500
 Birth: -
```

```shell
[root@localhost ~]# stat ccc
  File: ccc -> aaa
  Size: 3               Blocks: 0          IO Block: 4096   심볼릭 링크
Device: 10303h/66307d   Inode: 69239119    Links: 1
Access: (0777/lrwxrwxrwx)  Uid: (    0/    root)   Gid: (    0/    root)
Context: unconfined_u:object_r:admin_home_t:s0
Access: 2022-02-15 23:49:37.255377381 -0500
Modify: 2022-02-15 23:49:23.760314941 -0500
Change: 2022-02-15 23:49:23.760314941 -0500
 Birth: -
```



- 옵션

  - -L : 심볼릭 링크를 역 참조하여 정보 출력
  - -f : 해당 파일이 저장된 파일 시스템의 정보를 출력
  - -c : 사용자 정의 형식으로 정보를 출력 -> format sequence를 붙여 활용
  - -t : 디렉터리나 파일 정보를 요약하여 출력

- Format Sequence : -c 옵션을 이용하여 사용자 정의를 할 때 필요한 포맷들

  - %a : 8진수로 된 파일 권한

  ```shell
  [root@localhost ~]# stat -c %A aaa
  -rw-r--r--
  ```

  | %a   | 8진수로 된 파일 권한                                         |
  | ---- | ------------------------------------------------------------ |
  | %A   | 일반 rwx 형식의 파일 권한                                    |
  | %b   | 할당된 블록 수                                               |
  | %B   | 각 블록의 크기 (바이트 단위)                                 |
  | %d   | 10진수로 된 장치 번호                                        |
  | %D   | 16진수로 된 장치 번호                                        |
  | %f   | 16진수로 된 파일 유형                                        |
  | %F   | 파일 유형                                                    |
  | %g   | 소유자의 그룹 ID                                             |
  | %G   | 소유자의 그룹 이름                                           |
  | %h   | 하드 링크 개수                                               |
  | %i   | inode 번호                                                   |
  | %m   | 마운트 포인트                                                |
  | %n   | 파일 이름                                                    |
  | %N   | 심벌릭 링크일 경우 역 참조된 파일 이름                       |
  | %s   | 파일의 총 크기 (바이트 단위)                                 |
  | %u   | 소유자의 사용자 ID                                           |
  | %U   | 소유자의 사용자 이름                                         |
  | %w   | 파일 생성 시간 (존재하지 않다면 -로 표시)                    |
  | %x   | 파일 접근 시간 (Access)                                      |
  | %y   | 파일 수정 시간 (Modification - 파일 내용이 수정)             |
  | %z   | 파일 변경 시간 (Change - 파일 권한, 퍼미션과 같은 속성 변경) |



<br><br>

<h2>⭐find⭐</h2>

- **파일 및 디렉토리를 검색할 때 사용**하는 명령어
- 몇 가지 옵션과 수많은 표현식(Expression) 존재
- fine 명령어는 다른 명령어와는 달리, 옵션은 거의 사용되지 않고, 표현식을 통해 찾을 타깃을 정한다. 
- 표현식은 중첩을 통해 대상 범위를 줄일 수 있다.
- 사용법: find [option] [path] [expression]
- 옵션
  - -P : 심볼릭 링크를 따라가지 않고, 심볼릭 링크 자체 정보 사용
  - -L : 심볼릭 링크에 연결된 파일 정보 사용
  - -H : 심볼릭 링크를 따라가지 않으나, Command Line Argument를 처리할 땐 예외
  - -D : 디버그 메세지 출력
- Expression(표현식)
  - -name : 지정된 문자열 패턴에 해당하는 파일 검색(iname은 대소문자 구분x)
  - -type : 지정된 파일 타입에 해당하는 파일 검색
  - -inum : inode 넘버로 해당하는 파일 검색
  - -samefile : 같은 파일 검색
  - -perm : 퍼미션으로 파일 검색
  - -size : 파일 크기를 사용하여 파일 검색(-n : n 이하 크기, +n: n 이상 크기)
  - -empty : 빈 디렉토리 또는 크기가 0인 파일 검색
  - -delete : 검색된 파일 또는 디렉토리 삭제
  - -exec : 검색된 파일에 대해 지정된 명령 실행
  - -path : 지정된 문자열 패턴에 해당하는 경로에서 검색
  - -print : 검색 결과를 출력. 검색 항목은 newline으로 구분. (기본 값)
  - -print0 : 검색 결과를 출력. 검색 항목은 null로 구분
  - -mindepth : 검색을 시작할 하위 디렉토리 최소 깊이 지정
  - -maxdepth : 검색할 하위 디렉토리의 최대 깊이 지정
  - -atime : n일 이내에 액세스된 파일을 찾음
  - -ctime : n일 이내에 만들어진 파일을 찾음
  - -mtime : n일 이내에 수정된 파일을 찾음
  - -mmin : n분 이내에 수정된 파일을 찾음(+mmin: n분 보다 오래전에 수정된 파일)
  - -cnewer file : 해당 파일보다 최근에 수정된 파일을 찾음
  - -user : 사용자명을 사용하여 검색
- 예시: 이름이 aaa인 것을 찾는다.

```shell
[root@localhost ~]# find / -name aaa
/root/kbs/mbc/aaa
/root/kbs/aaa
/root/aaa
/home/user/kbs/aaa
/tmp/aaa
```

- type을 파일(file)이고, 이름이 aaa인 것을 찾는다

```shell
[root@localhost ~]# find /root -type f -name aaa
/root/kbs/mbc/aaa
/root/kbs/aaa
/root/aaa
```

- type을 파일(file)이고, 이름이 대소문자 구분없이 AaA이고, 사용자는 관계 X

```shell
[root@localhost ~]#  find /root -type f -iname AaA -user 0
/root/kbs/mbc/aaa
/root/kbs/aaa
/root/aaa
```

- type이 파일이고, 이름이 aa로 시작하는 것을 찾아라

```shell
[root@localhost ~]# find /root -type f -name aa*
/root/kbs/mbc/aaa
/root/kbs/aaa
/root/aaa
```

- aaa와 같은 파일을 찾아라 (하드링크로 연결)

```shell
[root@localhost ~]# ln aaa bbb
[root@localhost ~]# find /root -samefile aaa
/root/bbb
/root/aaa
```

- inode 넘버가 69239132인 것을 찾아라

```shell
[root@localhost ~]# find /root -inum 69239132
/root/aaa
```

- 퍼미션(권한) 넘버가 777인 파일(file)을 찾아라
  - chmod와 퍼미션 관련 내용은 추후 업로드 예정

```shell
[root@localhost ~]# chmod 777 aaa
[root@localhost ~]# find /root -type f -perm 777
/root/aaa
```

- type이 file이고, o(other)의 권한에 x(실행) 권한이 있는 파일을 찾아라

```shell
[root@localhost ~]# find . -type f  -perm /o=x -ls
 67285833     20 -rwxr-xr-x   1  root     root   17528  2월 16 01:30 ./sample
 69239132      4 -rwxrwxrwx   1  root     root   2658  2월 15 22:53 ./aaa
```

- type이 file이고, 1일 이내에 수정된 파일을 찾아라

```shell
[root@localhost ~]# find /root -type f  -mtime -1
/root/anaconda-ks.cfg
/root/.cache/dconf/user
/root/.cache/gnome-shell/update-check-3.32
/root/.cache/tracker/db-version.txt
```

- type이 file이고, 60분 이내에 수정된 파일을 찾아라.

```shell
[root@localhost ~]# find /root -type f -mmin -60
/root/.cache/tracker/meta.db
/root/.cache/tracker/meta.db-wal
/root/.cache/tracker/meta.db-shm
/root/.local/share/gvfs-metadata/root
/root/.local/share/gvfs-metadata/root-2e7b231c.log
/root/.local/share/tracker/data/tracker-store.journal
```

- type이 file이고, 크기가 50이상 100이하인 파일을 찾아라. 그리고 검색 결과  출력

```shell
[root@localhost ~]# find . -type f -size +50  -size -100  -print
./.cache/tracker/meta.db-shm
./.cache/mozilla/firefox/pxtt36so.default-default/cache2/entries/96A3A367708E3D055E8AAFD2CC426BD24476E19E
./.cache/mozilla/firefox/pxtt36so.default-default/cache2/entries/E34CCF2F421FB2762468857BBB9C7CF2AC2FBB09
./.config/pulse/40adb6651b7a4ddd8acccc50129a93f5-card-database.tdb
./.local/share/gvfs-metadata/home-21f9616f.log
./.local/share/gvfs-metadata/root-2e7b231c.log
./.mozilla/firefox/pxtt36so.default-
...
```

<br><br>

<h2>참고</h2>

- **-exec**

  - **앞선 명령어의 결과를 입력으로 받아 " \; " 라는 표기자를 만날 때까지 읽고 실행**
  - '+' 옵션은 인자를 연속으로 입력해서 커맨드 한번으로 실행하게끔 해줌

  - 리눅스에서 **반복하기**

  ```shell
  -exec [반복할 구간] {} \;
  ```

  - 예시

```shell
[root@localhost ~]# find /etc -type f -exec ls -s {} \; | sort -n -r | head -5
9124 /etc/udev/hwdb.bin
8652 /etc/selinux/targeted/policy/policy.31
700 /etc/brltty/Contraction/zh-tw.ctb
680 /etc/services
564 /etc/ssh/moduli
```

```shell
[root@localhost ~]# find /etc -type f  -exec grep -l umask  {} \;
/etc/X11/xinit/Xsession
/etc/lvm/lvm.conf
/etc/bashrc
/etc/login.defs
/etc/csh.cshrc
/etc/profile
/etc/rc.d/init.d/functions
/etc/authselect/postlogin
/etc/udisks2/mount_options.conf.example
```

```shell
[root@localhost ~]# find / -inum 68430434 -exec cp {} /tmp \;
[root@localhost ~]# ls /tmp
aaa
bbb
......
```

-> inum이 68430434 인 것을 찾아서 모두 tmp에 복사해 넣어라

```shell
[root@localhost ~]# find / -inum 68430434 | xargs tar cvf ab.tar
tar: 구성 요소 이름 앞에 붙은 `/' 제거 중
/root/aaa
tar: 하드 링크 대상 앞에 붙은 `/' 제거 중
/root/bbb
[root@localhost ~]# ls
aaa     anaconda-ks.cfg  ccc                   jjj   mbc       공개      문서      비디오  서식
ab.tar  bbb              initial-setup-ks.cfg  kbs2  testdir1  다운로드  바탕화면  사진    음악
[root@localhost ~]# tar -tf ab.tar
root/aaa
root/bbb
[root@localhost ~]#
```

-> inum이 68430434  인 것을 찾아 ab.tar 하나의 파일로 만들어라

     
- **-xargs**
  - exec 커맨드의 + 옵션과 유사
  - **앞선 명령어의 결과를 입력으로 받아 인자를 연속으로 나열하여 커맨드를 실행**함
  - 바로 윗 예시 참조

- **sort**
  - 사용자가 **지정한 파일의 내용을 정렬**하거나 **정렬된 파일의 내용을 병합**할 때 사용
  - 옵션
    - -r : 역순으로 정렬
    - -k : 정해진 필드를 기준으로 정렬
    - -u : 정렬 후 중복된 내용을 제거
    - -f : 대소문자를 구분하지 않고 정렬
