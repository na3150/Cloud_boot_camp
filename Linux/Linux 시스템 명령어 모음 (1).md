<h1>Linux 시스템 명령어 모음 (1)</h1> 



<h3>📌INDEX</h3>

- [uptime](#uptime)
- 메모리 사용량 관련
  - [free](#free)
  - [top](#top)
- [PID와 task](#pid와-task)

- [who](#who)
-  [pstree](#pstree)

- [df](#df)
- [du](#du)


<br><br>
<h2>uptime</h2>

- 리눅스 시스템이 언제 시작되었으며, 총 얼마 동안 가동되었는지 파악할 수 있는 명령어

- [**현재 시간, 시스템이 실행된 시간, 현재 로그인한 사용자 수, (CPU 평균값) 지난 1분, 5분, 15분 동안의 시스템 로드 평균**]을 한 줄로 표시
  - 현재 시각
  - 활성화된 날로 부터 지난 일 수
  - 활성화된 날로 부터 지난 시간
  - 현재 로그인 된 사용자 수
  - 현재 시스템 부하상태

```shell
[root@localhost ~]# uptime
 08:23:52 up 1 day, 54 min,  3 users,  load average: 0.01, 0.01, 0.00
```

- w 명령어로 출력되는 내용의 첫 줄과 같다
- **-s** : 시스템 시작 시간을 알 수 있다.

```shell
[root@localhost ~]# uptime -s
2022-02-14 07:28:57
```



<br><br>



<h2>free</h2>

- **전체 메모리(사용하고 있는 메모리, 남은 메모리, 버퍼 메모리)에 대한 상태확인**
- 시스템의 실제 메모리와 스왑메모리에 대한 사용 현황 확인 가능

```shell
[root@localhost ~]# free
              total        used        free      shared  buff/cache   available
Mem:        1832972     1226588      133456       21264      472928      398052
Swap:       2097148      473856     1623292
```

<details><summary>세부 정보 필드별 항목</summary>
<div markdown="2"><br>
▪️ [total] : 설치된 총 메모리 크기 / 설정된 스왑 총 크기<br><br>
▪️ [used] : total에서 free, buff/cache를 뺀 사용중인 메모리. / 사용중인 스왑 크기<br><br>
▪️ [free] : total에서 used와 buff/cahce를 뺀 실제 사용 가능한 여유 있는 메모리량 / 사용되지 않은 스왑 크기<br><br>
▪️ [shared] : tmpfs(메모리 파일 시스템), ramfs 등으로 사용되는 메모리. 여러 프로세스에서 사용할 수 있는 공유 메모리<br><br>
▪️ [buffers] : 커널 버퍼로 사용중인 메모리<br><br>
▪️ [cache] : 페이지 캐시와 slab으로 사용중인 메모리<br><br>
▪️ [buff/cache] : 버퍼와 캐시를 더한 사용중인 메모리<br><br>
▪️ [available] : swapping 없이 새로운 프로세스에서 할당 가능한 메모리의 예상 크기. (예전의 -/+ buffers/cache이 사라지고 새로 생긴 컬럼<br><br>
</div></details>

- 옵션
  - **-h :** 사람이 읽기 쉬운 단위로 출력한다.
  - **-b | -k | -m | -g :** 바이트, 키비바이트, 메비바이트, 기비바이트 단위로 출력
  - **--tebi | --pebi :** 테비바이트, 페비바이트 단위로 출력
  - **--kilo | --mega | --giga | --tera | --peta :** 킬로바이트, 메가바이트, 기기바이트, 페타바이트 단위로 출력한다.
  - **-w :** 와이드 모드로 cache와 buffers를 따로 출력한다.
  - **-c [반복횟수] :** 지정한 반복 횟수 만큼 free를 연속해서 실행
  - **-s [초] :** 지정한 초 만큼 딜레이를 두고 지속적으로 실행
  - **-t :** 합계가 계산된 total 컬럼줄을 추가로 출력



<br><br>

<h2>top</h2>

- **시스템의 상태를 전반적으로 가장 빠르게 파악** 가능(CPU, Memory, Process)
  - 실시간으로  CPU 사용률을 체크
- 옵션 없이 입력하면, interval 간격(기본 3초)으로 화면을 갱신하며 정보를 보여줌

```shell
[root@localhost ~]# top
top - 08:36:02 up 1 day,  1:07,  3 users,  load average: 0.00, 0.00,
Tasks: 283 total,   3 running, 280 sleeping,   0 stopped,   0 zombie
%Cpu(s):  1.0 us,  0.0 sy,  0.0 ni, 99.0 id,  0.0 wa,  0.0 hi,  0.0 s MiB Mem :   1790.0 total,    129.1 free,   1198.7 used,    462.2 buff
MiB Swap:   2048.0 total,   1585.2 free,    462.8 used.    387.9 avai

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM
  14297 root      20   0  213896  33080   6248 S   0.7   1.8
    782 root      20   0  368912   7580   5984 R   0.3   0.4
   5499 gnome-i+  20   0 2664628  66484  14932 S   0.3   3.6
   5975 user      20   0 2995900 218940  28816 S   0.3  11.9
      1 root      20   0  245828   8964   5464 S   0.0   0.5
      2 root      20   0       0      0      0 S   0.0   0.0
      3 root       0 -20       0      0      0 I   0.0   0.0
      4 root       0 -20       0      0      0 I   0.0   0.0
      6 root       0 -20       0      0      0 I   0.0   0.0
      9 root       0 -20       0      0      0 I   0.0   0.0
     10 root      20   0       0      0      0 S   0.0   0.0
     11 root      20   0       0      0      0 R   0.0   0.0
     12 root      rt   0       0      0      0 S   0.0   0.0
     13 root      rt   0       0      0      0 S   0.0   0.0
     14 root      20   0       0      0      0 S   0.0   0.0
     16 root      20   0       0      0      0 S   0.0   0.0
     17 root       0 -20       0      0      0 I   0.0   0.0
```

<details><summary>세부 정보 필드별 항목</summary>
<div markdown="1"><br>
    PID USER  PR  NI  VIRT  RES  SHR S %CPU %MEM  TIME+  COMMAND<br>
    ▪️ PID : 프로세스 ID (PID)<br><br>
    ▪️ USER : 프로세스를 실행시킨 사용자 ID<br><br>
    ▪️ PRI : 프로세스의 우선순위 (priority)<br><br>
    ▪️ NI : NICE 값. 일의 nice value값이다. 마이너스를 가지는 nice value는 우선순위가 높음.<br><br>
    ▪️ VIRT : 가상 메모리의 사용량(SWAP+RES)<br><br>
    ▪️ RES : 현재 페이지가 상주하고 있는 크기(Resident Size)<br><br>
    ▪️ SHR : 분할된 페이지, 프로세스에 의해 사용된 메모리를 나눈 메모리의 총합.<br><br>
    ▪️ S : 프로세스의 상태 [ S(sleeping), R(running), W(swapped out process), Z(zombies) ]<br><br>
    ▪️ %CPU : 프로세스가 사용하는 CPU의 사용율<br><br>
    ▪️ %MEM : 프로세스가 사용하는 메모리의 사용율<br><br>
    ▪️ TIME+ : 프로세스 시작된 이후 경과된 총 시간<br><br>
    ▪️ COMMAND : 실행된 명령어<br><br>
    ▪️ Load average (로드 애버리지) : 세 개의 숫자는 각각 1분, 5분, 15분 간의 평균 실행/대기 중인 프로세스의 수를 나타냄.<br>
  uptime 명령어로도 확인할 수 있으며, 시스템 부하를 모니터링 할 수 있다. 숫자가 높을 수록 시스템에 부하가 있다는 것이다.<br>
  load average 값은 CPU의 코어 수를 같이 확인해야 하며, 코어 수 보다 적으면 문제가 없다.<br>
</div></details>

- 옵션
  - -a : 메모리 사용에 따라 정렬
  - -b : 배치 모드에서 시작
  - -c : 명령어 대신 명령어 라인을 보여줌
  - -d : 업데이트 간격을 조정
  - -M : 메모리 유닛(K/M/G)을 보여줌
  - -s : 보안 모드로 시작

<br><br>

<h2>PID와 task</h2>

- **PID** : 운영체제에서 프로세스를 식별하기 위해 **프로세스에 부여하는 번호**
  - 스레드 1개당, 프로그램 하나 당
  - 확인하기 위해서는 ps 명령어 사용

```shell
[root@localhost ~]# ps -A -o pid
    PID
      1
      2
      3
      4
      6
      9
     10
     11
     12
     13
     ....
```

- **task** : 말 그대로 **실행(Execution)**

  - 특정 코드나 프로그램 실행을 **일괄 처리한 실행 및 작업 단위**
  - 같이 동작하는 스레드를 여러개  합쳐서(단위로)
  - 하나의 태스크(task)는 PID넘버가 하나 이상

- 작업 관리자를 통해 알아보기(Chrome)

  - Chrome 창 25개가 실행되고 있지만, 여기서 task는 진하게 표시된 **Chrome 실행 단위** 한개로 본다.

  <img src="https://user-images.githubusercontent.com/64996121/154080267-5bdd974a-a758-4d58-80a4-c8a7c27ff614.PNG" width="400" height="250" />


  - Chrome 창 25개, 각각이 **개별적인 PID**를 갖는다.

<img src="https://user-images.githubusercontent.com/64996121/154080451-0fce86e0-4c1b-4c16-bbcd-0742cbef2b9c.PNG" width="400" height="250"/>



<br><br>

<h2>who</h2>

- **로그인한 사용자의 정보**를 출력하는 명령어

```shell
[root@localhost ~]# who
user     :1           2022-02-14 07:13 (:1)
user     tty3         2022-02-14 07:28
user     pts/3        2022-02-14 19:13 (192.168.238.1)
```

- 옵션
  - **-b-** :  마지막 시스템 부팅 시간을 출력
  - **-l** : 시스템 로그인 프로세스를 출력
  - **-m-** :  호스트 명과 사용자만 출력
  - 등등



<br><br>



<h2>pstree</h2>

- 프로세스의 상관 관계(부모-자식 관계)를 트리 형태로 출력해주는 명령어
- 관계를 트리 형태로 출려해주므로 계층 관계를 한 눈에 파악 가능

```shell
[root@localhost ~]# pstree
systemd─┬─ModemManager───2*[{ModemManager}]
        ├─NetworkManager───2*[{NetworkManager}]
        ├─VGAuthService
        ├─accounts-daemon───2*[{accounts-daemon}]
        ├─agetty
        ├─alsactl
        ├─atd
        ├─auditd─┬─sedispatch
        │        └─2*[{auditd}]
        ├─avahi-daemon───avahi-daemon
        ├─bluetoothd
        ├─chronyd
        ├─colord───2*[{colord}]
        ├─crond
        ├─cupsd
        ├─dbus-daemon───{dbus-daemon}
        ├─dnsmasq───dnsmasq
        ├─firewalld───{firewalld}
        ├─gdm─┬─gdm-session-wor─┬─gdm-x-session─┬─Xorg───{Xorg}
        │     │                 │               ├─gnome-session-b─┬─g+
        │     │                 │               │                 ├─g+
        │     │                 │               │                 ├─g+
        │     │                 │               │                 ├─g+
        │     │                 │               │                 ├─g+
        │     │                 │               │                 ├─g+
        │     │                 │               │
        ....
```

- 옵션
  - **-a** : 지정한 인수까지 출력
  - **-c**: 중복된 프로세스도 모두 출력, 디폴트 값은 트리 내의 동일한 프로세스를 하나의 프로세스로 출력
  - **-p** : pid도 출력
  - **-u** : uid도 출력
  - 등등

<br><br>

<h2>df</h2>

- 시스템에 마운트된 하드디스크의 남은 용량을 확인할 때 사용하는 명령어
- 기본적으로 1024 byte 블록 단위로 출력
- 옵션을 통해 다른 단위로 출력 가능

```
[root@localhost ~]# df
Filesystem     1K-blocks    Used Available Use% Mounted on
devtmpfs          887304       0    887304   0% /dev
tmpfs             916484       0    916484   0% /dev/shm
tmpfs             916484   18816    897668   3% /run
tmpfs             916484       0    916484   0% /sys/fs/cgroup
/dev/nvme0n1p3  49782020 4715848  45066172  10% /
/dev/nvme0n1p1    518816  230376    288440  45% /boot
tmpfs             183296      28    183268   1% /run/user/976
tmpfs             183296      56    183240   1% /run/user/1000
```

- 옵션
  - -h : 사람이 읽을 수 있는 형태의 크기로 출력(예:1K, 512M, 4G)
  - -H: 1,000단위로 용량을 표시
  - -l: 출력하는 목록을 로컬 파일 시스템으로 제한
  - -i:  inode의 남은 공간, 사용 공간, 사용 퍼센트를 출력
  - -P: POSIX에서 사용되는 형태로 출력
- **df -hTP** 
  - h: Size정보를 m G 단위로 변환해서 보여줌 
  - T(type):  파일 시스템 정보를 알려줌 
  - P(portability): 화면에 출력시 끊겨서 출력되는 것을 방지

```shell
[root@localhost ~]# df -hTP
Filesystem     Type      Size  Used Avail Use% Mounted on
devtmpfs       devtmpfs  867M     0  867M   0% /dev
tmpfs          tmpfs     896M     0  896M   0% /dev/shm
tmpfs          tmpfs     896M   19M  877M   3% /run
tmpfs          tmpfs     896M     0  896M   0% /sys/fs/cgroup
/dev/nvme0n1p3 xfs        48G  4.5G   43G  10% /
/dev/nvme0n1p1 xfs       507M  225M  282M  45% /boot
tmpfs          tmpfs     179M   28K  179M   1% /run/user/976
tmpfs          tmpfs     179M   56K  179M   1% /run/user/1000
```

<br><br>

<h2>du</h2>

- Disk Usage의 약자로, 현재 디렉토리 혹은 지정한 디렉토리의 사용량을 확인할 때 사용
- 옵션을 지정하지 않으면 현재 경로의 모든 디렉토리 크기를 MB단위로 출력

```
[root@localhost ~]# du
4       ./.cache/dconf
4       ./.cache
4       ./.dbus/session-bus
4       ./.dbus
0       ./.config/procps
0       ./.config
4       ./ilsan/baekma
4       ./ilsan
4       ./kbs/mbc
4       ./kbs
0       ./one/two
0       ./one
0       ./two
68      .
```

- 옵션
  - -h: 파일 용량을 사람이 보기 쉬운 형태로 출력
  - -s:  간단하게 총 사용량만 요약하여 출력
  - -x: 현재 파일 시스템의 파일 사용량만을 출력
  - -l: 하드 링크되어 있는 파일도 있는 그대로 카운트
  - 등등
- du -sh : 디렉토리의 용량 사이즈

```
[root@localhost ~]# du -sh /etc
29M     /etc
```

```
[root@localhost ~]# du -sh /*  2> /dev/null
0       /bin
196M    /boot
0       /dev
29M     /etc
11M     /home
0       /lib
0       /lib64
0       /media
0       /mnt
0       /opt
0       /proc
105M    /root
9.8M    /run
0       /sbin
0       /srv
0       /sys
32K     /tmp
3.9G    /usr
174M    /var
```

