<h1>[Linux] shell 메타문자(Metacharacter)</h1>



<h2>📌INDEX</h2>

- [shell 메타 문자란?](#shell-메타-문자란)
- [경로 이름 메타 문자](#경로-이름-메타-문자)
- [파일 이름 메타 문자](#파일-이름-메타-문자)
- [인용 부호 메타 문자(echo와 사용시)](#인용-부호-메타-문자echo와-사용시)
- [방향 재지정 메타 문자](#방향-재지정-메타-문자)
  - [표준 입출력](#표준-입출력)
- [shell 메타 문자 실습(문제)](#shell-메타-문자-실습문제)



<br>

<br>



<h2>shell 메타 문자란?</h2>

- **shell에서 사용할 때 특수한 기능을 가지고 있는 문자**
- shell은 이러한 특수 기호들을 해석(interpret)하여 명령 실행
- Bourne Shell의 경우에는 메타 문자 인식 못함
- shell에서 사용하는 메타문자와 정규 표현식에서 사용하는 메타 문자 혼동 않도록 주의
- 종류 
  - 경로 이름 메타문자 : 디렉토리의 경로 축약
  - 파일 이름 메타문자 : 파일 이름 대체
  - 인용부호 메타문자 : 메타 문자의 의미를 다르게 하거나 무시
  - 방향 재지정 메타문자 : 표준 입력과 출력 등을 재지정



<br>

<br>

<h2>경로 이름 메타 문자</h2>

- 파일 경로 이름 매칭 기능을 제공
- 많은 수의 파일을 관리하기 쉬움



<img src="C:\Users\USER\Desktop\경로 이름 대체 문자.PNG" style="zoom:90%;" />



- 사용 예

```shell
[user@localhost ~]$ ~
-bash: /home/user: 디렉터리입니다
```

```shell
[user@localhost tmp]$ ~+
-bash: /tmp: 디렉터리입니다
```

```shell
[user@localhost tmp]$ ~-
-bash: /home/user: 디렉터리입니다
```

```shell
[root@localhost dir01]# ~user
-bash: /home/user: 디렉터리입니다
```

<br>

<br>

<h2>파일 이름 메타 문자</h2>

- **파일 이름을 대체(확장)하는 데 사용**되는 메타 문자들이다



<img src="C:\Users\USER\Desktop\파일 이름 대체 문자.PNG" style="zoom:90%;" />



- ex) [123] : 1,2,3을 하나씩 대입
- ex) [a-z] : a부터 z까지 한 문자씩 대입
- ex) [!] : 대괄호 안에 있는 문자들을 제외한 모든 문자
- ex) 1133* : 1133을 포함해서 1133으로 시작하는 모든 것을 뜻한다.
- ex) 13? : 빈칸을 포함한 최소 한 글자를 나타낸다(space, tab 등 포함)
- ex) [B-Pk-y] : B에서 P까지 사이 혹은 k 에서 y 까지 사이 중의 한 글자와 일치
- ex) [a-z0-9] : 소문자 혹은 숫자와 일치
- ex) [!b-d] : b에서 d 사이의 문자를 제외한 모든 문자

- <h4>브레이스 확장</h4>

  - bash 에서만 사용 가능
  - **중괄호 안에 들어가 있는 문자열을 하나씩 배포**
  - {a,b,c} 형식으로 사용 
  - {001..100} : 001부터 100까지 차례대로 배포
  - 사용 예

```shell
[root@localhost dir01]# touch {a,b,c}
[root@localhost dir01]# ls
a  b  c
```

```shell
[root@localhost dir01]# rm -rf {a..c}
```

