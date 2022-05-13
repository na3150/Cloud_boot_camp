# [Docker] Docker Hub에 이미지 업로드하기

이미지는 웹 인터페이스에서 올리지 못하고, 반드시 명령어로만 올릴 수 있다. 

`Docker Hub` 에 이미지를 push하기 위해서는 `docker login` 명령을 통해 로그인 해야한다. (인증을 받아야한다.)

```shell
$ docker login
```

`Login Succeeded` 가 나와야 로그인에 성공한 것이다.

로그인하면 인증정보가 홈 디렉토리의 `./docker/config.json` 에 저장된다. 

<br>

이미지를 빌드할 때는 홈 디렉토리의 파일이 올라갈 수 있기 때문에 홈 디렉토리에서 하면 안되고, `root`에서 해도 안된다.

로컬에 있는 이미지를 아무거나 `docker push` 해보자

```shell
$ docker push pyhello:v1
The push refers to repository [docker.io/library/pyhello]
98bd83fe59fc: Preparing
bdfe286695e3: Preparing
240b01a8ef06: Preparing
4bc966bb1030: Preparing
99382be4915c: Preparing
ca58f1c44290: Waiting
957a6eed8d1f: Waiting
85fe00380881: Waiting
5d253e59e523: Waiting
b9fd5db9c9a6: Waiting
denied: requested access to the resource is denied
```

이미지는 올라가지 않는다. (denied)

이미지를 `push`할 때는 이미지의 이름을`[/docker계정/image:tag]` 형식에 맞춰서 만들어줘야한다. 

<br>

**기존 이미지에 원하는 이름 붙이기**

이미지가 바뀌는 것이 아니라 원래 이미지에 태그가 더 붙게 되는 것이다.

이미지의 태그는 붙여도되고 안붙여도 괜찮은데, 안붙이면 자동으로 `latest` 태그가 붙게된다. 

```shell
$ docker tag [기존이미지명]:[태그명] [도커계정명]/[새로운이미지명]:[태그명]
```

<br>

예시

```shell
$ docker tag pyhello:v1 [Account]/pyhello:v1
```

```shell
$ docker image ls | grep pyhello
pyhello             v1-alpine         7d2cd787a913   26 hours ago     47.5MB
pyhello             v1-slim           f156633ac250   26 hours ago     118MB
pyhello             v1                3bc5e43f16b9   26 hours ago     889MB
[Account]/pyhello   v1                3bc5e43f16b9   26 hours ago     889MB
```

`pyhello   ` 와`[Account]/pyhello`의 이미지 아이디가 같으므로 동일한 이미지이고, 태그만 더 붙인 것이다.

이제 다시 이미지를 push 해보자

```shell
$ docker push [Account]/pyhello:v1
```

이미지를 올리면 default가 `Public`으로 올란간다.

`Public`은 아무나 `pull`할 수 있고, `Public Repository`는 무제한이다.

`Private`은 `pull`도 `push`도 인증받은 사용자만 가능하다.

`Private`은 무료는 1개만 가능하고, 이미지의 `settings`에서 `Visibility Settings`를 통해 `Private`으로 변경시킬 수 있다.

<br>

![image-20220512215910931](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220512215910931.png)

이미지가 잘 올라간 것을 확인할 수 있다.

<br>

<br>