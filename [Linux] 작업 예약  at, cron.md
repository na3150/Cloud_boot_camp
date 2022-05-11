<h1> [Linux] 작업 예약 : at, cron </h1>



<h3>📌INDEX</h3>

- [at](#at) 
- [at 실습(문제)](#at-실습문제)
- [cron](#cron)
- [cron 실습(문제)](#cron-실습문제) 

<br>

<br>

<h2>at</h2>

- at은 **일회성으로 작업을 예약**하는 명령어이다
- atd 서비스를 이용한다.
  - atd : 원하는 날짜 또는 시간에 명령들을 한번만 실행해주는 **데몬**

- 읽기·출력 관련 명령이거나 에러인 경우에는 결과를 메일로 전송

  - atd 서비스는 제어할 수 있는 터미널을 지정받지 못하기 때문에, 메일로 보내거나 redirection(< , <<)을 이용하여 파일로 지정해야한다

- **예약 작업 방법**

  ```shell
  # at [시간] ... 예약 시간 설정
  at> [명령] ... 예약 시간에 실행될 명령
  at> [ctrl+d] ... 예약완료
  ```

- `at-l` 또는 `atq` : 예약 확인

- `at -c [예약번호]` : 작업 내용 확인

- `atrm [예약번호]` : 작업 예약 취소

- `at -m` : 메일 보내지 않기

- `at -f` : 파일 지정하기

- **timespec(예약 시간) 작성 방법**
  - **at now + 값[minutes, hours, days]**
    - ex) 지금부터 2시간 후: `at now +2hour`
    - 시간 - hour, 분 - min
  - **at 시간**
    - ex) 오후 4시 :  `at 16:00` 또는 `at 04:00 PM` 
  - **at 시간 월/일/년(년-월-일)**
    - ex) `at 16:00 2/23/22` 또는 `at 16:00 23-08-01`
  - 더 자세한 사항은 /usr/share/doc/at-3.1.13/timespec 참조



<br>

<br>

<h2>at 실습(문제)</h2>

1. 5분 뒤에 ps -ef 명령을 실행해서 psfile01에 저장되도록 설정(예약)해보자.

```shell
[root@localhost ~]# at now +5min
at> ps -ef > psfile01
at> <EOT>
job 1 at Thu Feb 24 17:10:00 2022
```

2. 8월 3일에 date 명령어를 실행해서 메일로 오도록 설정(예약)해보자.

```shell
[root@localhost ~]# at 00:00 8/1/23
at> date
at> <EOT>
job 2 at Tue Aug  1 00:00:00 2023
```

3. 오늘 오후 12시에 cal 명령어를 실행해서 메일로 오도록 설정(예약)해보자.

```shell
[root@localhost ~]# at noon today
at> cal
at> <EOT>
```

4. 작업 예약 목록을 확인해보자.

```shell
[root@localhost ~]# at -l
2       Tue Aug  1 00:00:00 2023 a root
```

5. 2번 작업 예약을 삭제해보자.

```shell
[root@localhost ~]# at -l
2       Tue Aug  1 00:00:00 2023 a root
[root@localhost ~]# atrm 2
[root@localhost ~]# atq
```

<br>

<br>

<h2>cron</h2>

- cron은 **반복성 예약**을 할 때 사용한다.
- 일반적으로 데이터 백업을 위해 사용한다.

- cron은 사용자 cron과 시스템 cron으로 나뉜다

  - 사용자 cron : 사용자들이 crontab이라는 명령어를 통해 작성하는 cron
  - 시스템 cron : cron과 anacron 2종류

- <h4>사용자 cron</h4>

  - crond 서비스를 이용한다.
    - crond : 원하는 날짜 또는 시간에 명령들을 반복적으로 실행해주는 **크론데몬**
    - cron 데몬이 주기적인 작업 실행을 처리
  - cron 설정 파일은 cron table을 줄여서 **crontab**이라 부른다
    - crontab의 파일위치: /var/spool/cron
    - 리눅스에서 사용자가 **반복성 예약을 할 때 crontab 명령어를 사용**한다

  - cron 프로세스는 **/etc/crontab 파일에 설정된 것을 읽어서 작업 수행**
    - /etc/cron.d 디렉토리에 crontab 파일을 직접 작성하는 것도 가능
  - 생각해보기) /etc/crontab 의 other 권한에 쓰기,실행 권한이 없음에도 일반 사용자가 crontab 명령어로 작업 예약을 할 수 있는 이유는 **/bin/crontab에 setuid 권한이 부여**되어있기 때문이다

