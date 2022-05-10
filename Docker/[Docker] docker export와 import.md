# [Docker] docker export와 import

<br>

### 📌Index

- [Docker export](#docker-export)
- [Docker import](#docker-import)

<br>

<br>

## docker export

docker save와 유사 : save는 image를 tar archive로 만들기

**export는 container를 tar archive로 만들기**

```
docker export <CONTAINER> -o <TARFILE>
```

예시

```shell
$ docker export 3d -o httpd.tar
$ ls
centos7.tar  hello-world.tar  httpd.tar  zsh-completions
$ mkdir httpd      
$ tar xf httpd.tar
$ cd httpd      
```

<br>

<br>

## docker import

**tar 파일을 이미지로 가져오기**

**하나의 레이어로 가져옴** -> 멀티 레이어의 이미지, 컨테이너를 하나로 만들 때 자주 사용

```
docker import <TARFILE> <IMAGE>:<TAG>
```

<br>

예시

```shell
$ docker import httpd.tar a:v1                        
sha256:8461ff7329bcd0ce2e1940106ac7d40c978e6a73ab93f36e37cd991601350021
$ docker images                                       
REPOSITORY   TAG        IMAGE ID       CREATED             SIZE
a            v1         8461ff7329bc   4 seconds ago       141MB
```



