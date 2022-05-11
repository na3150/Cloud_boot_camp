# [Linux] shell 변수(variable) : 매개변수

<br>

`shell` 에서 변수를 선언할 때는 다른 프로그래밍 언어와 마찬가지로 `=` 을 사용한다.

쉘에서 스크립트로 **매개변수**를 보내줄 수도 있는데, 규칙은 아래와 같다

```
$0           : 현재 쉘 스크립트의 이름                                  
$#           : 위치 매개변수의 총 개수                       
$*           : 모든 위치 매개변수                             
$@           : 큰 따옴표를 사용하였을 때를 제외하고는 $*와 동일한 의미                   
$1 ... ${10} : 사용가능한 위치 매개변수         
```

<br>

`a.sh` 을 다음과 같이 작성하였다.

```shell
#!/bin/sh

echo "\$MSG = $MSG"
echo "\$@ = $@"
echo "\$0 = $0"
echo "\$1 = $1"
```

실행할 수 있는 권한을 부여하고, ` shell script`를 실행시켜보자.

```shell
$chmod +x a.sh
$ ./a.sh  
```

`$0`은 `shell script`의 이름이 할당되므로, `./a.sh`이다. 

```shell
$MSG = 
$@ = 
$0 = ./a.sh
$1 = 
```

`argument`를 붙인 경우

`a.sh` 을 다음과 같이 작성하였다.

```shell
#!/bin/sh

echo "\$MSG = $MSG"
echo "\$@ = $@"
echo "\$0 = $0"
echo "\$1 = $1"
echo "\$2 = $2"
```

명령어를 제외하고 나머지 인자들은 모두 `@`이다. (==특수변수이다)

`/a.sh`에 변수 `abc`와 `xyz` 를 전달해주는 것!

```shell
$ ./a.sh abc xyz
```

 `./a.sh`가 $0, 그 뒤로 차례대로 `abc`가 $1, `xyz`는 $2에 할당된다. 

```shell
$MSG = 
$@ = abc xyz
$0 = ./a.sh
$1 = abc
$2 = xyz
```

다음과 같이 `env` 명령에 나와야만(내보내기를 해야만) `shell script`에서 변수를 참조할 수 있다.

```shell
$ export MSG="hello MESSAGE"
$ ./a.sh abc xyz
```

```shell
$MSG = hello MESSAGE
$@ = abc xyz
$0 = ./a.sh
$1 = abc
$2 = xyz
```

또한, **명령어 앞에 변수를 정의**함으로써 **해당 명령에만 scope이 한정되는 변수**를 정의하는 것도 가능하다. 

```shell
$ MSG="hello world" ./a.sh abc xyz
```

```shell
$MSG = hello world
$@ = abc xyz
$0 = ./a.sh
$1 = abc
$2 = xyz
```

<br>

<br>📋`httpd` 이미지에서 `/usr/local/bin/httpd-foreground` 파일을 확인해보자

```shell
$ docker run -it httpd bash                       
root@8ebeec201ca9:/usr/local/apache2# cat /usr/local/bin/httpd-foreground 
```

여기서 `$@`는 무슨 의미일까❔

```shell
#!/bin/sh
set -e

# Apache gets grumpy about PID files pre-existing
rm -f /usr/local/apache2/logs/httpd.pid

exec httpd -DFOREGROUND "$@"
```

`./httpd-foreground [option|argument]` 명령의 `[option|argument]`가 `$@`에 들어가게 된다. 

<br>