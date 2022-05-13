# [Docker] Docker Compose

**Docker Compose**는 Docker의 IaC와 같은 것으로, yaml 코드를 통해 컨테이너를 어떻게 실행할 지 정의하는 것이다.

`docker-compose` 는 옛 명령어로, `docker compose`가 최근에 생긴 명령어이다.

<br>

<br>

**디렉토리 구성**

먼저 실습을 실행할 디렉토리를 만들자.

본 글에서는 총 3개의 실습을 진행할 예정인데, 각각 `example1` `exampl2` `exmple3` 디렉토리에서 진행할 예정이다.

```shell
$ mkdir compose
```

<br>

#### 📋 실습1

```shell
$ mkdir example1
$ cd compose/example1
```

Docker Compose 파일은 `docker-compose.yaml` 또는 `docker-compose.yml` 로 정해져있다.

아래와 같이 `docker-compose.yaml` 파일을 작성해보자.

`docker-compose.yaml`

```yaml
version: '3' #docker compose의 version

services:
  web: #컨테이너의 이름
    image: httpd #컨테이너를 실행하기 위한 이미지 지정
```

Docker Compose는 서비스를 컨테이너라는 개념으로 사용한다.

여기서 `web`은  컨테이너의 이름이고, 컨테이너를 실행하기 위한 이미지는 `httpd` 이다.

<br>

Docker Compose를 실행하는 방법은 아래와 같다.

- `up` : Container를 Create하고 Start

- `run` : 이미 만들어져있는 것을 실행

현재 우리는 아무것도 만들어져있지 않으므로 `up` 을 한다.

default는 `attach`모드로, `-d` 옵션을 통해 `detach` 모드로 실행할 수 있다.

```shell
$ docker compose up -d
[+] Running 2/2
 ⠿ Network example1_default  Created                                                         0.0s
 ⠿ Container example1-web-1  Started                                                         0.4s
```

명령을 실행하면 `docker-compose.yaml` 파일을 읽어서 만들게된다.

디렉토리의 이름을 프로젝트라고 하는데, 네트워크와 컨테이너 앞에 프로젝트 이름이 붙는다.

- `example1_default` : 디렉토리의 이름 `example1`이 앞에 붙음

- `example1-web-1` : [디렉토리이름]-[서비스명]-[서수]

```shell
$ docker compose ps
NAME                COMMAND              SERVICE             STATUS              PORTS
example1-web-1      "httpd-foreground"   web                 running             80/tcp
```

```shell
$ docker compose ls
NAME                STATUS              CONFIG FILES
example1            running(1)          /home/vagrant/compose/example1/docker-compose.yaml
```

- `docker compose ps`로 실행되고 있는 `SERVICE`(컨테이너) 목록을 확인할 수 있다. 
- `docker compose ls`로 실행되고 있는 프로젝트 목록을 확인할 수 있다.

<br>

컨테이너 중단하기

```shell
$ docker compose stop
[+] Running 1/1
 ⠿ Container example1-web-1  Stopped             
```

<br>

`up`의 반대는 `down` 으로 `docker compose down`을 실행하면 지워지게 된다. 

```shell
$ docker compose down
[+] Running 2/2
 ⠿ Container example1-web-1  Removed                                                         1.1s
 ⠿ Network example1_default  Removed
```

그러나 `down`을 해도 `volume`은 삭제되지 않기 때문에, `-v` 옵션을 함께 사용해주는 것이 좋다.

```shell
$ docker compose down -v
```

<br>

<br>

#### 📋 실습2

두번째 실습을 진행하기 위한 환경(디렉토리)를 만들자

```shell
$ mkdir example2
$ cd compose/example2
```

아래와 같이 `docker-compose.yaml` 파일을 작성한다.

`docker-compose.yaml`

```yaml
version: '3'

services:
  web: #서비스명
    image: httpd #base image
    restart: always
    ports:
      - 80:80
    environment: #환경변수
      MSG: hello world
    volumes:     #연결할 볼륨
      - web-contents:/var/www/html
    networks:    #연결할 네트워크
      - web-net
  web2: #서비스명
    image: nginx
    networks:
      - web-net

volumes:
  web-contents:

networks:
  web-net:
```

- `ports` : 포트포워딩 (호스트:컨테이너)
- `docker compose`로 배포한 컨테이너들은 서로 이름을 통해 가리킬 수 있음 : `web` , `web2`

