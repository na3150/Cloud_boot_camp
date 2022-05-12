# [Docker] Dockerfile의 caching 문제 방지하기

<br>

`Dockerfile`을 통해 도커 이미지를 빌드할 때, `Dockerfile`의 레이어(Layer)와 캐싱(caching) 문제로 

패키지 관련 이슈가 발생할 수 있다.

앞서 [이미지 레이어](https://nayoungs.tistory.com/159)에 대해서 설명할 때, 이미지 레이어 캐싱을 통해 얻을 수 있는 장점은 **데이터 저장의 효율성과 재사용에 의한 빌드 시간 단축**이라고 설명한 바 있다.

`Dockerfile`에 정의된 명령어와 이전 명령어들이 같다면 **동일한 레이어로 판단**하기 때문에 다시 다운로드 받지 않으며, 

**캐싱되어있는 부분을 가져온다.**

결과적으로 데이터 저장의 효율성과 빌드 시간 단축이라는 효과를 얻을 수 있는 것이다.

공식 홈페이지 문서의 [Dockerfile 작성 안내](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)에서도 다음과 같이 설명하고 있다.

```
A Docker image consists of read-only layers each of which represents a Dockerfile instruction. The layers are stacked and each one is a delta of the changes from the previous layer.
```

<br>

그러나 새로운 이미지 빌드 시, 파일이나 패키지가 변경되었음에도 **처음 캐싱된 레이어의 정보로 인해** 별도의 업데이트 없이 **이전의 것이 그대로 이미지에 포함되는 문제가 발생**한다.  

<br>

이해를 위해 아래 예시를 살펴보자.

`myubuntu/Dockerfile`

```shell
FROM ubuntu:focal
RUN apt update; DEBIAN_FRONTEND=noninteractive apt install tzdata
RUN ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
RUN apt install -y apache2
ADD index.html /var/www/html/index.html
EXPOSE 80/tcp
CMD ["/usr/sbin/apache2ctl", "-DFOREGROUND"]
```

위의 `Dockerfile`로 이미지를 빌드하고, 2달 뒤에 `apache2` 최신 버전을 받기 위해 다시 이미지를 빌드한다고 해보자.

그러나, 새로운 버전이 출시되고 2달 뒤에 다시 빌드를 해도 아무런 작업도 일어나지 않는다. 

새로운 패키지가 출시되면 새로운 패키지 목록이 있는 `index` 정보를 가져와야하는데, 

이는 `apt update` 명령을 실행할 때만 가져오게 된다.

그러나 이 과정이 **이미 캐싱이 되어있기 때문에 새로운 목록을 가져오지 않게되는 것**이다. (해당 라인을 아예 실행하지 않는다)

<br>

참고로, `apache2`를 설치할 때는 **버전을 명시**해주면 캐싱된 데이터로 `apt update`가 되지 않았을 때

새로운 패키지 목록이 없으므로, 설치가 정상적으로 이루어지지 않아 오류를 확인해 볼 수 있다.

<br>

이러한 캐싱으로 인한 패키지 문제를 대비(해결)할 수 있는 방법으로는 2가지를 생각해볼 수 있다.

#### 1. `ONBUILD`

[ONBUILD](https://docs.docker.com/engine/reference/builder/) `INSTRUCTION` 을 사용하여, **build할 때 마다 실행할 명령을 지정**하는 것이다.

```shell
ONBUILD RUN apt update
```

<br>

#### 2. `--no-cache` 옵션 사용

`docker build` 옵션에 `--no-cache`라는 옵션이 있다.

이 옵션을 사용하면 `docker build` 시 **캐시를 사용하지 않고 빌드**를 진행하게 된다.

다만, 모든 레이어에 캐시를 아예 사용하지 않기 때문에 시간이 오래 걸릴 수도 있다는 단점이 있다. 

<br>

build 시간을 줄이는 것이 목적이라면 `ONBUILD`를 사용하는 것이 효과적일 수도 있고, 

번거로움이 싫다면 `--no-cache` 옵션을 선택할 수 있다. 

<br>

<br>

<br>

<br>

[참고](https://code4human.tistory.com/147)