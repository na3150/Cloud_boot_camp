# [Docker] Docker에 Go 배포하기

<br>

### 📌Index

- [환경 구성](#환경-구성)
- [Go 기초 실습](#go-기초-실습)
- [Web Application 만들기](#web-application-만들기)
- [Go App으로 Docker image 만들기](#go-app으로-docker-image-만들기)
- [Docker에 Gin 배포하기](#docker에-gin-배포하기)

<br>

[Go](https://go.dev/) 란 구글(google)에서 개발한 언어로, Go는 간결하고 신뢰성 있으며 효율적인 소프트웨어를 손쉽게 만들기 위한 

오픈소스 프로그래밍 언어이다. 

`GoLang`은 간결한 의존성 해석 알고리즘을 통해서 **다른 컴파일 언어에 비해 빌드가 빠르다**는 장점이 있다.

<br>

<br>

## 환경 구성

먼저 실습을 진행할 환경을 구성하자

<br>

**디렉토리 만들기**

```shell
$ mkdir golang
$ mkdir hello
$ cd /golang/hello
```

**golang 설치하기**

```shell
$ sudo apt install golang
```

**go module 만들기**

`Golang`에서 `module`은 `Django`에서의 `App`과 비슷한 개념이다.

```shell
$ go mod init hello
```

위의 명령을 실행하면 `go.mod` 파일이 생성되는데, 이렇게 설정하면 나중에 `go build` , `go run` 할 때 

파일을 따로 지정하지 않아도 된다.

`go build .` 와 같이 명령을 실행해도 `go.mod` 파일 정보를 읽어서 빌드하게 된다.

```shell
cat go.mod 
module hello

go 1.13
```

<br>

<br>

## Go 기초 실습

`GoLang`은 컴파일 언어이지만, C와 달리 실행 파일을 만들지 않고도 바로 실행할 수 있다.

`hello.go`

```shell
package main

import "fmt"

func main() {
        fmt.Println("hello go world")
}
```

`hello.go`는 `hello go wolrd`를 출력하는 간단한 코드이다.

`go run` 하면 실행파일 없이 바로 실행되는 것을 확인할 수 있다.

```shell
$ go run hello.go              
hello go world
```

빌드를 하지 않는 것처럼 보일 수 있지만, 실제로는 이미 빠르게 빌드(컴파일)를 해서 실행한 것이다.

따라서 실행파일을 만들지 않고 바로 `go run`하는 것은 일반적으로 테스트 시에 많이 사용하는 방식이다.

또한 앞서 module `go.mod` 를 생성했기 때문에 `hello.go` 파일을 지정하지 않고 `go run .` 으로 실행해도 정상적으로 진행된다.

```shell
$ go run .
```

<br>

그렇다면 이번에는 실행 파일을 만들어서 빌드 해보자!

`-o` : output

```shell
$ go build -o hello hello.go
```

참고로, 아래에서 확인할 수 있듯이 `GoLang`은 기본적으로 `static build` 된다.  

```shell
$ file hello    
hello: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), statically linked, Go BuildID=Xew94lip5of83edrsxSa/8XB7RY7GXYkuErfE3FlL/7s8zg7p_A_RGMeeC4DvB/bSosaz9uK6MWnPf89h5y, not stripped
```

`hello` 파일을 실행하면 정상적으로 출력되는 것을 확인할 수 있다.

```shell
$ ./hello                 
hello go world
```

<br>

이제 **`go` 파일로 스크립트가 출력되는 이미지를 빌드**해보자

먼저 다음과 같이 이미지를 빌드하기 위한 `Dockerfile`을 작성한다

`Dockerfile`

```shell
FROM golang:1.18-buster AS gobuilder
COPY hello.go /app/hello.go
WORKDIR /app
RUN go build -o hello hello.go

FROM scratch
COPY --from=gobuilder /app/hello /
CMD ["/hello"]
```

`docker build`를 통해 `gohello` 이미지를 빌드한다.

```shell
docker build -t gohello .
```

그리고 해당 이미지를 `docker run` 하면 `hello go world` 가 잘 출력되는 것을 확인할 수 있다

```shell
$ docker run gohello               
hello go world
```

<br>

<br>

## Web Application 만들기

[Writing Web Applications](https://go.dev/doc/articles/wiki/)을 따라 `HTTP Web`을 만들어보자

먼저 실습을 진행할 환경(디렉토리)를 만든다.

```shell
$ mkdir goweb
$ cd goweb
```

그 다음 `http` 모듈을 만들자

```shell
$ go mod init http
```

<br>

그리고 다음과 같이 `goweb.go` 파일을 작성하자.

`goweb.go`

```shell
package main

import (
    "fmt"
    "log"
    "net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
    fmt.Fprintf(w, "Hi there, I love %s!", r.URL.Path[1:])
}

func main() {
    http.HandleFunc("/", handler)
    log.Fatal(http.ListenAndServe(":8080", nil))
}
```

파일 내용 설명

- `import` 는 패키지를 추가하는 부분으로,  `net/http ` 패키지는 웹앱을 만들 때 사용하는 패키지
- ` http.HandlFunc("/", handler)` : `/` 에 접속하면 `handler` 함수를 실행하라는 의미
- `fmt.Fprintf(w, "Hi there, I love %s!", r.URL.Path[1:])` : `/`뒤의 첫번째 요소(변수)를 `%s` 에 넣어서 출력

참고) `go fmt` : `terraform fmt` 처럼 파일들을 포맷팅하는 방법

<br>

`go run` 명령을 실행하여 테스트해보자

```shel
$ go run . 
```

설정한 포트로 접속했을 때 잘 실행되는 것을 확인할 수 있다

![image-20220512180427889](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220512180427889.png)

<br>

<br>

## Go App으로 Docker image 만들기

앞선 실습에서 작성한 `goweb.go` 으로 docker 이미지를 빌드해볼 예정이다.

<br>

먼저 이미지를 만들기 위한 `Dockerfile`을 아래와 같이 작성한다. 

`Dockerfile`

```shell
FROM golang:1.18-buster AS gobuilder
ENV CGO_ENABLED 0
COPY . /app
WORKDIR /app
RUN go build .
FROM scratch
COPY --from=gobuilder /app/goweb /
CMD ["/goweb"]
```

다음으로 이미지를 build하고 실행해보자

```shell
$ docker build -t goweb .
$ docker run -d -p 80:8080 goweb
```

```shell
$ docker ps                     
CONTAINER ID   IMAGE     COMMAND    CREATED          STATUS          PORTS                                   NAMES
6fd13bf97af3   gogin     "/gogin"   28 seconds ago   Up 27 seconds   0.0.0.0:80->8080/tcp, :::80->8080/tcp   dreamy_blackwell
```

<br>

**접속 확인**

![image-20220512122809322](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220512122809322.png)

#### multistage-build 해보기

`multistage-build`는 하나의 도커파일에 2개의 FROM이 있는 형식이다.

<br>

먼저 `.dockerignorefile`을 작성하자 

`.dockerignorefile`이 무엇인지 모른다면? 👉 [.dockerignorefile 설명](https://nayoungs.tistory.com/168#%E-%-C%--%EF%B-%-F%--%C-%A--dockerignore%--file%EC%-D%B-%EB%-E%--%-F)

`.dockeerignorefile`

```shell
goweb
.dockerignore
Dockerfile
```

다음으로 multistage-build 형식의 이미지 빌드를 위한  `Dockerfile`을 작성하자

`Dockerfile`

```shell
FROM golang:1.18-buster AS gobuilder
ENV CGO_ENABLED 0 #CGO Disable
COPY . /app
WORKDIR /app
RUN go build .

FROM scratch
COPY --from=gobuilder /app/goweb /
CMD ["/goweb"]
```

- `ENV CGO_ENABLED 0` : CGO Disable을 의미하는 것으로,  Go 라이브러리 내부는 C 구조체를 참조하는 것이 있는데, `Scratch` 이미지는 아무것도 없기 때문에 C 관련된 기능을 꺼줘야 정상적으로 작동함

<br>

이제 이미지를 빌드하고 실행해보자

```shell
$ docker build -t goweb .    
$ docker run -d -p 80:8080 goweb
d3d822b3ac86908913fcc691ce2b093460f65606a822be18c197c611b02409cb
$ docker ps                     
CONTAINER ID   IMAGE     COMMAND    CREATED         STATUS         PORTS                                   NAMES
d3d822b3ac86   goweb     "/goweb"   3 seconds ago   Up 3 seconds   0.0.0.0:80->8080/tcp, :::80->8080/tcp   agitated_chatterjee
```

정상적으로 실행되고 있는 것을 확인할 수 있고, 접속을 시도해보자

확인완료!

<br>

![image-20220512183205205](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220512183205205.png)

<br>

<br>

## Docker에 Gin 배포하기

[Gin](https://github.com/gin-gonic/gin) 은 GoLang에서 가장 많이 사용하는 웹 프레임워크이다. 

**디렉토리 만들기**

```shell
$ mkdir ~/golang/gogin
$ cd ~/golang/gogin
```

```shell
$ go mod init gogin
```

다음으로 아래와 같이 `go` 파일을 작성한다.

참고) `golang`은 공식적인 패키지 서버가 없고 `github` 등 인터넷에서 가져오게된다.

`gogin.go`

```
package main

import "github.com/gin-gonic/gin"

func main() {
	r := gin.Default()
	r.GET("/ping", func(c *gin.Context) {
		c.JSON(200, gin.H{
			"message": "pong",
		})
	})
	r.Run() // listen and serve on 0.0.0.0:8080 (for windows "localhost:8080")
}
```

패지키 목록을 파일로 만들자. `pip3 freeze`와 동일한 명령어이다.

```shell
$ go mod tidy
```

그러면 `go.sum` 파일이 생성되고, 이 파일은 `requirements.txt` 파일과 비슷하다고 보면 된다. 

여기에는 패키지 목록이 저장되어있다.

```shell
$ cat go.sum
```

다음으로 이미지 빌드를 위한 `Dockerfile`을 만들자

`Dockerfile`

```
FROM golang:1.18-buster AS gobuilder
ENV CGO_ENABLED 0
COPY . /app
WORKDIR /app
RUN go build -o gogin .

FROM scratch
COPY --from=gobuilder /app/gogin /
CMD ["/gogin"]
EXPOSE 8080
```

이제 `gogin` 이미지를 빌드하자.

`build`를 할 때  `go.sum` 파일이 있으면 알아서 읽어오기 때문에 `pip install`과 같은 별도의 작업이 필요 없다.

아래와 같이 실행하면 **자동으로 `go.sum`에서 외부 패키지 목록을 읽어와 다운**받는다.

```shell
$ docker build -t gogin .
```

이미지 `gogin`으로 컨테이너를 실행하자

```shell
$ docker run -d -p 80:8080 gogin
```

**접속 확인**

```shell
$ curl 192.168.100.100/ping
```



![image-20220512123814418](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220512123814418.png)



<br>

<br>