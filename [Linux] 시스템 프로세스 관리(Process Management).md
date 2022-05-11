<h1>[Linux] 시스템 프로세스 관리(Process Management)



<h3>📌INDEX</h3>

- [프로세스(process)란?](#프로세스process란)
-  [프로세스의 종류](#프로세스의-종류)
-  [ps와 pstree](#ps와-pstree)
-  [포그라운드와 백그라운드 프로세스](#포그라운드와-백그라운드-프로세스)
- [SIGNAL](#signal)
- [우선순위](#우선순위)
- [프로세스 실습(문제)](#프로세스-실습문제)



<br>

<br>

<h2>프로세스(process)란?</h2>

- **컴퓨터의 CPU에서 실행되는 모든 프로그램**
  - 하드디스크에 저장된 실행 코드(프로그램)가 메모리에 로딩되어 활성화 된 것

- 컴퓨터의 구성 요소

  - CPU
  - memory : 주기억장치 
    - 휘발성: 전원이 있는 상태에서만 사용가능, 전원이 공급되지 않으면 모든 자료 날라감
  - hdd, ssd : 보조기억장치
    - 비휘발성: 전원이 꺼지더라도 자료가 날라가지 않는다.

  - I/O device

- **프로세스 생성**
  - 기존 프로세스는 **자체 주소 공간(fork)을 복제해서 새로운 구조**를 생성
  - 모든 프로세스는 하위 프로세스 생성 가능
  - 보안 ID, 파일 설명자, 우선 순위, 환경 변수 등 **상속**

- **PID** : 프로세스가 시작될 때 부여되는 고유한 ID 넘버
- **PPID** : 부모 프로세스의 PID 값

<br>

<br>

<h2>프로세스의 종류</h2>

- <h4>부모 프로세스와 자식 프로세스</h4>

  - 프로세스는 여러가지 기능을 수행함으로써 주어진 작업을 완료하며, 모든 기능이 완료되지 전까지는 종료될 수 없다.
    - 부모 프로세스는 여러 개의 자식 프로세스를 실행하여 다수의 작은 작업들을 동시에 처리하도록 할 수 있다.
  - 모든 프로세스는 혼자서 독립적으로 실행되는 것이 아니라 부모 프로세스의 하위에 종속되어 실행된다.
    - 부모 프로세스가를 종료하면, 그에 종속된 자식 프로세스도 모두 종료된다.
  - **exec** : 한 프로세스가 다른 프로세스를 생성(spawn)할 경우, **원래의 프로세스가 더는 남아 있을 필요가 없다면**, exec호출을 통해서 **다른 프로그램을 실행하고 새로운 프로세스로 자신을 대체**할 수 있다.
  - **fork** : exec에 반해 **원래 프로세스가 계속 존재해야한다면**, fork를 호출하여 **자신의 복사본 프로세스**를 먼저 만들고 복사본 프로세스에서 다시 exec를 호출하여 다른 프로그램을 실행하는 새로운 프로세스로 자신을 대체한다. 
  - **동작 방식**
    - 부모 프로세스: fork 후 **자식 프로세스의 동작 완료까지 대기**
    - 자식 프로세스: **작업 완료 후 부모 프로세스에 신호 전달** 후 종료

- process의 종류: 프로세스는 고아 프로세스, 좀비 프로세스, 데몬 프로세스 등 으로 구분되어 진다.
- 각 프로세스의 기본 규칙
  - **각각의 프로세스마다 고유 번호의 프로세스 ID(PID)를 하나씩 증가시키면서 부여**
    - 더 이상 할당할 PID가 없으면, 사용되지 않는 가장 낮은 숫자로 되돌아가 다시 할당
  - 프로세스는 파일의 소유권과 유사한 방식의 소유권을 갖는다.
    - 프로세스를 실행하는 사용자의 UID가 프로세스의 실제 사용자 UID로 할당된다.
    - SetUID와 같은 특수한 경우, 실행하는 사용자의 UID가 아닌 파일의 소유가 실행한것 처럼 실행된다(EUID/EGID)

- **고아 프로세스**
  - 일반적으로 부모 프로세스가 죽게되면 자식  프로세스가 죽게된다.
  - 어떠한 이유로 인해서 **부모 프로세스가 죽었음(종료)에도 불구하고, 자식 프로세스가 살아남는 경우**를 고아 프로세스라 한다. 
  - **부모 프로세스만 먼저 종료된 경우**
- **좀비 프로세스**
  - 부모가 자식 프로세스를 탄생시키고, 자식 프로세스가 일을 끝내면 부모는 자식을 죽이고, 해당 리소스를 모두 회수한다.
  - **시스템적으로는 죽은 것(종료된 것)으로 표시되지만, 실제는 살아서 리소스를 갖고(잡고)있는 경우**를 좀비프로세스라 한다.
  - **발생하는 경우**
    - 자식 프로세스가 종료되었는데, 부모 프로세스에세 SIGCHLD 전달이 안되었을 때, 혹은 손실(lost) 되었을 때 발생
    - 자식 프로세스는 종료 되었는데, 부모 프로세스는 종료되지 않았거나, wait() 계열 함수를 호출해서 자식 프로세스를 정리하지 않았을 때 발생 
  - 파일 등의 모든 자원 및 메모리 이미지 역시 해제 하였으며, **프로세스 테이블만 유지**하고 있는 상태
  - 시스템적으로는 죽었기(종료되었기) 때문에 다시 죽이지는 못함
  - 이러한 좀비 프로세스가 많아지면, 리소스를 잡아먹어서 다른 프로세스를 할당하는 메모리가 부족해질 수 있다. 
    - 전원을 끔으로써 좀비 프로세스를 종료할 수 있다.
- **데몬 프로세스**
  - 사용자가 아닌 **시스템에 의해서 실행된 프로세스**
  - 데몬은 특정 서비스를 위해 **백그라운드 상태에서 계속 실행되는 서버 프로세스**
    - 일반적인 서비스는 각각의 서비스가 사용하는 포트를 관리하는 데몬이 존재
    - 다른 데몬들에게 할당된 포트를 관리하는 특별한 용도의 데몬도 존재
    - 일반적으로 **백신, 웹서비스**와 같은 프로세스

<br>

<br>

<h2>ps와 pstree</h2>

- <h4>ps</h4>

  - 현재 프로세스의 상태를 확인하는 명령어로, **현재 동작하고 있는 프로세스들의 상황(스냅샷)을 보여줌**

  - 실시간으로 프로세스의 동작 상황을 확인하고 싶을 때는 top 명령어를 사용

  - Process 정보의 기본적인 내용은 proc 파일 시스템에 있는 stat의 내용에서 가져온다.

  - 옵션

    - -a : 현재 실행중인 전체 사용자의 모든 프로세스를 출력
    - -e : 모든 프로세스 정보 출력
    - -l : Long Format
    - -u : 프로세스를 실행한 사용자 정보와 프로세스 시작 시간 등을 출력
    - -x : 제어 터미널을 갖지 않는 프로세스 출력
    - -f : Full format 정보
    - 자주 사용하는 종합: ps -ef, ps aux

  - ps 명령어 주요 필드

    - USER : 프로세스를 실행시킨 사용자
    - **PID : 프로세스 ID**
    - %CPU : 최근 1분간 프로세스가 사용한 CPU 시간 백분율
    - %MEM : 최근 1분간 프로세스가 사용한 실제 메모리의 백분율
    - RSS : 현재 프로세스가 사용하고 있는 실제 메모리 크기
    - **TTY : 프로세스를 제어하고 있는 터미널**
    - STAT : 프로세스 상태 코드
    - START : 프로세스의 시작 시간

  - 프로세스의 번호 및 상태를 확인할 때는 '**ps -ef | grep [프로세스 이름]**' 명령 자주 사용

    

  - 사용 예

- 현재 실행 중인 전체 사용자 정보와 프로세스 시작 시간 등 출력

```shell
[root@localhost ~]# ps -au
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
gdm         1435  0.0  0.2 338968  5252 tty1     Ssl+ 00:37   0:00 /usr/
gdm         1454  0.0  0.3 657500  6776 tty1     Sl+  00:37   0:00 /usr/
gdm         1481  0.0  5.2 2649784 96584 tty1    Sl+  00:37   0:06 /usr/
gdm         1632  0.0  0.2 260240  5136 tty1     S+   00:37   0:00 /usr/
gdm         1791  0.0  0.2 387792  5152 tty1     Sl   00:37   0:00 ibus-
gdm         1794  0.0  0.2 301552  4216 tty1     Sl   00:37   0:00 /usr/
gdm         1798  0.0  0.6 521404 11088 tty1     Sl   00:37   0:00 /usr/
gdm         1837  0.0  0.5 523092 10384 tty1     Sl+  00:37   0:00 /usr/
...
```

- 사용자가 정의한 형색(o) 으로 모든 프로세스(e)를 보여줌

```shell
[root@localhost ~]# ps -eo pid,state,nice,args | head -10
    PID S  NI COMMAND
      1 S   0 /usr/lib/systemd/systemd --switched-root --system --deserialize 18
      2 S   0 [kthreadd]
      3 I -20 [rcu_gp]
      4 I -20 [rcu_par_gp]
      6 I -20 [kworker/0:0H-kblockd]
      9 I -20 [mm_percpu_wq]
     10 S   0 [ksoftirqd/0]
     11 R   0 [rcu_sched]
     12 S   - [migration/0]
```

- sleep 프로세스의 full format 정보 출력

```shell
[root@localhost ~]# ps -ef | egrep '(sleep|PID)'
UID          PID    PPID  C STIME TTY          TIME CMD
root        3165    2861  0 01:00 pts/1    00:00:00 sleep 20000
root        6519     830  0 06:23 ?        00:00:00 sleep 60
root        6522    2861  0 06:23 pts/1    00:00:00 grep -E --color=auto (sleep|PID)
```



- <h4>pstree</h4>

  - **현재 프로세스의 상황을 트리형식**으로 보여줌
  - 옵션 
    - -n : PID 순으로 정렬
    - -p : 프로세스명과 PID 함께 출력
  - 사용 예

```shell
[root@localhost ~]# pstree -np
systemd(1)─┬─systemd-journal(611)
           ├─systemd-udevd(646)
           ├─rpcbind(746)
           ├─auditd(750)─┬─{auditd}(751)
           │             ├─sedispatch(752)
           │             └─{auditd}(753)
           ├─rtkit-daemon(779)─┬─{rtkit-daemon}(838)
           │                   └─{rtkit-daemon}(839)
           ├─alsactl(781)
           ├─smartd(783)
           ├─lsmd(785)
           ├─sssd(786)─┬─sssd_be(837)
           │           └─sssd_nss(861)
           ├─udisksd(787)─┬─{udisksd}(795)
           │              ├─{udisksd}(835)
           │              ├─{udisksd}(886)
           │              └─{udisksd}(968)
           ├─dbus-daemon(788)───{dbus-daemon}(827)
           ├─ModemManager(789)─┬─{ModemManager}(806)
           │                   └─{ModemManager}(836)
           ├─avahi-daemon(793)───avahi-daemon(832)
           ├─VGAuthService(794)
           ├─vmtoolsd(796)─┬─{vmtoolsd}(829)
           │               └─{vmtoolsd}(850)
           ....
```

<br>

<br>

<h2>포그라운드와 백그라운드 프로세스</h2>

- **포그라운드(foreground) 프로세스**
  - 실행하면 **화면에 나타나서 사용자와 상호 작용하는 프로세스**
  - shell 상태에서 명령을 내리면 사용자는 해당 프로세스가 종료될 때 까지 기다려야함(대기상태)
  - 특정 터미널 창으로 입력 및 키보드 생성 신호 수신 가능
- **백그라운드(background) 프로세스**
  - 실행은 되었지만 **화면에 나타나지 않고, 뒤에서 실행되는 프로세스**
  - 일반적으로 **명령어 뒤에 '&' 를 붙여서 동작**시키며, 명령을 내린 사용자는 자신이 하고자 하는 다른 명령어를 계속 실행할 수 있음
  - PID 값 출력 후 다시 프롬프트 표시
  - 예를 들어, 바이러스 백신, 서버 데몬 등은 눈에 보이지 않지만 실행된다.

- **관련 명령어**

  - **jobs**
    - 백그라운드로 실행중인 프로세스나 현재 중지된 프로세스 목록을 출력해줌
    - 옵션 -l : PID와 함께 출력

  ```shell
  [root@localhost ~]# jobs -l
  [1]+  3165 Running                 sleep 20000 &
  ```

  - **fg**
    - fg는 **백그라운드 프로세스를 포그라운드 프로세스로 전환**하는 명령어
    - 백그라운드 프로세스가 여러개 존재할 경우, 별도의 작업 번호를 부여하지 않으면 현재 수행중인(+ 기호가 붙은) 작업을 전환
    - 사용법: **fg %[작업번호]**

  ```shell
  [root@localhost ~]# jobs
  [1]+  Running                 sleep 1000 &
  [root@localhost ~]# fg %1
  sleep 1000
  
  ```

  - **bg**
    - bg는 **포그라운드 프로세스를 백그라운드 프로세스로 전환**하는 명령어
    - 일반적으로 실행시키고 있는 포그라운드 프로세스에서 ctrl+z 키를 눌러 작업을 잠시 중지시킨 후에 bg 명령어를 사용하여 작업을 백그라운드로 전환함

  ```shell
  [root@localhost ~]# fg %1
  sleep 1000
  ^Z
  [1]+  Stopped                 sleep 1000
  [root@localhost ~]# bg
  [1]+ sleep 1000 &
  ```

- 전환 방법 정리

  - fg %작업번호 : 백그라운드 -> 포그라운드
  - Ctrl+z : 포그라운드 -> 백그라운드 / 일시 정지 상태
  - bg %작업번호 : 일시 정지 상태의 백그라운드 프로세스 시작

<br>

<br>

<h2>SIGNAL</h2>

- 시그널이란? **프로세스에서 발생하는 비동기적인 사건(asynchronous event)**
  - 갑자기 일어나는 이벤트
- 한 프로세스가 다른 프로세스에게 보낼 수 있고, 커널이 프로세스에게 보낼 수도 있음

- 비동기적이므로 어느 시점에서 시그널이 발생할 지 미리 예측할 수 없음
- **시그널을 통해서 프로세스를 관리**

- SIGNAL이 발생하는 경우
  - 키보드를 통해 발생
    - ctrl + c (sigint) , ctrl + z (sigstop)
  - 다른 프로세스에 의해서 발생
  - 커널 내부에서 발생
    - kill(), alarm() 과 같은 시스템 콜

- SIGNAL SYNTAX
  - kill [옵션] PID 
    - PID default : -15

- **주요 SIGNAL**

<img src="https://user-images.githubusercontent.com/64996121/154955556-9737d4f0-aa60-46fd-b003-6fe7a63e6ad7.PNG" width=500 height=250 />

- -15 시그널 넘버로 죽일(종료) 수 없는 경우
  - 일시 정지 상태
  - shell(shell은 죽지 않음)
  - 이러한 경우, kill -9 명령어 사용

- **kill**

  - **프로세스나 프로세스 그룹에게 지정된 시그널을 보내줌**

  - 사용 예

    - PID 1234 vmfhtptmdptp SIGTERM(기본값) 신호 보내기

    ```shell
    [root@localhost ~]# kill PID
    ```

    -  다수의 프로세스 강제종료(SIGKILL 옵션을 주어도 동일)

    ```shell
    [root@localhost ~]# kill -9 PID1 PID2 PID3 PID4
    ```

    - 프로세스를 정보를 다시 읽어들임

    ```shell
    [root@localhost ~]# kill -HUP 1234
    ```

  - 작업 번호 단위로 종료

    - **kill %[작업번호]**

- **killall**

  - kill 명령은 다수의 경우 각각의 PID 값을 알아내고 모두 입력해야 하나 데몬에 의해 동작되는 **모든 프로세스에게 한번에 같은 시그널을 보낼 경우**에 사용됨

  - 프로세스명 또는 데몬명으로 프로세스 종료시킴

  - 사용 예

    - 작업번호와 관련된 모든 프로세스에게 SIGTERM 보냄

    ```shell
    [root@localhost ~]# killall %1
    ```

    - ssh 데몬에 대한 환경설정 리로드 : ssh 연결 종료됨

    ```
    [root@localhost ~]# killall -s SIGHUP sshd
    ```

    - **test1 사용자가 생성한 sleep 프로세스 제거**

    ```
    [root@localhost ~]# killall -15 -u test1 sleep
    ```

  

- **skill**

  - 주로 시스템에 **접속해 있는 사용자 혹은 특정 터미널을 종료**시키는데 사용

  - 불필요한 접속자 혹은 공격자 등을 차단하는 경우

  - 사용 예

    - testuser1 이라는 사용자를 시스템에서 추방

    ```shell
    [root@localhost ~]# skill -KILL user
    ```

    - 특정 터미널인 pts/0 에 접속해 있는 사용자만 추방

    ```shell
    [root@localhost ~]# skill -KILL pts/0
    ```

    - 특정 사용자를 정지시킴

    ```shell
    [root@localhost ~]# skill -STOP testuser1
    ```

- **프로세스 제어 관련 명령어**

  - pgrep

    - 프로세스에 대해 특정 정보를 이용한 검색 기능
    - ps + grep과 같은 효과
    - 조건: killall의 조건 + PPID, terminal
    - 조건이 충당되는 것 중 제일 최신 프로세스만 선택하는 것도 가능

  - **pkill**

    - killall과 같이 **복수의 프로세스에 신호 전달** 가능
    - **-t 옵션과 함께 사용하면, 터미널 별로 관리 가능**
    - +pgrep과 같은 특정 조건으로 신호 전달 가능
    - 장점: **여러 프로세스 통시에 제어 가능**
    - 단점: 예상치 못한 프로세스 제어
    - 사용 예

    ```shell
    [root@localhost ~]# pkill -15 -t pts/1 sleep
    ```

    

<br>

<br>

<h2>우선순위</h2>

- 우선순위란? **프로세스의 처리 순서**
- 중요도에 따른 가중치 부여
- 기본 값(priority) + 조정 값(nice)
- **nice 값**
  - **높을 수록 우선순위 하락**
  - 프로세스 실행 시 설정 - nice 명령어 사용
  - 동작 중 변경 가능 -  renice 명령어 사용

<img src="https://user-images.githubusercontent.com/64996121/154955830-50302b3d-6272-4541-9a87-2568edf3ef31.PNG"  width=400 height=100 />


- 사용 예

  - 프로세스 실행 시 부여

  ```shell
  [root@localhost ~]# nice -n 100 sleep 1000 &
  [1] 7245
  [root@localhost ~]# ps -l
  F S   UID     PID    PPID  C PRI  NI ADDR SZ WCHAN  TTY          TIME CMD
  0 S     0    7028    7023  0  80   0 -  6530 -      pts/1    00:00:00 bash
  0 S     0    7245    7028  0  99  19 -  1435 hrtime pts/1    00:00:00 sleep
  0 R     0    7246    7028  0  80   0 - 10975 -      pts/1    00:00:00 ps
  ```

  - 실행 중인 프로세스 변경

```shell
[root@localhost ~]# renice -n 19 7028
7028 (process ID) old priority 0, new priority 19
```

​       

<br>

<br>

<h2>프로세스 실습(문제)</h2>

1. sleep, gedit, firefox 의 PID와 PPID가 무엇인지 확인하시오.

```shell
[root@localhost ~]# ps -ef | grep sleep gedit firefox
```

```shell
[root@localhost ~]# ps -ef | egrep `(sleep|gedit|firefox)`
```

2. pts/2 번에서 sleep 2000을 포그라운드로 실행시키고 백그라운드로 보내라.

```shell
[root@localhost ~]# sleep 2000
^Z
[3]+  Stopped                 sleep 2000
[root@localhost ~]# bg %3
[3]+ sleep 2000 &
```

3. firefox를 kill 명령어로 kill 하라

```shell
[root@localhost ~]# kill -15 [firefox PID]
```

4. pts/0, pts/3의 sleep 프로세스를 kill 하라

```shell
[root@localhost ~]# pkill -15 -t pts/1, pts/3 sleep
```

5. nice 값 -11의 우선 순위로 sleep 2000을 실행시키시오

```shell
[root@localhost ~]# nice -n -11 sleep 2000 &
[root@localhost ~]# ps -l | egrep '(sleep|NI)'
```

6. 5번에 이어서 nice 값을 4로 수정해보시오

```shell
[root@localhost ~]# renice -n 4 sleep 7460
```

