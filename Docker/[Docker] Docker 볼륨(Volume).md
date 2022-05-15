# [Docker] Docker 볼륨(Volume)

<br>

### 📌Index

- [Volume이란?](#volume이란)
- [볼륨 방식 마운트](#볼륨-방식-마운트)
- [바인드 방식 마운트](#볼륨-방식-마운트)
- [사용 용도](#사용-용도)

<br>

<br>

## ✔️ Volume이란?

Docker 컨테이너(container)에 쓰여진 데이터(새로 추가한 rw layer)는 기본적으로 컨테이너가 삭제될 때 함께 사라지게 된다.

Docker에서 돌아가는 많은 애플리케이션(특히 `MySQL`과 같은 DB)은 컨테이너의 생명 주기와 관계없이 데이터를 영속적으로 저장해야하고, 많은 경우 여러 개의 Docker 컨테이너가 하나의 저장 공간을 공유해서 데이터를 읽거나 써야한다. 

이렇게 Docker 컨테이너의 생명 주기와 관계없이 데이터를 영속적으로 저장할 수 있도록 별개의 공간인, `Volume`이 필요하다.

<br>

이미지의 `Config.Volumes` 선언되어 있으면, 자동으로 Docker 볼륨이 생성되고 마운트되며, 수동으로 마운트하는 것도 가능하다.

`/var/lib/docker/volumes/[volume명]/_data`가 실제 사용하는, 마운트된 디렉토리이다

<br>

<br>

## ✔️ 볼륨 방식 마운트
볼륨은 읽기-쓰기가 가능한 빈 저장소를 생성하는 것이 기본이고, 볼륨은 도커 데몬이 관리한다. 

<br>

#### 빈 볼륨 생성하기

```
docker volume create <NAME>
```

예시

```shell
$ docker volume create test-vol 
```

```shell
$ docker volume ls             
DRIVER    VOLUME NAME
local     test-vol
```

빈 볼륨이므로 `/var/lib/docker/volumes/test-vol/_data`를 확인해도 아직은 아무것도 없다.

```shell
$ docker inspect test-vol           
[
    {
        "CreatedAt": "2022-05-15T12:52:47Z",
        "Driver": "local",
        "Labels": {},
        "Mountpoint": "/var/lib/docker/volumes/test-vol/_data",
        "Name": "test-vol",
        "Options": {},
        "Scope": "local"
    }
]
```

<br>

#### 볼륨 목록 확인하기

```shell
$ docker volume ls
```

<br>

#### 볼륨 삭제하기

```shell
$ docker volume rm <NAME>
```

<br>

#### 사용하지 않는 볼륨 삭제하기

사용되지 않는다는 것은 컨테이너에 마운트되지 않았다는 뜻이다.

```shell
$ docker volume prune
```

<br>

#### 볼륨을 사용한 컨테이너

`docker run`의 `-v`옵션을 통해 볼륨을 연결할 수 있다.

`ro` : `Read-Only` 설정, default는 `rw` 이다.

`<MOUNTPOINT>`는 컨테이너 내부의 마운트할 위치로, **디렉토리가 만들어져있지 않더라도 알아서 만들게 된다.**

```shell
$ docker run -v <VOL-NAME>:<MOUNTPOINT>[:ro] <IMAGE>
```

**예시1**

```shell
$ docker run -itd -v test-vol:/test-vol ubuntu
```

생성된 컨테이너를 확인해보면 `Mounts`에서 `Destination`이 `/test-vol`으로 설정된 것을 확인할 수 있다.

```shell
$ docker inspect 5c 
...
 "Mounts": [
            {
                "Type": "volume",
                "Name": "test-vol",
                "Source": "/var/lib/docker/volumes/test-vol/_data",
                "Destination": "/test-vol",
                "Driver": "local",
                "Mode": "z",
                "RW": true,
                "Propagation": ""
            }
        ],
        ...
```

컨테이너에 접속해서 `/test-vol` 디렉토리에 `hello.txt` 파일을 생성해보자.

```shell
$ docker exec -it 5c bash          
root@5c80ed5ed7c5:/# ls
bin   dev  home  lib32  libx32  mnt  proc  run   srv  test-vol  usr
boot  etc  lib   lib64  media   opt  root  sbin  sys  tmp       var
root@5c80ed5ed7c5:/# cd test-vol/
root@5c80ed5ed7c5:/test-vol# ls
root@5c80ed5ed7c5:/test-vol# echo "hello volume" > hello.txt
root@5c80ed5ed7c5:/test-vol# exit
```

`/var/lib/docker/volumes/test-vol/_data ` 에 `hello.txt`가 생성된 것을 확인할 수 있다.

```shell
$ sudo ls /var/lib/docker/volumes/test-vol/_data 
hello.txt
```

이때, **컨테이너를 지운다고해서 볼륨이 지워지는 것은 아니다.**

즉, **컨테이너의 라이프 사이클과 볼륨의 라이프 사이클은 별개**이다.

<br>

**예시2**

볼륨은 다음과 같이 여러개를 지정하는 것도 가능하다. (**볼륨은 여러개 있을 수 있다**)

```shell
$ docker run -itd -v abc:/abc -v xyz:/xyz: ubuntu
```

```shell
$ docker volume ls                               
DRIVER    VOLUME NAME
local     abc
local     xyz
```

```shell
$ docker inspect <container>
...
"Mounts": [
            {
                "Type": "volume",
                "Name": "abc",
                "Source": "/var/lib/docker/volumes/abc/_data",
                "Destination": "/abc",
                "Driver": "local",
                "Mode": "z",
                "RW": true,
                "Propagation": ""
            },
            {
                "Type": "volume",
                "Name": "xyz",
                "Source": "/var/lib/docker/volumes/xyz/_data",
                "Destination": "/xyz",
                "Driver": "local",
                "Mode": "z",
                "RW": true,
                "Propagation": ""
            }
        ],
...
```

<br>

**예시3**

아래의 명령을 실행해보자

```shell
$ docker run --name wp-db -d -v wp-db-vol:/var/lib/mysql mysql:5.7
b63565b20242657ef8ca4a91f346754fbbf1a8a9c1237db48fd37ce270d0ba9c
```

`mysql` 컨테이너에 환경변수를 설정하지 않았지만, 정상적으로 실행되었다.

왜 환경 변수 설정없이도 잘 실행되는 것일까❔

```shell
$ docker ps

CONTAINER ID   IMAGE       COMMAND                  CREATED         STATUS         PORTS                 NAMES
b63565b20242   mysql:5.7   "docker-entrypoint.s…"   4 seconds ago   Up 3 seconds   3306/tcp, 33060/tcp   wp-db
```

```shell
$ docker exec b6 env
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=95348375c379
GOSU_VERSION=1.14
MYSQL_MAJOR=5.7
MYSQL_VERSION=5.7.38-1debian10
HOME=/root
```

`wp-db`를 살펴보면 환경변수가 없는 것을 확인할 수 있는데, 

원래 `mysql` 또는 `mariadb` 컨테이너를 실행하기 위해서는 `root` 패스워드 설정이 중요하고, 이미지 내에는 `root` 패스워드가 없기 때문에 환경변수로 `root` 패스워드를 제공해줘야한다.

그러나 여기서는 컨테이너를 띄울 때 volume 즉 데이터베이스를 제공했기 때문에 그 내부에 `root` 패스워드가 있어 별도로 루트 패스워드를 설정할 필요 없이 컨테이너가 실행된 것이다. 

<br>
다음과 같이 기존 패스워드로는 정상적으로 접속할 수 있지만

```shell
$ docker exec -it b6 mysql -u wpadm -p
Enter password:
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 2
Server version: 5.7.38 MySQL Community Server (GPL)

Copyright (c) 2000, 2022, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>
```

패스워드를 변경한 뒤, 변경한 패스워드를 통해 로그인하려하면 접근이 불가능하다.

`-e`로 지정한 환경 변수는 무시되고, 볼륨에 있는 내용을  참조하고 있기 때문이다. 

```shell
$ docker run --name wp-db2 -d -e MYSQL_ROOT_PASSWORD=qwer1234 -e MYSQL_DATABASE=wordpress -e MYSQL_USER=wpadm -e MYSQL_PASSWORD=qwer1234 --restart always --cpus 0.5 --memory 1000m -v wp-db-vol:/var/lib/mysql mysql:5.7
WARNING: Your kernel does not support swap limit capabilities or the cgroup is not mounted. Memory limited without swap.
389245782e838f364604f3dab72790b772046eb93e2d967de58f534db140857e
$ docker ps
CONTAINER ID   IMAGE       COMMAND                  CREATED         STATUS         PORTS                 NAMES
37887g412411   mysql:5.7   "docker-entrypoint.s…"   3 seconds ago   Up 3 seconds   3306/tcp, 33060/tcp   wp-db2
b63565b20242   mysql:5.7   "docker-entrypoint.s…"   5 minutes ago   Up 5 minutes   3306/tcp, 33060/tcp   wp-db
```

심지어 다시 변경 전의 비밀번호로 접속하려고해도 접속이 불가능하다. 

```shell
$ docker exec -it 37 mysql -u wpadm -p
Enter password:
ERROR 2002 (HY000): Can't connect to local MySQL server through socket '/var/run/mysqld/mysqld.sock' (2)
```

결론: 이미 데이터베이스(볼륨)이 있는 상태에서 데이터베이스 환경변수를 설정해주면 오류가 발생한다.

또한 여기서 알 수 있는 한가지 사실이 더 있다.

**하나의 볼륨을 서로 다른 컨테이너가 동시에 마운트해서 사용할 수 있다**는 것이다. (여기서는 `wp-db`, `wp-db2`)

`VM`을 사용할 때는 이런 구성을 하기 위해 NFS를 사용했어야했다.

그리고 NFS는 동시에 읽기는 가능하나, `lock` 기능으로 인해 동시에 쓰기는 불가능 하다.

그러나 이러한 방식(컨테이너가 마운트 공유)은 `lock` 기능이 없고, 동시에 파일의 쓰기 작업도 가능하다.

다만 데이터가 깨지거나, 문제가 발생하거나 어떠한 결과를 초래할 지는 모른다.

<br>

**예시4**

아래의 명령을 실행해보자. `ro`는 `Read-Only` 옵션이다.

```shell
$ docker run -itd -v abc:/abc --name u1 ubuntu
$ docker run -itd -v abc:/abc:ro --name u2 ubuntu
```

`ro` 옵션을 주지 않은 `u1`은 `RW : true`로 설정되어있고,

```shell
$ docker inspect u1
"Mounts": [
            {
                "Type": "volume",
                "Name": "abc",
                "Source": "/var/lib/docker/volumes/abc/_data",
                "Destination": "/abc",
                "Driver": "local",
                "Mode": "z",
                "RW": true,
                "Propagation": ""
            }
        ],
```

`ro` 옵션을 준 `u2` 는 `RW : false` 로 설정되어있는 것을 확인할 수 있다. 

즉, 쓰기가 불가능하다. 

```shell
$ docker inspect u2
"Mounts": [
            {
                "Type": "volume",
                "Name": "abc",
                "Source": "/var/lib/docker/volumes/abc/_data",
                "Destination": "/abc",
                "Driver": "local",
                "Mode": "ro",
                "RW": false,
                "Propagation": ""
            }
        ],
```

<br>

<br>

## ✔️ 바인드 방식 마운트

바인드 방식은 **컨테이너에게 제공할 볼륨을 호스트의 특정 디렉토리를 지정**하는 방식이다. 
**호스트의 디렉토리를 컨테이너에게 제공**하는 것으로, 미리 데이터를 채워서 제공이 가능하다.

바인드 볼륨은 도커 데몬이 관리하지 않고, 사용자가 직접 관리한다. 

`bind` 방식의 볼륨은 `.Mounts`의 `Type`이 `bind`로 되어있다.

<br>

` <ABSOLUTE_PATH>` : 경로를 반드시 절대경로로 작성해야한다

```shell
$ docker run -v <ABSOLUTE_PATH>:<MOUNTPOINT>[:ro] <IMAGE>
```

마운트 방식과의 차이는 절대경로를 적는가, 볼륨 이름을 적는가의 차이이다.

<br>

**예시**

먼저 실습을 위한  `contents` 디렉토리를 만들고 본 디렉토리에 `hello.html` 파일을 생성해보자

```shell
$ mkdir contents
$ cd contents
$ echo "hello bind volume" > hello.html
```

그리고 다음과 같이 절대경로로 바인드 마운트 한 뒤,

```shell
$ docker run -itd -v /home/vagrant/contents:/abc ubuntu
```

`/abc` 디렉토리를 확인해보면 `hello.html` 이 있는 것을 확인할 수 있다.

```shell
$ docker exec -it d3e bash              
root@d3e21b276e15:/# ls abc
hello.html
```

또한,  `.Mounts`의 `Type`이 `bind`로 되어있는 것을 확인할 수 있다. 

볼륨 바인드 방식은 `volume`으로 설정되어있다. 

```shell
$ docker inspect <container>
...
  "Mounts": [
            {
                "Type": "bind",
                "Source": "/home/vagrant/contents",
                "Destination": "/abc",
                "Mode": "",
                "RW": true,
                "Propagation": "rprivate"
            }
        ],
...
```

<br>

**디렉토리 전체 마운트하기**

`httpd`는 기본적으로 `/usr/local/apache2/` 가 `working directory`이고 `/usr/local/apache2/htdocs`가 `httpd`의 `DocumentRoot` directory이다. 

```shell
$ docker run -d -v /home/vagrant/contents:/usr/local/apache2/htdocs httpd
```

<br>

**⭐ 파일 마운트하기**

파일을 파일로 마운트 하는 것이다. `file mounting`

```shell
$ docker run -d -v /home/vagrant/contents/hello.html:/usr/local/apache2/htdocs/hello.html httpd
```

디렉토리에 기존의 것은 유지되고, 파일만 마운트 된다.

```shell
$ docker exec -it 664 bash
root@664e1253a597:/usr/local/apache2# ls htdocs/
hello.html  index.html
```

디렉토리를 마운트하면 디렉토리 전체가 마운트 되기 때문에 기존의 파일이 가려진다.

기존의 파일들이 있지만 접근불가(안보이는) 것으로, 마운트를 해제하면 다시 접근할 수 있다.

<br>그러나 **파일을 마운트하면 특정 파일만 마운트되기 때문에 기존에 존재하던 파일이 가려지지 않는다.**

따라서 기존에 어떤 디렉토리에 index.html 파일이 있고 추가적으로 다른 파일을 마운팅 시키고 싶다면 파일명을 지정해서 마운팅할 수 있다.

실제로 `file mounting`은 설정 파일을 제공할 때 많이 사용한다.

파일만을 추가하는 것이 목적이라면 파일 마운팅 방식을 사용해야한다.

참고로 볼륨 방식은 파일 마운팅이 불가능하다. 

<br>

<br>

## ✔️ 사용 용도

**바인드 방식**: 설정파일, 기타 파일을 제공하기 위한 목적

- 이미 존재하는 파일을 제공할 때 사용한다.

**볼륨 방식** : 데이터를 저장하기 위한 빈 디렉토리 제공하기 위한 목적

- 빈 볼륨을 제공할 때 사용한다. 












