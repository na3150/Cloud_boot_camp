# [Docker] Dockerfile

<br>

### 📌Index

- [Dockerfile이란?](#dockerfile이란)
-  [Dockerfile 지시어](#dockerfile-지시어)

<br>

<br>

## Dockerfile이란?

[Dockerfile reference | Docker Documentation](https://docs.docker.com/engine/reference/builder/)

`VagrantFile` 처럼 파일 이름은 `Dockerfile`로 정해져있고, **이미지를 어떻게 만들 지에 대한 정의**를 한다.

`Dockerfile`은 컨테이너에 설치해야하는 패키지, 소스코드, 명령어, 환경변수설정 등을 기록한 하나의 파일로, 

빌드하면 자동으로 이미지가 생성되므로 `애플리케이션 빌드 및 배포를 자동화`할 수 있게 된다.

<br>

#### build

`docker build` 명령어를 실행하면,  `Dockerfile`에 정의된 대로 이미지를 빌드하게 되고, 

`Dockerfile`이 있는 디렉토리에서 진행해야한다. 

이때, `/` 루트 디렉토리에서 진행하지 않는 것을 권장하는데, 루트 디렉토리의 모든 파일 시스템을 올려버리게 되기 때문이다. 

```shell
$ docker build .
```

`-t` 옵션으로 태그 지정

- 태그가 여러개일 경우, `-t` 옵션을 여러번 붙여서 진행하면 된다.

```shell
$ docker build -t shykes/myapp .
```

<br>

#### Dockerfile 작성 포맷

INSTRUCTION(지시어)은 대문자로 사용하는 것이 원칙이나, 문법적 오류는 아니다.

```shell
# Comment
INSTRUCTION arguments
```

<br>

<br>

## Dockerfile 지시어

#### FROM

[FROM](https://docs.docker.com/engine/reference/builder/#from)

`Base Image`를 지정하는 것으로, 가능한한 latest는 사용하지 않는다.

```
FROM <image>
FROM <image>[:<tag>]
FROM <image>[@<digest>]
```

<br>

#### RUN

이미지를 빌드할 때(하는 중에) **base image에 실행할 명령어**를 입력한다.

command를 실행하는 것으로, `shell form`과 `exec form`이 있고, **`RUN`이 실행될 때마다 `layer`가 만들어진다.** 

- `RUN` 행 각각이 컨테이너를 만들고 실행 후 `commit`되는 것
- 하나의 `layer`로 만들고 싶다면 각 명령어를 `;`로 구분

<br>

##### `shell form` : 명령어를 나열하는 것

```
RUN yum install httpd
```

== `/bin/sh -c yum install httpd`

##### `exec form` : 대괄호로 리스트 입력

- 내부적으로는 C의 함수`exec` 를 실행하는 것
- 반드시 쌍따옴표(") 사용해야함
- `inspect`로 명령어로 살펴본 `Cmd`는 `exec form`이다

```
RUN ["yum", "install", "httpd"]
```

== `exec yum install httpd`

`exec form`으로 작성하는 것은 번거롭기 때문에, `RUN`은 일반적으로 `shell form`으로 작성한다.

<br>

#### CMD

**⭐`CMD`는  `shell form`을 사용하면 안된다**

- stop 시 비정상 오류`(return code != 0)`가 발생할 수 있기 때문
- **shell은 시그널을 하위 프로세스로 전달하지 않는다**
- stop을 하면 시그널(`TERM` 15)을 shell로 보내게 되는데, shell은 시그널을 무시하고, 하위 프로세스로 보내지 않는다

<br>

`httpd` : httpd가 직접 신호를 받고 정상 종료된다.

내가 만든이미지: `/bin/sh -c ~~` 은 shell이 신호를 무시하고, 하위 프로세스로 시그널을 보내지 않기 때문에 

하위 프로세스는 아무런 작업을 하지 않게된다. 

`Docker`는 10초 동안 아무런 응답이 오지 않으면 9번 시그널을 보내서 강제 종료시키게 되는데, 

이러한 경우 **shell의 하위 프로세스는 강제 종료되는 상황이 발생**한다. 

강제 종료는 어떤 중요한 프로세스든 모두 중단시키겨버리기 때문에 문제가 될 수 있다.

따라서 `exec form`이 선호되며, **실제로 `exec form`만 사용**한다

<br>

#### ENTRYPOINT

`CMD`와 동일한 이유로 `exec form`이 선호되며, **실제로 `exec form`만 사용**한다

순서는 항상 `ENTRYPOINT`가 `CMD`보다  우선이며, 둘 중 아무것도 없는 경우는 허용되지 않는다(not allowed).

CASE 3가지(`shell form` 방식은 제외)

- `ENTRYPOINT` 만 있는 경우
- `ENTRYPOINT`, `CMD`가 있는 경우
- `CMD` 만 있는 경우

| ENTRYPOINT | CMD  | Result      |
| ---------- | ---- | ----------- |
| 없음       | 없음 | not allowed |
| 없음       | abc  | abc         |
| xyz        | 없음 | xyz         |
| xyz        | abc  | xyz abc     |

**`CMD`와 `ENTRYPOINT`의 차이**

```shell
ls -l
```

`ENTRYPOINT` : `ls`

`CMD` : `-l`

```shell
$ docker run xzx -F
```

`CMD`, `ENTRYPOINT` 두개를 함께 사용하는 경우 일반적으로 **entrypoint는 명령어, cmd는 argument/옵션으로 사용**

<br>

예시

```shell
FROM ubuntu
ENTRYPOINT ["top", "-b"]
CMD ["-c"]
```

<br>

#### USER

entrypoint와 cmd를 실행할 user를 지정할 수 있다. (default는 root)

```shell
USER <user>[:<group>]
```

<br>

#### EXPOSE

외부에 노출할 포트 및 프로토콜

```
EXPOSE <PORT>/<PROTOCOL>
```

<br>

#### ENV

쉘 환경 변수

```
ENV MY_NAME="John Doe"
ENV MY_DOG=Rex\ The\ Dog
ENV MY_CAT=fluffy
```

<br>

#### ADD/COPY

도커 호스트 -> 컨테이너 파일 복사

```
ADD <SRC> <DEST>
COPY <SRC> <DEST>
```

> ADD는 SRC로 URL 지정 가능

<br>

#### ENTRYPOINT

CMD의 명령으로 사용

| ENTRYPOINT | CMD  | Result  |
| ---------- | ---- | ------- |
| X          | X    | 허용X   |
| X          | abc  | abc     |
| xyz        | X    | xyz     |
| xyz        | abc  | xyz abc |

<br>

#### VOLUME

자동으로 마운트할 볼륨 마운트 포인트 지정

```
VOLUME /myvol
```

<br>

#### WORKDIR

실행 디렉토리를 상대 경로로 지정할 때 실행되는 위치(작업 디렉토리)로 

`RUN`, `CMD`, `ENTRYPOINT`, `COPY` ,`ADD` 지시어에 영향을 미치게 된다.

그러나 절대 경로로 작성하는 것이 안전하고 권장된다.

```
WORKDIR /usr/local
```

<br>

#### ONBUILD

이미지를 빌드할 때마다 실행할 명령어(작업)

<br>

#### STOPSIGNAL

이미지에 중지할 시그널을 지정할 수 있다. (default는 `SIGTERM` 15)

<br>

#### HEALTHCHECK

쿠버네티스에서는 사용되지 않는다. docker만 사용할 때 사용한다.

<br>

#### 레이어

`RUN`, `ADD`, `COPY` 레이어를 만듦

<br>

**📋실습**

```shell
$ mkdir -p ~/image-build/myweb
$ cd ~/image-build/myweb
```

`Dockerfile`

```shell
FROM centos:7
RUN yum install -y httpd
ADD index.html /var/www/html/index.html
CMD ["/usr/sbin/httpd", "-DFOREGROUND" ]
EXPOSE 80/tcp
```

`index.html`

```shell
hello dockerfile
```

```shell
docker build -t myweb:centos .
```

<br>
