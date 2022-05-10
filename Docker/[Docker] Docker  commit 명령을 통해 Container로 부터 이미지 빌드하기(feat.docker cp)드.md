# [Docker] Docker : commit 명령을 통해 Container로 이미지 빌드하기(fead. docker cp)

<br>

### 📌Index

- [docker diff](#docker-diff)
-  [docker commit](#docker-commit)
-  [docker cp](#docker-cp)

<br>

<br>

## docker diff

**기준 이미지와 지정한 컨테이너와의 차이**를 확인할 수 있는 명령어이다.

```
docker diff <CONTAINER>
```

이때, 출력되는 값은 변경된 내용이 아닌 **변경된 파일의 경로**이다.

<br>

예시: `httpd` 이미지에서 a.gif 파일을 삭제 후 `docker diff` 명령어로 확인해보자

```shell
$ docker run -d httpd         
df72a404057ebfa139809094e5aa3991793ec913b63d7ef6d04a0fc0e95a1143
$ docker exec -it df bash     
root@df72a404057e:/usr/local/apache2# rm /usr/local/apache2/icons/a.gif
root@df72a404057e:/usr/local/apache2# exit
exit
```

```shell
$ docker diff df         
C /root
A /root/.bash_history
C /usr
C /usr/local
C /usr/local/apache2
C /usr/local/apache2/icons
D /usr/local/apache2/icons/a.gif #확인
C /usr/local/apache2/logs
A /usr/local/apache2/logs/httpd.pid
```

<br>

<br>

## docker commit

**`Container`를 이미지로 생성**할 때 사용하는 명령어로, 태그를 지정하지 않으면 `latest` 태그가 자동으로 붙게된다.

```
docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]
```

<br>

#### CMD 변경하기

`-c` 옵션을 사용하여, 이미지의 CMD(command)를 변경할 수 있다.

```
docker commit -c "CMD XXX" CONTAINER [REPOSITORY[:TAG]]
```

<br>

예시 : `centos:7` 이미지의 CMD를 변경해보자

이때, 확인을 위해 `index.html` 파일을 내용을`hello centos`로 설정해주자

```shell
$ docker run -itd centos:7
$ docker ps
$ docker exec -it 0c bash
[root@0c485eb1ed9c /]# yum -y install httpd
[root@0c485eb1ed9c /]# cd /var/www/html
[root@0c485eb1ed9c html]# ls
index.html
[root@0c485eb1ed9c html]# cat index.html 
<h1>hello centos</h1>
```

**컨테이너에는 `systemd`가 없기 때문에 명령어로 `httpd` 을 실행**(시작)해야한다.

`systemctl start httpd` == `/usr/sbin/httpd -DFOREGROUND`

해당 내용은 ` /usr/lib/systemd/system/httpd.service`에서 확인할 수 있다.

📋` /usr/lib/systemd/system/httpd.service`

```shell
[Service]
Type=notify
EnvironmentFile=/etc/sysconfig/httpd
ExecStart=/usr/sbin/httpd $OPTIONS -DFOREGROUND
ExecReload=/usr/sbin/httpd $OPTIONS -k graceful
ExecStop=/bin/kill -WINCH ${MAINPID}
```

```shell
$ docker commit -c "CMD /usr/sbin/httpd -DFOREGROUND" 0c myapache:v1
sha256:dfd93aa30e80d32fb8c82b005fab7e6a79a50850ca7e8cc0e4d114b5fd2ca105
```

`docker images`명령어를 통해 `myapache:v1` 이미지가 생성된 것을 확인할 수 있다.

```shell
$ docker images                                                     
REPOSITORY   TAG        IMAGE ID       CREATED             SIZE
myapache     v1         dfd93aa30e80   5 seconds ago       402MB
```

접속확인을 위해 80번 포트로 포트포워딩 해주자

```shell
$ docker run -d -p 80:80 myapache:v1
26f3338a18d6803d9a7cb76421626fa8df29567fa9f44f8fad01513d5da65120
$ docker ps                         
CONTAINER ID   IMAGE         COMMAND                  CREATED          STATUS          PORTS                               NAMES
26f3338a18d6   myapache:v1   "/bin/sh -c '/usr/sb…"   4 seconds ago    Up 2 seconds    0.0.0.0:80->80/tcp, :::80->80/tcp   elastic_perlman
0c485eb1ed9c   centos:7      "/bin/bash"              14 minutes ago   Up 14 minutes                                       competent_sinoussi
```

접속 확인!

![hello centos](https://raw.githubusercontent.com/na3150/typora-img/main/img/hello%20centos.PNG)

`docker inspect`로 cmd 확인해보기

```shell
docker inspect 26 --format '{{ .Config.Cmd }}'
[/bin/sh -c /usr/sbin/httpd -DFOREGROUND]
```

참고) `bin/sh -c` 가 붙어있는 이유는 뭘까❔ shell이 명령어를 실행한다는 의미이다. 

<br>

#### ExposedPort 변경

`-c` 옵션을 사용하여 ExposedPort를 변경 및 설정할 수 있다.

```
docker commit -c "EXPOSE PORT/PROTOCOL" CONTAINER [REPOSITORY[:TAG]]
```

ExposedPort는 정보일 뿐이고, 실제 서비스 및 작동 여부와는 관계가 없지만 사용자에게 제공하는 정보이므로, 설정해두는 것이 좋다

<br>
예시 : 포트가 설정되어있지 않은 이미지에 ExposedPort 설정하기

`docker inspect` 명령어를 통해 살펴보면, `ExposedPorts`가 설정되어있지 않은 것을 확인할 수 있다.

```shell
$ docker inspect 23 --format '{{ .Config.ExposedPorts }}'
map[]
```

포트 변경후 확인하기

```shell
$ docker commit -c  "EXPOSE 80/tcp" e0 myapache2:v1
```

```shell
$ docker inspect [myapache2:v1 IMAGE ID] --format '{{ .Config.ExposedPorts }}'
map[80/tcp:{}]
```

<br>

<br>

## docker cp

**HOST와 컨테이너간의 파일 이동(복사)**을 위해 사용하는 명령어로, `Container` <->`Docker Host` 사이의 **양방향 모두를 지원**한다.

`Container` -->`Docker Host` 

```shell
$ docker cp CONTAINER:SRC_PATH DEST_PATH
```

`Docker Host` --> `Container`

```shell
$ docker cp SRC_PATH CONTAINER:DEST_PATH
```

<br>

예시 : `/usr/local/apache2/conf/httpd.conf` 파일 수정해보기

앞서 `docker commit` 명령을 통한 `ExposedPort`의 변경은 실제 서비스와는 관계가 없다는 설명을 했었다.

실제 연결 포트는 `/usr/local/apache2/conf/httpd.conf` 파일에서 `Listen` 뒤의 포트이다.

먼저 `httpd`를 실행시킨 뒤, 컨테이너 확인 후 `/usr/local/apache2/conf/httpd.conf` 파일을 호스트로 복사해보자

```shell
$ docker run -d httpd 
2cf3ef766218c13b203a7675f3237fc33298a90eb4809afb241f87f3bd65f0a1
$ docker ps           
CONTAINER ID   IMAGE         COMMAND                  CREATED             STATUS             PORTS                               NAMES
2cf3ef766218   httpd         "httpd-foreground"       2 seconds ago       Up 2 seconds       80/tcp                              heuristic_joliot
$ docker cp 2c:/usr/local/apache2/conf/httpd.conf ./httpd.conf
```

`vi`에디터를 통해 파일을 수정하고, 다시 컨테이너로 복사하자

이때 `docker diff` 명령어를 통해 확인 가능하다

```shell
$ docker cp ./httpd.conf 2c:/usr/local/apache2/conf/httpd.conf 
$ docker diff 2c   
C /usr
C /usr/local
C /usr/local/apache2
C /usr/local/apache2/logs
A /usr/local/apache2/logs/httpd.pid
C /usr/local/apache2/conf
C /usr/local/apache2/conf/httpd.conf
```

`docker commit` 후 `docker images`로 확인

```shell
$ docker commit 2c myhttpd:p8080
sha256:b6b592b54ebb7c8d3cbeb38af4fe5629ed74fc856437cd51bd2a9baed3754436
$ docker images                                          
REPOSITORY   TAG        IMAGE ID       CREATED             SIZE
myhttpd      p8080      b6b592b54ebb   4 seconds ago       144MB
```

80 포트로 잘 설정되었는지 확인을 위해 포트 포워딩 후 접속해보자

```shell
$ docker run -d -p 80:8080 myhttpd:p8080 
```

<br>

![8080 확인](https://raw.githubusercontent.com/na3150/typora-img/main/img/8080%20%ED%99%95%EC%9D%B8.PNG)





> 