- `volume` : 볼륨의 이름을 지정할 수 있고, 여기서는 `web1` 컨테이너에 마운트됨
- `networks` : 네트워크의 이름을 부여할 수 있음

<br>

docker container를 실행한다.

```shell
$ docker compose up -d     
[+] Running 2/2
 ⠿ Container example2-web-1   Started                                                  0.5s
 ⠿ Container example2-web2-1  Started           
```

잘 실행되고 있는지 확인해보자

```shell
$ docker network ls   
NETWORK ID     NAME               DRIVER    SCOPE
0fcbc713898a   example1_default   bridge    local
4b99c98dcece   example2_web-net   bridge    local
```

```shell
$ docker compose ls   
NAME                STATUS              CONFIG FILES
example2            running(2)          /home/vagrant/compose/example2/docker-compose.yaml
```

`web1`의 포트포워딩 확인

```shell
$ docker compose ps
NAME                COMMAND                  SERVICE             STATUS              PORTS
example2-web-1      "httpd-foreground"       web                 running             0.0.0.0:80->80/tcp, :::80->80/tcp
example2-web2-1     "/docker-entrypoint.…"   web2                running             80/tcp
```

```shell
$ docker volume ls 
DRIVER    VOLUME NAME
local     d6683d9aedd18676fb97c0b275d1620b17a2f26317f8bbe69f89e1f91b7cd874
local     example1_web-contents
local     example2_web-contents
```

**docker compose exec**

```shell
$ docker compose exec [서비스명] [실행할 애플리케이션]
```

```shell
$ docker compose exec web bash 
root@4f13d26be453:/usr/local/apache2# 
```

`MSG` 변수가 잘 설정된 것을 확인할 수 있다.

```shell
root@4f13d26be453:/usr/local/apache2# echo $MSG
hello world
```

`curl` 테스트를 위해 `curl`을 설치해보자

```shell
root@4f13d26be453:/usr/local/apache2# apt update; apt install curl
```

**`docker compose`로 배포한 컨테이너들은 `--link` 없이 서로 이름으로 통신이 가능**하다.

```yaml
root@4f13d26be453:/usr/local/apache2# curl web2
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

<br>

<br>

#### 📋 실습3

세번째 실습을 진행하기 위한 환경(디렉토리)를 만들자

```shell
$ mkdir example3
$ cd compose/example3
```

아래와 같이 `docker-compose.yaml` 파일을 작성한다.

`docker-compose.yaml`

```yaml
version: '3'

services:

  myflask:
    build: ./hello-flask

  mydjango:
    build: ./hello-django
```

서비스는 기존의 이미지로 컨테이너를 만들 수 있고, **`Dockerfile`을 build해서 바로 실행할 수 있다.**

여기서는 [myflask](https://nayoungs.tistory.com/167#%E-%-C%--%EF%B-%-F%--Flask%--App%EC%-C%BC%EB%A-%-C%--Docker%--%EC%-D%B-%EB%AF%B-%EC%A-%--%--%EB%A-%-C%EB%--%A-%EA%B-%B-)와 [mydjango](https://nayoungs.tistory.com/168#%E-%-C%--%EF%B-%-F%--%C-%A-Django%--App%EC%-C%BC%EB%A-%-C%--Docker%--%EC%-D%B-%EB%AF%B-%EC%A-%--%--%EB%A-%-C%EB%--%A-%EA%B-%B-)의 `Dockerfile`로 바로 실행해볼 것이다. 

현재 디렉토리로 복사하기

```shell
$ cp -r ~/python/hello-django .
$ cp -r ~/python/hello-flask .
```

컨테이너를 시작해보자.

`docker compose up`하면 이미지를 빌드하게 된다.

```shell
$ docker compose up -d          
Sending build context to Docker daemon   13.1MB
...
[+] Running 3/3
 ⠿ Network example3_default       Created                                              0.0s
 ⠿ Container example3-mydjango-1  Started                                              0.6s
 ⠿ Container example3-myflask-1   Started                                              0.7s
```

확인해보기

```shell
$ docker compose ps   
NAME                  COMMAND                  SERVICE             STATUS              PORTS
example3-mydjango-1   "python3 manage.py r…"   mydjango            running             8000/tcp
example3-myflask-1    "python3 -m flask ru…"   myflask             running             5000/tcp
```

<br>

<br>

실습 끝나고 `docker compose down -v` 하는 것 잊지말기!
