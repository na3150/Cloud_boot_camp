# [Docker] Docker 이미지 레이어(Layer) 

<br>

Docker image가 레이어(Layer)를 가지는 이유를 먼저 설명하자면, 바로 **데이터 저장의 효율성을 가지기 위함이다**

<br>

`docker run <image>` 를 통해 이미지로 컨테이너를 생성할 경우 **기존의 이미지 레이어들 위에 `conatiner layer` 가 생성된다.**

즉, **commit 할 때마다 새로운 내용을 레이어에 쌓아가는 것**이다.

**기존 이미지의 레이어는 `Read-Only`(변경 불가)** 이고, 기존 레이어 위에 **새로 생성된 레이어는 `Read-Write`(변경 가능)** 이며,

기존 이미지 레이어는 삭제되지 않지만 컨테이너 레이어(생성된 layer)는 해당 컨테이너가 종료될 경우 같이 소멸된다

<br>

아래 그림에서 볼 수 있듯이, 도커 엔진이 이미지에서 컨테이너를 생성할 때 **읽기 전용 레이어 위에 쓰기 가능한 레이어를 추가**하게 된다. 

![image-20220510213908418](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220510213908418.png)

[image 출처](https://blog.djjproject.com/782)

<br>

만약 기존 레이어를 변경하고 `commit` 한다고 해도, 실제로는 변하지 않는다(Read-Only)

예를 들어 기존 레이어에서 어떤 것을 삭제했을 때, 실제로는 지워지지 않고 새로운 레이어에 해당 사항이 없다고만 "표시"한다.

즉, 기존 레이어의 삭제 행위는 의미가 없기 때문에 용량적으로, 메모리적으로 매우 비효율적이라고 할 수 있다.

<br>

#### 이미지 레이어 확인하기

**`docker image inspect`** 명령으로 확인하기

```shell
$ docker image inspect ubuntu --format '{{ .RootFS }}' 
```

<br>

**`docker save`** 명령어로 파일 직접 확인하기

- `docker save` 명령어를 통해 image를 아카이브 : `ubuntu:focal-v2`

```shell
$ docker save ubuntu:focal-v2 -o focal-v2.tar
$ mkdir focal-v2            
```

- `tar` 파일 아카이브 해제
- **디렉토리의 개수가 레이어(layer)의 개수**이다 (여기서는 3개)

```shell
$ tar xf focal-v2.tar -C focal-v2
$ cd focal-v2 
$ ls
2d8863025a8f619824d68c90bd2c7fdd58c6df8a3b2f0e1d2d0e50b2e0112e39
785ca7304d50e7b5495f97a289a2560fce26579d38dbbb07fdc8641d16fe4084
7fcdf84fc510378f71215b383022fe34e0b7156341b377a8b968a2bdb29de00b.json
c3e2a59068922ea6af60721e223e9ca0593af19d61751227162eed69b5f9a5e0
```

- 이때 `json` 파일은 `docker inspect` 명령 시 확인할 수 있는 `Config` 정보와 같다.

```shell
$ cat 7fcdf84fc510378f71215b383022fe34e0b7156341b377a8b968a2bdb29de00b.json 
{"architecture":"amd64","config":{"Hostname":"3306aa427fbe","Domainname":"","User":"","AttachStdin":false,"AttachStdout":false,"AttachStderr":false,"Tty":true,"OpenStdin":true,"StdinOnce":false,"Env":["PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"],"Cmd":["bash"],"Image":"ubuntu:focal-v1","Volumes":null,"WorkingDir":"","Entrypoint":null,"OnBuild":null,"Labels":{}},"container":"3306aa427fbe4ccdfc56306aa7fd79f1c2c954b0e4a495b475cff93fce781af9","container_config":{"Hostname":"3306aa427fbe","Domainname":"","User":"","AttachStdin":false,"AttachStdout":false,"AttachStderr":false,"Tty":true,"OpenStdin":true,"StdinOnce":false,"Env":["PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"],"Cmd":["bash"],"Image":"ubuntu:focal-v1","Volumes":null,"WorkingDir":"","Entrypoint":null,"OnBuild":null,"Labels":{}},"created":"2022-05-10T13:00:55.885615981Z","docker_version":"20.10.14","history":[{"created":"2022-04-29T23:20:59.079732432Z","created_by":"/bin/sh -c #(nop) ADD file:7009ad0ee0bbe5ed7f381792e07347e260e6896aeee0d80597808065120fa96b in / "},{"created":"2022-04-29T23:20:59.430653302Z","created_by":"/bin/sh -c #(nop)  CMD [\"bash\"]","empty_layer":true},{"created":"2022-05-10T13:00:24.934947705Z","created_by":"bash"},{"created":"2022-05-10T13:00:55.885615981Z","created_by":"bash"}],"os":"linux","rootfs":{"type":"layers","diff_ids":["sha256:bf8cedc62fb3ef98ad0dff2be56ca451dd3ea69abd0031ad3e0fe5d9f9e4dfff","sha256:df59eb48198017080d0381d87979984a85d0f51d643e082788a8969891512d16","sha256:346880cf0691ec76b021be82d47fb36e6023a40d49a380001af4d213819a5288"]}}%           
```

<br>

Docker Image가 layer를 사용하는 이유(데이터 저장의 효율성)를 이해하기 위해 `Layered Filesystem`을 확인해보자

**Layered Filesystem** 이란 여러개의 블록장치를 하나의 장치로 결합하는 것으로, 대표적인 예시로 현재 docker의 표준 파일 시스템인 `oveerlay2`가 있다.

<brr>

**`aufs`은`ufs`(Union File System)** 에서 파생된 것으로, 여기서 union은 **여러개의 레이어를 하나인 것처럼 결합**시켜주는 시스템이다.

Docker에서 초기에는 `aufs`파일 시스템을 사용했었으나,  `overlay2`로 변경하였다. 

**레이어를 하나로 합치지 않고 나누면,** 이미지 pulling을 할 때 동일한 레이어가 있는 경우 다시 다운 받을 필요가 없는데

즉, **중복된 레이어를 별도로 저장(다운)할 필요가 없기 때문**이다.

<br>

**레이어를 하나로 합치게 되면**, 이미 로컬에 존재하는 레이어여도, **이미지를 사용할 때마다 처음부터 다시 다운 받아야하기 때문에 용량의 효율성이 떨어지게된다.**

생각해볼점❕

- 레이어 자체의 용량 제한은 없기 때문에, 합칠지 나눌지는 전략적으로 선택해야한다

- 변경될 일이 없는 것은 합치는 것이 효율적일 수 있다
- 자주 바뀌는 것일 경우 분리시키는 것이 좋다 -> 그것 때문에 레이어 전체가 바뀌어야 되기 때문이다

<br>

<br>

## docker history

**`docker history`** 명령을 통해서 이미지 생성 로그를 확인할 수 있다.

```
docker history <IMAGE>
```

<br>

예시

```shell
$ docker history ubuntu:focal-v2 
IMAGE          CREATED          CREATED BY                                      SIZE      COMMENT
7fcdf84fc510   43 minutes ago   bash                                            8B        
171cf237b96e   43 minutes ago   bash                                            8B        
53df61775e88   10 days ago      /bin/sh -c #(nop)  CMD ["bash"]                 0B        
<missing>      10 days ago      /bin/sh -c #(nop) ADD file:7009ad0ee0bbe5ed7…   72.8MB 
```

<br>

<br>

[참조 사이트](https://eqfwcev123.github.io/2020/01/30/%EB%8F%84%EC%BB%A4/docker-image-layer/)