- `crontab -e` : 작업 예약 (cron 예약창 편집)
- `crontab -l` : 작업 예약 목록 확인
- `crontab -r` : 작업 예약 취소 (모든 작업 취소)
- `crontab -u [사용자]` : 지정한 사용자가 등록한 crontab 리스트 표시
- `crontab [파일명]` : 다른 파일에 만들어놓은 작업을 불러올 수 있음

- **timespec(예약 시간) 작성 방법**
  - 5개의 필드 사용
  - 순서대로 분-시간-일-월-요일

```shell
   *　　　　　　*　　　　　　*　　　　　　*　　　　　　*
  분　　      시간　　     일　　        월　　　    요일
(0-59)     (0-23)      (1-31)         (1-12)       (0-7)
                                     (약식월)    (약식요일| 0,7: 일요일)
```

```
특수문자
* : 모두 참
- : 범위
/ : 주기
, : 연속되지 않은 다수
```

- <h4>시스템 cron</h4>

  - cron과 anacron 2가지 종류 존재
  - **cron** : 일반 cron은 시스템이 켜져있는 동안에만 해당 시간의 작업을 수행
    - 해당 시간(예약시간)에 시스템이 다운되어있으면 작업을 수행하지 않음
  - **anacron** : 시스템이 꺼져있어서 실행하지 못했을 때, 시스템이 켜지면 일정시간 대기 후에 해당 작업 실행
    - 서버가 일정 시간 중지되었을 때에도 작업이 실행되는 것을 보장하기 위해 사용
  - 사용자 cron과 달리, cron 예약시 사용자 계정이 들어감



**사용 예**

- crontab -e 를 통해 예약창을 열어 작성

- 1월 1일 새벽 12시 reboot

```shell
0 0 1 1 * reboot
```

- 12월 15일 오후 3시부터 오후 6시까지 15분 마다 date

```shell
*/15 15-18 15 12 * date
```

- 매월 첫번째 월요일 오후 1시 정각에 date

```shell
0 13 1-7 * 1(Mon) date
```

- 매분마다 date 명령어를 datefile에 기입해보자(이어쓰기)

```
* * * * * date >> datefile
```

- 매시간 마다 date

```shell
0 * * * * date
```



<br>

<br>

<h2>cron 실습(문제)</h2>

- crontab -e 명령을 통해 예약창을 열어서 작성

1. 매년 1월 첫번째 일요일 자정에 재부팅이 되도록 설정해보자

```shell
0 0 1-7 1 0 reboot
```

2. 다음 문제부터 vi 에디터로 test파일에 내용을 저장해보자

``` shell
vi test
```

2. 매월 오후 1시부터 5시까지 10분 마다 date 명령어를 실행해서 datefile01에 이어쓰기로 저장하도록 설정해보자

```shell
*/10 13-17 * * * date >> datefile01
```

3. 매년 3월,6월,9월 2번째 화요일 14시 20분에 /etc/passwd 파일의 내용을 userfile에 갱신하도록 설정해보자

```shell
20 14 8-14 3,6,9 2 cat /etc/passwd > userfile
```

4. 매주 수~금 오후 5시에 /var/log/secure의 내용 중 오전 8시 정각부터 오후 5시59분까지의 내용을 securefile에 갱신하도록 설정해보자

```shell
0 17 * * 3~5 egrep ‘^... .. (0[89]|1[0-7])’ /var/log/secure > securefile’
```

5. 3,4번의 작업을 파일로 예약해보자

```shell
:wq 로 저장하고 나온 후
[root@localhost ~]# crontab test
```

6. 3번 작업만 삭제해보자

```
crontab -r 명령은 모든 예약을 삭제하기 때문에 특정 예약만 삭제하기 위해서는 
crontab -e 명령을 통해 예약창에 들어가서 해당 예약을 삭제하고 :wq 하고 나와야한다
```

7. 모든 작업을 삭제해보자

```shell
crontab -r
```

