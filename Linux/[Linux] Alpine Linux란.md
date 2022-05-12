# [Linux] Alpine Linux란?

[Alpine Linux](https://www.alpinelinux.org/) : [BusyBox](https://busybox.net/)  + APK(패키지 관리자)

- `BusyBox`는 리눅스 커널와 핵심 바이너리와 라이브러리만 포함
-  `yum`과 같은 패키지 관리자가 없어서, 소스코드 실행 파일을 직접 빌드해야함
- 일반적으로 임베디드 장치에 사용하기 위해 만듬

<b>

`BusyBox` 의 불편함을 해결하기 위해 만든 것이 바로 `Alpine Linux`이다. 

단, `Alpine Linux`는 bash shell이 없고, 기본적으로 본 shell만 가지고 있다.

```shell
docker run -it alpine:3 bash              
docker: Error response from daemon: failed to create shim: OCI runtime create failed: container_linux.go:380: starting container process caused: exec: "bash": executable file not found in $PATH: unknown.
ERRO[0000] error waiting for container: context canceled 
```

기존의 리눅스는 `Glibc` C 라이브러리를 사용하나, `Alpine Linux`은 `musl` C 라이브러리를 사용한다. 

 `musl` 라이브러리는  `Glibc` 에 비해 용량이 매우 작고, 따라서 `Alpine Linux`는 **아주 작은 사이즈가 필요한 경우에 사용**한다.

다만, `Glibc`와  `musl` 은 완전히 호환되지는 않기 때문에 약간의 오류가 발생할 수 있다.

<br>

참고) `Debian`이 성능이 뛰어나며, 설치되어있는 패키지가 많고, 사이즈도 작으며, 라이선스가 자유롭다운 등의 이유로 많이 사용된다.

<br>

### ✔️ 사용 방법

패키지 인덱스

```
apk update
```

패키지 검색

```
apk search <PKG>
```

패키지 추가

```
apk add <PKG>
```

패키지 제거

```
apk del <PKG>
```

