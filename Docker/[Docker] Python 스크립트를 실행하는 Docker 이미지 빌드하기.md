# [Docker] Python 스크립트를 실행하는 Docker 이미지 빌드하기

<br>

### 📌Index

- [python:3.9-buster 이미지 사용하기](#python:3.9-buster-이미지-사용하기)
- [python:3.9-slim-buster 이미지 사용하기](#python:3.9-slim-buster-이미지-사용하기)
- [python:3.9-alpine 이미지 사용하기](#python:3.9-alpine-이미지-사용하기)

<br>

<br>

먼저 아래의 3가지 **python 이미지를 pulling** 하자 : `Debian` + `Python3`

-  `python:3.9-buster` : 대부분의 필요한 패키지가 설치된 것
-  `python:3.9-slim-buster` : 표준 라이브러리를 제외하고 전부 제외된 것
- `python:3.9-alpine` : [BusyBox](https://busybox.net/) Linux + `apk ` 패키지 관리자

```shell
$ docker image ls | grep python                       
python       3.9-buster        2081325398fc   2 weeks ago     889MB
python       3.9-slim-buster   975c845dddf2   2 weeks ago     118MB
python       3.9-alpine        9f14ea10b146   3 weeks ago     475MB
```

<br>

<br>

## python:3.9-buster 이미지 사용하기

`python/hello-world/hello.py` 파일을 생성하자

```shell
#!/usr/bin/python3
print("Hello Python")
```

`hello.py` 에게 실행 권한(x)을 부여하고 실행을 확인해보자

```shell
$ chmod +x hello.py      
$ ./hello.py 
Hello Python
```

이미지를 빌드하기 위한 `Dockerfile`을 작성하자

`/python/hello-world/hello.py`

```shell
FROM python:3.9-buster
WORKDIR /root
ADD hello.py .
CMD ["python3", "hello.py"]
```

`Dockerfile`이 존재하는 디렉토리 `/python/hello-world`에서 이미지를 빌드해보자

```shell
$ docker build -t pyhello:v1 .    
Sending build context to Docker daemon  3.072kB
Step 1/4 : FROM python:3.9-buster
 ---> 2081325398fc
Step 2/4 : WORKDIR /root
 ---> Running in bfc9e7cff64b
Removing intermediate container bfc9e7cff64b
 ---> 82433aaaa0be
Step 3/4 : ADD hello.py .
 ---> 423004448fea
Step 4/4 : CMD ["python3", "hello.py"]
 ---> Running in c884d1681945
Removing intermediate container c884d1681945
 ---> 3bc5e43f16b9
Successfully built 3bc5e43f16b9
Successfully tagged pyhello:v1
```

생성된 이미지 `pyhello:v1` 으로 컨테이너를 실행해보자

- 표준 출력만 있기 때문에 별다른 옵션없이 `docker run`만 하면 된다.
- 정상적으로 `Hello Python`이 출력되는 것을 확인할 수 있다.

```shell
$ docker run pyhello:v1         
Hello Python
```

<br>
<br>

## python:3.9-slim-buster 이미지 사용하기

앞서 진행한 실습에 이어서 동일한 디렉토리 `/python/hello-world`에 `Dockerfile`을 생성하자.

`Dockerfile-slim`

```shell
FROM python:3.9-slim-buster
WORKDIR /root
ADD hello.py .
CMD ["python3", "hello.py"]
```

**`Dockerfile`의 이름이 `Dockerfile`이 아닌 경우 `-f` 옵션을 이용하여 파일을 지정할 수 있다**

`-f` 옵션으로 `Dockerfile` 을 지정하여 이미지를 빌드해보자

```shell
$ docker build -f Dockerfile-slim -t pyhello:v1-slim . 
```

생성된 이미지 `pyhello:v1-slim` 으로 컨테이너를  실행해보자

`Hello Python` 문구가 정상적으로 출력되는 것을 확인할 수 있다. 

```shell
$ docker run pyhello:v1-slim
Hello Python
```

<br>
<br>

## python:3.9-alpine 이미지 사용하기

앞서 진행한 실습에 이어서 동일한 디렉토리 `/python/hello-world`에 `Dockerfile`을 생성하자.

`Dockerfile-alpine`

```shell
FROM python:3.9-alpine
WORKDIR /root
ADD hello.py .
CMD ["python3", "hello.py"]
```

`-f` 옵션으로 `Dockerfile` 을 지정하여 이미지를 빌드해보자

```shell
$ docker build -f Dockerfile-alpine -t pyhello:v1-alpine . 
```

생성된 이미지 `pyhello:v1-alpine` 으로 컨테이너를  실행해보자

`Hello Python` 문구가 정상적으로 출력되는 것을 확인할 수 있다. 

```shell
$ docker run pyhello:v1-alpine
Hello Python
```

<br>

<br>