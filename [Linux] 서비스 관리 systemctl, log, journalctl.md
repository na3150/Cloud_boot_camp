<h1> [Linux] 서비스 관리: systemctl, log, journalctl

<br>

<h3>📌INDEX</h3>

- [systemd란?](#systemd란)
-  [systemctl](#systemctl)
  - [시스템의 unit 확인](#시스템의-unit-확인)
  - [시스템 unit의 활성화 상태 확인](#시스템-unit의-활성화-상태-확인)
  - [unit 제어 서브 커맨드(sub-command)](#unit-제어-서브-커맨드sub-command)
-  [log](#log)
  - [rsyslog 서비스](#rsyslog-서비스)
  - [실시간 로그 모니터링](#실시간-로그-모니터링)
  - [로그 메세지 발생](#로그-메세지-발생)
- [journalctl](#journalctl)

<br>

<br>

<h2>systemd란?

- systemd는 **init 프로세스를 대체하는 데몬이다.** (PID 1)
  - 데몬: 시스템에 의해 실행되는 프로세스
- 프로세스 트리에서 가장 상위의 프로레스로, 모든 프로세스의 직간접 부모 데몬이다.

- 특징
  - 부팅 시 **병렬화** 처리 -> 부팅 속도 향상
  - **cgroup**을 통한 자원관리 및 프로세스 트래킹
  - 자동 서비스 종속성 관리
    - **종속성**, 의존성
      - 어떠한 프로그램을 실행하기 위해서는 이전에 또 다른 프로그램이 실행되어있어야함
      - 어떠한 프로그램을 설치하기 위해서는 사전에 다른 프로그램이 설치되어있어야함
  - 선택적 데몬 실행
  - 별도의 서비스 없이 필요시 데몬 시작
  - **systemctl을 이용해 서비스 제어 관리**
- **systemd 메인 프로세스는 unit 개체를 통해 시스템을 관리**

- systemd unit의 위치는 총 3곳이다
  - **/user/lib/systemd/system** : 생성되는 유닛들을 제외한 모든 **유닛들의 원본**
  - **/etc/systemd/system** : 부팅 시에 자동적으로 생성되는 **유닛들의 위치(활성화 여부확인)**
  - **/run/systemd/system** : 실시간으로 생성되는 유닛들에 대한 위치

<br>

<br>

<h2>systemctl</h2>

- systemd 시스템, 서비스 매니저를 제어하는 명렁어



<h4>시스템의 unit 확인</h4>

- **systemctl** 또는 **systemctl list-units**
  - systemctl list-units가 default 이다
- 옵션
  - **-a, --all** : 모든 유닛
    - 실행되지 않거나(inactive), 설치되어있지 않은(not-found) unit까지 확인가능
  - **-t, --type** : 특정 유닛 지정
    - 등호(=)로 서비스 지정 가능 ex) systemctl --type=service



사용 예

```shell
[root@localhost ~]# systemctl
UNIT                         LOAD   ACTIVE SUB       DESCRIPTION
proc-sys-fs-binfmt_misc.automount loaded active waiting   Arbitrary Executable Fil
sys-devices-pci0000:00-0000:00:01.1-ata2-host1-target1:0:0-1:0:0:0-block-sr0.devic
sys-devices-pci0000:00-0000:00:03.0-net-enp0s3.device loaded active plugged   8254
sys-devices-pci0000:00-0000:00:05.0-sound-card0.device loaded active plugged   828
sys-devices-pci0000:00-0000:00:08.0-net-enp0s8.device loaded active plugged   8254
...
```

```shell
[root@localhost ~]# systemctl -t service
UNIT                          LOAD   ACTIVE SUB     DESCRIPTION
abrt-ccpp.service             loaded active exited  Install ABRT coredump hook
abrt-oops.service             loaded active running ABRT kernel log watcher
abrt-xorg.service             loaded active running ABRT Xorg log watcher
abrtd.service                 loaded active running ABRT Automated Bug Reporting T
alsa-state.service            loaded active running Manage Sound Card State (resto
atd.service                   loaded active running Job spooling tools
...
```





<h4>시스템 unit의 활성화 상태 확인</h4>

- 활성화(enable) : 부팅 시에 자동으로 실행되는지에 대한 여부
  - **상태(state) 4가지**
    - enabled : 부팅 시에 실행
    - disabled : 부팅 시에 실행안됨
    - static : 사용자가 실행하지 않고, 다른 유닛에 대해서 실행됨
    - masked : 실행되지 않도록 프리징 시킴
- **systemctl is-[상태] [unit]**
- **systemctl list-unit-files**



사용 예

```
[root@localhost ~]# systemctl is-enabled httpd
disabled
```

```shell
[root@localhost ~]# systemctl list-unit-files
UNIT FILE                                     STATE
proc-sys-fs-binfmt_misc.automount             static
dev-hugepages.mount                           static
dev-mqueue.mount                              static
proc-fs-nfsd.mount                            static
proc-sys-fs-binfmt_misc.mount                 static
sys-fs-fuse-connections.mount                 static
sys-kernel-config.mount                       static
sys-kernel-debug.mount                        static
tmp.mount                                     disabled
var-lib-nfs-rpc_pipefs.mount                  static
brandbot.path                                 disabled
cups.path                                     enabled
...
```





<h4>unit 제어 서브 커맨드(sub-command)</h4>

- **sytemctl [sub-command] [unit]**
- status : 상태확인
- start : 시작
- stop : 종료
- restart : 재시작
  - **PID 변경됨**
  - 아예 프로세스를 껐다가 다시 키는 것
  - **변경된 설정을 시스템에 반영시킬 때마다 restart** 해줘야함
- reload : 재설정
  - **main PID 변경 안됨**
- enable : 활성화
  - 부팅할 때 시작
  - /etc/systemd/system/multi-user.target.wants/[유닛(unit)]에서 /user/lib/systemd/system/[유닛(unit)]로 **심볼릭 링크 연결**하는 것
    - 즉, **디렉토리(/etc/systemd/system)에서 원본 unit(/usr/lib/systemd)으로 연결**시킨다
  - 수동으로 심볼릭 링크 연결 시키는 것도 가능
    -  ln -s 명령 사용
- disable : 비활성화
  - 심볼릭 링크 없앰
  - start 명령을 통해 다시 실행 가능
- mask : 마스크 설정
  - **/dev/null**에 심볼릭 링크 연결
  - start 명령으로도 실행 불가
- unmask : 마스크 해제
- list-dependencies : 종속성(의존성) 확인
  - 녹색 : 의존성이 필요한 상태(해당 부분)
  - 예시

<img src="C:\Users\USER\Desktop\의존성 확인.PNG" style="zoom:60%;" />



- ⭐특정 **서비스를 설치한 후** 앞으로도 계속해서 해당 서비스를 실행 설정할 때 **start, enable 모두 설정**해주어야함

  - **start, enable** 설정 또는 **enable과 --now 옵션** 사용

  - 예시

```shell
[root@localhost ~]# systemctl start autofs.service
[root@localhost ~]# systemctl enable autofs.service
```

```shell
[root@localhost ~]# systemctl enable autofs.service --now
Created symlink from /etc/systemd/system/multi-user.target.wants/autofs.service to /usr/lib/systemd/system/autofs.service.
```



사용 예

- reload 후 PID가 변하지 않고, restart 후에는 PID가 변하는 것을 확인할 수 있음

```shell
[root@localhost ~]# systemctl status httpd.service
● httpd.service - The Apache HTTP Server
...
 Main PID: 1546 (httpd)
...
[root@localhost ~]# systemctl reload httpd.service
[root@localhost ~]# systemctl status httpd.service
● httpd.service - The Apache HTTP Server
...
 Main PID: 1546 (httpd)
...
[root@localhost ~]# systemctl restart httpd.service
[root@localhost ~]# systemctl status httpd.service
● httpd.service - The Apache HTTP Server
...
 Main PID: 1620 (httpd)
...
```





<br>

<br>

<h2>log</h2>

- 로그(log) : **시스템에 일어나는 이벤트들에  대한 기록**
- 중요한 이유: 이슈 발생 시에 **해당 시간에 일어났던 일에 대해 파악**하기 위한 첫번째 수단
- 로그가 저장되는 위치 : **/var/log**
- 로그 관련 서비스: **systemd-journald, rsyslogd**
  - systemd-journald : 시스템에 발생되는 모든 로그들의 수집 (**/run/**)
  - rsyslogd : 로그를 저장하는 역할 (**/var/log/**)

- 로그 파일 저장 체계 : **로그 순환(logrotate)**
  - 로그가 일정 시간이 지나면 해당 로그 파일을 보관
  - 일정 시간 후에 압축했었던 로그 파일을 삭제



<h4>rsyslog 서비스</h4>

- **rsyslog.conf 에 설정**

  - **/etc/rsyslog.cong 에 작성**
    - RULES 파트: 어떤 기준으로 저장하는지 나와있는 부분

  - 설정 후 restart하여 시스템에 반영

- rsyslog로 수집되는 정보들

  - **/var/log/messages** : 대부분의 로그 기록
    - 인증, 메일, 반복예약, 부팅, 디버그 기록 제외
  - **/var/log/secure** : 인증에 관련된 로그
  - **/var/log/maillog** : 메일에 관련된 로그
  - **/var/log/cron** : 반복적인 예약에 관련된 로그
  - **/var/log/boot.log** : 부팅에 관련된 로그

- **facility(기능).priority(우선순위)**

  - 기능과 우선 순위를 조합에서 저장
    - ex) cron.err
  - 기능 : log 종류
  - 우선 순위 : 메세지에 대한 심각도
    - 설정된 우선 순위까지 모두 기록 저장
      - ex) critical로 설정했으면, emerg, alert, critical 까지 기록

- **facility**

  - authpriv : 인증
  - auth, security : 로그인
  - cron : cron, at 과 같은 스케쥴링
  - daemon : telnet, ftp 와 같은 데몬 서비스
  - kern : 커널
  - mail : 메일
  - local1-8 : 부팅
  - lpr : 프린트
  - mark : syslog에 의해 만들어지는 날짜 유형
  - user : 사용자

- **priority**

  - 0 : emerg
  - 1 : alert
  - 2 : critical
  - 3 : error
  - 4 : warning
  - 5 : notice
  - 6 : info
  - 7: debug
  - 0 ~ 3 : 빨간색으로 표시
  - 4 ~5 : 볼드체로 표시





<h4>실시간 로그 모니터링</h4>

- **tail -f /var/log/로그파일**

```shell
[root@localhost ~]# tail -f /var/log/cron
Mar  2 18:00:01 localhost CROND[32280]: (root) CMD (/usr/lib64/sa/sa1 1 1)
Mar  2 18:01:01 localhost CROND[32323]: (root) CMD (run-parts /etc/cron.hourly)
Mar  2 18:01:01 localhost run-parts(/etc/cron.hourly)[32323]: starting 0anacron
Mar  2 18:01:01 localhost run-parts(/etc/cron.hourly)[32332]: finished 0anacron
...
```





<h4>로그 메세지 발생</h4>

- **logger -p [기능].[우선순위] "메세지"**



사용 예

- /var/rsyslog.conf 에서 RULES 파트 확인했을 때, authpriv 기능은 /var/log/secure에 저장되는 것을 확인할 수 있음

  - 파일에 직접 접근하여 확인하지 않아도, /var/log/secure는 원래 인증에 관한 로그를 기록하는 곳

  - authpriv.* 
    - **우선 순위가 '*'로 설정되어있기 때문에, 모든 메세지를 기록** 
  - 만약, authpriv.critcal 로 설정되어있다면, error는 critical보다 우선 순위가 낮기 때문에 /var/log/secure에 저장되지 않는다

```shell
#### RULES ####

# Log all kernel messages to the console.
# Logging much else clutters up the screen.
#kern.*                                                 /dev/console
...
# The authpriv file has restricted access.
authpriv.*                                              /var/log/secure
...
```

- logger 명령어를 통해, "test" 로그 메세지를 남겼을 때, /var/log/secure에 기록된 것을 확인할 수 있음

```shell
[root@localhost ~]# logger -p authpriv.err "test"
[root@localhost ~]# tail -1 /var/log/secure
Mar  2 18:47:08 localhost root: test
```



<br>

<br>

<h2>journalctl</h2>

- **systemd의 서비스 로그를 확인**할 수 있는 명령어

- rsyslog를 통해서 로그들을 저장하기는 하나, 모든 로그들을 확인할 수 있는 것은 아니다
  - **systemd-journald 서비스**에서 저장하는 로그를 볼 수 있음
  - **메모리 영역에 로그들을 수집**
    - 메모리는 휘발성을 가지기 때문에, 수집되는 기간은 전원을 킨 후 부터이다

- 설정 파일 :  **/etc/systemd/journald.conf**
- 옵션
  - -n : 최근 내역부터 n 만큼 출력
  - -p : 우선순위를 지정하여, 해당 우선 순위 이상으로 출력
  - -f : 실시간으로 모니터링
  - -b : 마지막 부팅 후의 log만 출력
  - -k : 커널 메세지만 출력
  - --since yyy-mm-dd : 해당 날짜부터 현재까지 출력
  - --since yyyy-mm-dd --until yyyy-mm-dd : since 부터 until까지 출력

- **영구저장하기**
  - 영구 저장 시 저장 용량이 설정되어있음
    - 전체 파일 시스템의 10%를 초과 불과
    - 남아있는 공간의 15% 초과 불가
  - 용량이 부족하여 영구 저장이 안될 시, **/var/log/journal에 직접 구현**할 수 있음(아래 예시 참조)



사용 예

- /etc/systemd/journald.conf에서 설정 확인

```shell
[root@localhost ~]# cat /etc/systemd/journald.conf | less
[Journal]
#Storage=auto
#Compress=yes
#Seal=yes
#SplitMode=uid
#SyncIntervalSec=5m
#RateLimitInterval=30s
#RateLimitBurst=1000
#SystemMaxUse=
#SystemKeepFree=
#SystemMaxFileSize=
#RuntimeMaxUse=
...
```

- journalsystemctl 명령어로 확인

```shell
[root@localhost ~]# journalctl
-- Logs begin at 수 2022-03-02 11:18:17 KST, end at 수 2022-03-02 19:20:26 KST. --
 3월 02 11:18:17 localhost.localdomain systemd-journal[83]: Runtime journal is usi
 3월 02 11:18:17 localhost.localdomain kernel: Initializing cgroup subsys cpuset
 3월 02 11:18:17 localhost.localdomain kernel: Initializing cgroup subsys cpu
 3월 02 11:18:17 localhost.localdomain kernel: Initializing cgroup subsys cpuacct
 3월 02 11:18:17 localhost.localdomain kernel: Linux version 3.10.0-862.el7.x86_64
 3월 02 11:18:17 localhost.localdomain kernel: Command line: BOOT_IMAGE=/boot/vmli
 3월 02 11:18:17 localhost.localdomain kernel: [Firmware Bug]: TSC doesn't count w
 3월 02 11:18:17 localhost.localdomain kernel: e820: BIOS-provided physical RAM ma
 3월 02 11:18:17 localhost.localdomain kernel: BIOS-e820: [mem 0x0000000000000000-
 3월 02 11:18:17 localhost.localdomain kernel: BIOS-e820: [mem 0x000000000009fc00-
 3월 02 11:18:17 localhost.localdomain kernel: BIOS-e820: [mem 0x00000000000f0000-
 ...
```

- journal의 로그들을 /run/log/journal에 **영구 저장**해보자

```shell
[root@localhost ~]# mkdir /var/log/journal
[root@localhost ~]# chmod g+s /var/log/journal
[root@localhost ~]# chown :systemd-journal /var/log/journal
[root@localhost ~]# systemctl restart systemd-journald.service
```

```shell
[root@localhost ~]# ls /var/log/journal
bb9afee5d305ab46b7f34ffc7d08f145
[root@localhost ~]# ls -l /run/log
합계 0 ---> /var/log/journal로 이동 된 것
```

- 다시 원래대로 되돌려 보자
  - 다시 /run/log로 옮기고 재시작

```shell
[root@localhost ~]# mv /var/log/journal /run/log
[root@localhost ~]# systemctl restart systemd-journald.service
```

