<h2>[Linux] shell(script) 기본 문법 정리</h2>



<h3>📌INDEX</h3>

- [shell이란?](#shell이란)

- [shell script란?](#shell script란)
- [shell script 문법](#shell-script-문법)
  - [기본 출력](#기본-출력)
  - [변수](#변수)
  - [종료 상태(Exit Status)](#종료-상태exit-status)
  - [명령어의 연속 실행](#명령어의-연속-실행)
  - [기본 입력](#기본-입력)
  - [크기 비교(조건문)](#크기-비교조건문)
  - [if 문](#if-문)
  - [while 문](#while-문)
  - [until loop](#until-loop)
  - [for 문](#for-문)



<br>

<br>

<h2>shell이란?</h2>

- 리눅스의 shell은 **명령어와 프로그램을 실행할 때 사용하는 인터페이스**로, **커널(kernel)과 사용자(user)간의 다리**역할을 한다.
  - 사용자로부터 명령을 받아 그것을 해석하고 프로그램을 실행
- 쉽게 말해, '터미널' 처럼 명령어를 입력하는 환경

<img src="C:\Users\USER\Desktop\shell이란.PNG" style="zoom:50%;" />

- **shell의 기능**
  - 자체 내에 프로그래밍 기능이 있어, 프로그램 작성 가능
  - 초기화 파일 기능을 이용하여 사용자의 환경 설정 가능
  - 사용자와 커널 사이에서 명령을 해석해 전달하는 명령어 해석 기능

- **bash** : 리눅스의 표준 shell
  - /bin/bash

- 사용중인 shell은 다음과 같은 과정을 통해 확인할 수 있다.

```shell
[root@localhost ~]# echo $SHELL
/bin/bash
```

- 사용자의 기본 shell의 변경은 시스템 관리자만 가능하고, 일반 사용자는 현재 실행중인 shell을 임시로만 변경가능



<br>

<br>

<h2>shell script란?</h2>

- **shell에서 사용할 수 있는 명령어들의 조합**을 모아서 만든 배치(batch)파일
- 스크립트(script) : **인터프리터(interpreter)**에 의해 해석/실행되는 프로그램
  - 인터프리터 방식: 한줄씩 순차적으로 읽으면서 명령어 실행
- 우리는 이미 많은 shell script를 사용하고 있다. file과 grep 명령어를 통해 확인해보자.

```shell
[root@localhost ~]# cd /bin ; file * | grep "shell script"
Xorg:                               POSIX shell script, ASCII text executable
alias:                              POSIX shell script, ASCII text executable
alsaunmute:                         POSIX shell script, ASCII text executable
amuFormat.sh:                       POSIX shell script, ASCII text executable
anaconda-disable-nm-ibft-plugin:    POSIX shell script, ASCII text executable
bashbug-64:                         POSIX shell script, ASCII text executable, with very long lines
batch:                              POSIX shell script, ASCII text executable
bg:                                 POSIX shell script, ASCII text executable
....
```

- shell script는 내용이 텍스트 형식이라는 특징을 가지고 있어, 일반 편집기로 내용을 확인할 수 있다. 
  - ex : cat , vi, emacs 등
- **' #! ' 다음에 script를 실행할 인터프리터와 실행 옵션을 지정**한다.
- shell script 에서는  \#!/bin/sh, #!/bin/csh, #!/bin/bash, #!/bin/ksh, #!/bin/tcsh와 같이 shell의 절대 경로를 써준다
  - \#!만 써줄 경우에는 #!/bin/sh로 인식
- **shell script** 기본 구조

```shell
#!/bin/bash
echo 'hi, Linux'
```

- **실행 권한이 없을 때 : bash [파일명]**
- **실행 권한 있을 때 : ./[파일명]**

```shell
[root@localhost bin]# ls -l test.sh
-rw-r--r--. 1 root root 30  2월 20 01:44 test.sh
[root@localhost bin]# chmod u+x test.sh
[root@localhost bin]# ./test.sh
hi, Linux
```

<br>

<br>

<h2>shell script 문법</h2>

- <h4>기본 출력</h4>

  - **echo**또는 print를 사용한다.
  - 사용 예

  ```shell
  [root@localhost bin]# cat echo_test.sh
  #!/bin/bash
  echo "Red"
  echo "Blue"
  echo "Yellow"
  [root@localhost bin]# bash echo_test.sh
  Red
  Blue
  Yellow
  ```

  

- <h4>변수</h4>

  - 형식 : 변수명=변수값
    - 주의 : 변수명 다음에 오는 **'=' 의 좌우로 공백이 있으면 안된다.**
    - 변수명은 대문자를 사용하는 것을 권장
  - **$을 이용하여 변수를 호출**(ACCESS)
    - shell에서 **$0은 파일 이름**이다.
    - **"${변수명}"** 과 같이도 사용 가능
  - **echo "[실행문]"** : $A와 같은 변수가 들어가도, 변수의 값 처리됨**(변수로 인식)**
    - ex:  echo "ls  /proc | grep ^[0-9]" 
  - **echo '[실행문]'** : **$A(변수)를 문자로 처리(문자로 인식)**
    - echo 'ls  /proc | grep ^[0-9]'
  - echo (백틱) [실행문] (백틱)  : 백쿼테이션**(``) 사이의 명령을 실행**하여 처리
    - 일반적으로 ``(backtick)는 명령어 전환(command substitution)에 쓰인다
  - echo $([실행문]) : **$() 사이에 명령어와 변수를 넣어주면 실행**하여 처리
  - 예시

  ```shell
  [root@localhost bin]# korea="republic of korea"
  [root@localhost bin]# echo $korea
  republic of korea
  ```

  

- <h4>종료 상태(Exit Status)</h4>

  - 각 명령어들은 실행을 마치고 정상적인 종료(성공/참)하거나, 실행 오류 또는 인터럽트에 의한 중단과 같은 이유로 비정상적으로 종료(실패/거짓)할 수 있다.
  - 이러한 성공과 실패는 명령의 종료 상태값으로 알 수 있다.
  - **0 : 성공 |  0이 아닌 값 : 실패**
  - shell에서는 이전에 실행한 명령의 성공여부를 ' ? ' 변수값에 저장

  ```shell
  [root@localhost bin]# false
  [root@localhost bin]# echo $?
  1
  [root@localhost bin]# true
  [root@localhost bin]# echo $?
  0
  ```

  - exit를 이용하여 script를 종료하면서 종료 상태를 반환할 수 있다.

    - exit [숫자] : 종료하고 [숫자] 값을 shell에 반환

    

- <h4>명령어의 연속 실행</h4>

  -  파이프 라인과 다르게, 일반적으로 명령어를 연속하여 선언할 때는 ' ; ', '&&' 부호를 사용
  - [선행 명령] **;** [후행 명령] : **선행 명령의 참, 거짓 상관없이 후행 명령**을 실행
    - 일반적으로 명령 작업들 사이에 관련이 없을 때 사용
  - [선행 명령] **&&** [후행 명령] : **선행 명령이 참일 경우에만 후행 명령**을 실행
    - 일반적으로 명령 작업들 사이의 관계가 연관이 있을 때 사용
  - 사용 예

  ```shell
  [root@localhost bin]# cat aaa ; cat bbb
  cat: aaa: 그런 파일이나 디렉터리가 없습니다
  이것은 bbb 파일이다.
  ```

   ```shell
   [root@localhost bin]# cat aaa && cat bbb
   cat: aaa: 그런 파일이나 디렉터리가 없습니다
   ```



- <h4>기본 입력</h4>

  - **read** 를 사용한다(타이핑 치는 값을 받아옴)
  - 사용 예

  ```shell
  [root@localhost bin]# cat > read.sh
  #!/bin/bash
  echo "age?"
  read x
  echo "You are $x years old"
  [root@localhost bin]# bash read.sh
  age?
  23
  You are 23 years old
  ```

  

- <h4>크기 비교(조건문)</h4>

  - [$A –gt $B] : A값이 B값보다 크다
  - [$A –lt $B] : A값이 B값보다 작다
  - [$A –ge $B] : A값이 B값보다 크거나 같다
  - [$A –le $B] : A값이 B값보다 작거나 같다
  - [$A –eq $B] : A값과 B값이 같다
  - [$A –ne $B] : A값과 B값이 다르다



- <h4>if 문</h4>

  - 참(0),거짓(0이 아닌 값)을 제외하고, 다른 프로그래밍 언어의 if문과 유사
  - **if의 조건식이 참이면(0을 반환하면), then 다음의 명령들을 수행**
  - if의 조건식이 거짓이면(0이 아닌 값을 반환하면), else 다음의 명령을 수행
  - if 구문은 조건식에 따라서 분기를 한다.
  - fi를 만나면 종료
  - if를 쓰지 않아도 [](대괄호)사이에 조건식을 쓰면, 조건식으로 인식한다.
  - 형식

  ```shell
  if 조건식 
  then 
      실행문 
  [ elif 조건식 
  then 
      실행문
  ] 
  [ else 
      실행문
  ] 
  fi
  ```

  - 사용 예

  ```shell
  [root@localhost bin]# cat number.sh
  #!/bin/sh
  
  echo "A?"
  read A
  echo "B?"
  read B
  
  if [ $A -eq $B ]
  then
     echo "$A is equal to $B"
  elif [ $A -gt $B ]
  then
     echo "$A is greater than $B"
  elif [ $A -lt $B ]
  then
     echo "$A is less than $B"
  fi
  [root@localhost bin]# bash number.sh
  A?
  10
  B?
  8
  10 is greater than 8
  ```

  

- <h4>While 문</h4>

  - while루프는 **조건식이 참인 동안 do ~ done 사이의 명령을 수행**
  - done : while문 종료
  - 형식

  ```shell
  while [조건식]
  do
      실행문
  done 
  ```

  - 사용 예

  ```shell
  [root@localhost ~]# cat while_test.sh
  #! /bin/ksh
  
  number=1
  
  while [ $number -le 5 ]
  do
          echo $number
          number=$(($number+1))
  done
  [root@localhost ~]# bash while_test.sh
  1
  2
  3
  4
  5
  ```



- <h4>until loop</h4>

  - **조건이 false인 동안 반복**하며, **true이면 반복문 종료**
  - until은 조건이 반대라는 것을 제외하고 while과 동일
  - 형식

  ```shell
  until [ 조건문 ]
  do
     실행문
  done
  ```

  - 사용 예

  ```shell
  [root@localhost ~]# cat until_test.sh
  #!/bin/bash
  
  number=0
  until [ $number -ge 5 ]
  do
      number=$(($number + 1))
      echo $number
  done
  [root@localhost ~]# bash until_test.sh
  1
  2
  3
  4
  5
  ```

  



- <h4>for 문</h4>

  - 형식 1

  ```shell
  for 변수 in 값
  do
      실행문
  done
  ```

  - 사용 예

  ```shell
  [root@localhost ~]# cat for_test.sh
  #!/bin/bash
  
  for i in $(ls)
  do
     echo $i
  done
  [root@localhost ~]# bash for_test.sh
  \
  :
  =
  aa
  ab.tar
  anaconda-ks.cfg
  argument.sh
  awkfile1
  awkfile2
  awkfilter2
  bb
  bbb
  ....
  ```

  - 형식 2

  ```shell
  for ((초기값;조건식;증감))
  do
      실행문
  done
  ```

  - 사용 예

  ```shell
  [root@localhost ~]# cat for_test2.sh
  #!/bin/bash
  
  for ((i=0;i<10;i++))
  do
       echo $i
  done
  
  [root@localhost ~]# bash for_test2.sh
  0
  1
  2
  3
  4
  5
  6
  7
  8
  9
  ```

  