```shell
[root@localhost dir01]# touch z{a{1..10},b{01..10},c{001..100}}
[root@localhost dir01]# ls
za1   zb01  zc001  zc011  zc021  zc031  zc041  zc051  zc061  zc071  zc081  zc091
za10  zb02  zc002  zc012  zc022  zc032  zc042  zc052  zc062  zc072  zc082  zc092
za2   zb03  zc003  zc013  zc023  zc033  zc043  zc053  zc063  zc073  zc083  zc093
za3   zb04  zc004  zc014  zc024  zc034  zc044  zc054  zc064  zc074  zc084  zc094
za4   zb05  zc005  zc015  zc025  zc035  zc045  zc055  zc065  zc075  zc085  zc095
za5   zb06  zc006  zc016  zc026  zc036  zc046  zc056  zc066  zc076  zc086  zc096
za6   zb07  zc007  zc017  zc027  zc037  zc047  zc057  zc067  zc077  zc087  zc097
za7   zb08  zc008  zc018  zc028  zc038  zc048  zc058  zc068  zc078  zc088  zc098
za8   zb09  zc009  zc019  zc029  zc039  zc049  zc059  zc069  zc079  zc089  zc099
za9   zb10  zc010  zc020  zc030  zc040  zc050  zc060  zc070  zc080  zc090  zc100
```

```shell
[root@localhost dir01]# rm -f z{a?,a10,b??,c*}
```

<br>

<br>

<h2>인용 부호 메타 문자(echo와 사용시)</h2>

- echo와 사용 시에 적용

<img src="C:\Users\USER\Desktop\인용부호 메타문자.PNG" style="zoom:90%;" />

- 사용 예

```shell
[root@localhost dir01]# echo "date is $(date)"
date is 2022. 02. 21. (월) 03:30:19 EST

[root@localhost dir01]# echo 'date is $(date)'
date is $(date)

[root@localhost dir01]# echo "date is `date`"
date is 2022. 02. 21. (월) 03:31:50 EST

[root@localhost dir01]# echo "\`date\` is `date`"
`date` is 2022. 02. 21. (월) 03:32:11 EST
```

<br>

<br>

<h2>방향 재지정 메타 문자</h2>

- I/O 관련

<img src="C:\Users\USER\Desktop\방향 재지정 메타 문자.PNG" style="zoom:90%;" />

- <h4>표준 입출력</h4>

  <img src="C:\Users\USER\Desktop\표준 입출력.PNG" style="zoom:90%;" />

  -  **리디렉션(redirection) 사용법**

  <img src="C:\Users\USER\Desktop\redirection 사용법.PNG" style="zoom:90%;" />

  -  사용 예

```shell
[root@localhost dir01]# date 1> r01
[root@localhost dir01]# cat r01
2022. 02. 21. (월) 04:15:21 EST
```

```shell
[root@localhost dir01]# find / -perm -2000 > r03 2>&1
[root@localhost dir01]# cat r03
find: ‘/proc/5126/task/5126/fd/5’: 그런 파일이나 디렉터리가 없습니다
find: ‘/proc/5126/task/5126/fdinfo/5’: 그런 파일이나 디렉터리가 없습니다
find: ‘/proc/5126/fd/6’: 그런 파일이나 디렉터리가 없습니다
find: ‘/proc/5126/fdinfo/6’: 그런 파일이나 디렉터리가 없습니다
find: ‘/run/user/1000/gvfs’: 허가 거부
/run/log/journal
/run/log/journal/092c802715504b6f8575e745f2daaed4
/usr/bin/write
/usr/bin/locate
/usr/sbin/lockdev
/usr/libexec/utempter/utempter
/usr/libexec/openssh/ssh-keysign
/tmp/usr/bin/write
/tmp/usr/bin/locate
```

```shell
[root@localhost dir01]# echo "hello" > test.txt
[root@localhost dir01]# cat test.txt
hello
[root@localhost dir01]# echo "next hello" >> test.txt
[root@localhost dir01]# cat test.txt
hello
next hello
```

```shell
[root@localhost dir01]# ln aaa bbb
ln: failed to access 'aaa': 그런 파일이나 디렉터리가 없습니다
[root@localhost dir01]# ln aaa bbb 2> errro.txt
[root@localhost dir01]# cat error.txt
cat: error.txt: 그런 파일이나 디렉터리가 없습니다
```

```shell
[root@localhost dir01]# ln aaa bbb 2> /dev/null
```



- **파이프(pipe)** : 한 프로그램의 출력을 중간 파일 없이 다른 파일의 입력으로 바로 보내는 유닉스 메커니즘
  - 파이프는 파이프(|) 기호 왼쪽 명령어의 출력을 오른쪽 명령어의 입력으로  보낸다
  - 파이프라인은 하나 이상의 파이프로 구성
  - 사용 예

```shell
[root@localhost dir01]# cat /etc/profile | more
```

```shell
[root@localhost dir01]# cat /etc/passwd | sort -r | more
```

<br>

<br>

<h2>shell 메타 문자 실습(문제)</h2>

1.  /etc/ 로 이동 후에 틸드(~) 문자를 사용하여 현 사용자의 디렉토리로 이동하시오.

``` shell
[root@localhost dir01]# cd /etc
[root@localhost etc]# cd ~
[root@localhost ~]#
```

2. /etc/sysconfig/network-scripts/로 이동 후에 홈으로 다시 이동 - 문자를 사용해서 이동해 보시오.

```shell
[root@localhost ~]# cd /etc/sysconfig/network-scripts/
[root@localhost network-scripts]# cd -
/root
[root@localhost ~]#
```

3. 이전 문제에 이어, 자신의 홈 디렉토리로 이동된 상태에서 /etc/sysconfig/network-scripts 디렉토리의 내용을 확인해보시오. (틸드 문자 ~ 이용)

```shell
[root@localhost ~]# ls ~-/
ifcfg-ens160
```

4. /media 디렉토리 안에 superman-season(1~3) 디렉토리를 각각 만들고 superman-season(1~3)-drama(01~10).avi 파일 생성 후에 이름에 맞추어 각각 넣으시오. (파일 이동시 최대한 간단하게 작성)

```shell
[root@localhost media]# mkdir /superman-season{1..3}
[root@localhost media]# touch superman-season{1..3}-drama{01..10}.avi
[root@localhost media]# mv *n1*i /*1
[root@localhost media]# mv *n2*i /*2
[root@localhost media]# mv *n3*i /*3
[root@localhost ~]# ls -lR /superman-season{1..3}
/superman-season1:
합계 0
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season1-drama01.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season1-drama02.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season1-drama03.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season1-drama04.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season1-drama05.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season1-drama06.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season1-drama07.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season1-drama08.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season1-drama09.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season1-drama10.avi

/superman-season2:
합계 0
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season2-drama01.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season2-drama02.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season2-drama03.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season2-drama04.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season2-drama05.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season2-drama06.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season2-drama07.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season2-drama08.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season2-drama09.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season2-drama10.avi

/superman-season3:
합계 0
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season3-drama01.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season3-drama02.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season3-drama03.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season3-drama04.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season3-drama05.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season3-drama06.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season3-drama07.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season3-drama08.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season3-drama09.avi
-rw-r--r--. 1 root root 0  2월 21 04:36 superman-season3-drama10.avi
```

5. ls -lR / 의 정상 출력 값은 ~/r01 에 입력하고, 에러값은 ~/r02에 입력하시오.

```shell
[root@localhost ~]# ls -lR / 1> ~/r01 2> ~/r02
```

6.  ls -lR / 의 모든 출력 값을 ~/r03에 입력하시오.

```shell
[root@localhost ~]# ls -lR / &> ~/r03
```

7. yum list 의 결과값 중에서 ssh 라는 패턴이 들어가는 것을 출력해보시오.

```shell
[root@localhost ~]# yum list | grep ssh
libssh.x86_64                                          0.9.4-2.el8                                            @anaconda
libssh-config.noarch                                   0.9.4-2.el8                                            @anaconda
openssh.x86_64                                         8.0p1-5.el8                                            @anaconda
openssh-askpass.x86_64                                 8.0p1-5.el8                                            @AppStream
openssh-clients.x86_64                                 8.0p1-5.el8                                            @anaconda
openssh-server.x86_64                                  8.0p1-5.el8   
...
```

8. 7번의 결과를 r04에 저장하시오(여러가지 가능)

```shell
[root@localhost ~]# yum list | grep ssh > r04
[root@localhost ~]# cat r04
libssh.x86_64                                          0.9.4-2.el8                                            @anaconda
libssh-config.noarch                                   0.9.4-2.el8                                            @anaconda
openssh.x86_64                                         8.0p1-5.el8                                            @anaconda
openssh-askpass.x86_64                                 8.0p1-5.el8                                            @AppStream
openssh-clients.x86_64                                 8.0p1-5.el8                                            @anaconda
openssh-server.x86_64                                  8.0p1-5.el8                                            @anaconda
```

