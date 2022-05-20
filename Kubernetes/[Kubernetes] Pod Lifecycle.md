# [Kubernetes] Pod Lifecycle

[pod-lifecycle](https://kubernetes.io/ko/docs/concepts/workloads/pods/pod-lifecycle/)

<br>

#### 파드의 상태

파드의 상태는 컨테이너의 상태를 반영한다.

쿠버네티스는 다양한 컨테이너 [상태](https://kubernetes.io/ko/docs/concepts/workloads/pods/pod-lifecycle/#컨테이너-상태)를 추적하고 파드를 다시 정상 상태로 만들기 위해 취할 조치를 결정하며,

파드의 `status` 필드는 `phase` 필드를 포함하는 [PodStatus](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.24/#podstatus-v1-core) 오브젝트로 정의된다.

`phase`에 가능한 값은 다음과 같다.

| 값          | 의미                                                         |
| :---------- | :----------------------------------------------------------- |
| `Pending`   | 파드가 쿠버네티스 클러스터에서 승인되었지만, 하나 이상의 컨테이너가 설정되지 않았고 실행할 준비가 되지 않았다. 여기에는 파드가 스케줄되기 이전까지의 시간 뿐만 아니라 네트워크를 통한 컨테이너 이미지 다운로드 시간도 포함된다. (이미지 사이즈가 크면 `pending` 상태가 조금 더 지속된다)                                                                                           - 스케쥴링되기 전, 이미지 받기 전, 컨테이너가 준비 되기 전 |
| `Running`   | 파드가 노드에 바인딩되었고, 모든 컨테이너가 생성되었다. 적어도 하나의 컨테이너가 아직 실행 중이거나, 시작 또는 재시작 중에 있다.                                                                                                                                                                                  - 컨테이너가 실행 중, 실행 전, 재시작 등 |
| `Succeeded` | 파드에 있는 모든 컨테이너들이 성공적으로 종료되었고, 재시작되지 않을 것이다.                                                                   - 정상종료 : `return code 0` |
| `Failed`    | 파드에 있는 모든 컨테이너가 종료되었고, 적어도 하나 이상의 컨테이너가 실패로 종료되었다. 즉, 해당 컨테이너는 `non-zero` 상태로 빠져나왔거나(exited) 시스템에 의해서 종료(terminated)되었다.                                                                 - 비정상 종료 : `return code !0` |
| `Unknown`   | 어떤 이유에 의해서 파드의 상태를 얻을 수 없다. 이 단계는 일반적으로 파드가 실행되어야 하는 노드와의 통신 오류로 인해 발생한다. 일반적으로 컨트롤 플레인이 워커노드에 접근할 수 없을 때 이 상태가 된다.                                                        - 노드의 통신 문제로 상태를 알 수 없음 |

<br>

**`Pending` 상태가 지속되는 경우**

- 만족하는(배칭할 수 있는) 노드가 없어(`insufficient node`) 스케쥴링을 할 수 없는 상태가 되는 경우
- 이미지를 잘못 지정하여 이미지를 받지 못하는 경우
- 프라이빗 레지스트리에서 인증을 받을 수 없는 경우
- 컨테이너가 실행할 준비가 되지 않은 경우
- 볼륨에 문제가 있는 경우
- ..

<br>

**참고)**

파드가 삭제될 때, 일부 kubectl 커맨드에서 `Terminating` 이 표시된다. 

이 `Terminating` 상태는 파드의 단계(status)에 해당하지 않으며, `SIGTERM 15`를 전송시키게 된다.

파드에는 그레이스풀하게(gracefully) 종료되도록 기간이 부여되며, 그 기본값은 30초이다.

30초 이상 응답이 없으면 `SIGTERM 9`를 보내 강제 종료된다.

[강제로 파드를 종료](https://kubernetes.io/ko/docs/concepts/workloads/pods/pod-lifecycle/#pod-termination-forced)하려면 `--force` 플래그를 설정하면 된다.

<br>

#### 컨테이너의 상태

`kubectl describe` 명령을 통해 컨테이너의 이전 상태(Last State)와 현재 상태(State)를 확인할 수 있다.

| 값         | 의미                                                         |
| ---------- | ------------------------------------------------------------ |
| Waiting    | 만약 컨테이너가 `Running` 또는 `Terminated` 상태가 아니면, `Waiting` 상태이다.<br> `Waiting` 상태의 컨테이너는 시작을 완료하는 데 필요한 작업(예를 들어, 컨테이너 이미지 레지스트리에서 컨테이너 이미지 가져오거나, [시크릿(Secret)](https://kubernetes.io/ko/docs/concepts/configuration/secret/) 데이터를 적용하는 작업(볼륨을 연결하는 작업))을 계속 실행하고 있는 중이다. `kubectl` 을 사용하여 컨테이너가 `Waiting` 인 파드를 쿼리하면, 컨테이너가 해당 상태에 있는 이유를 요약하는 Reason 필드도 표시된다. <br>- 이미지를 받기 전, 볼륨 연결 되기 전 |
| Running    | `Running` 상태는 컨테이너가 문제없이 실행되고 있음을 나타낸다. `postStart` 훅이 구성되어 있었다면, 이미 실행되고 완료되었다. `kubectl` 을 사용하여 컨테이너가 `Running` 인 파드를 쿼리하면, 컨테이너가 `Running` 상태에 진입한 시기에 대한 정보도 볼 수 있다.   <br> `postStart` : start한 후에 하는 작업    <br>- 실행 중 |
| Terminated | `Terminated` 상태의 컨테이너는 실행을 시작한 다음 완료될 때까지 실행되었거나 어떤 이유로 실패했다. `kubectl` 을 사용하여 컨테이너가 `Terminated` 인 파드를 쿼리하면, 이유와 종료 코드 그리고 해당 컨테이너의 실행 기간에 대한 시작과 종료 시간이 표시된다. <br> 컨테이너에 구성된 `preStop` 훅이 있는 경우, 컨테이너가 `Terminated` 상태에 들어가기 전에 실행된다 <br> `preStop` : stop하기 전에 하는 작업<br>- 종료 |

<br>

#### 컨테이너의 재시작 정책

파드의 `pods.spec.restartPolicy`에 선언한다.

사용 가능한 값은 `Always`, `OnFailure` , `Never`이며 기본값은 `Always`이다.

```shell
$ kubectl explain pods.spec.restartPolicy
KIND:     Pod
VERSION:  v1

FIELD:    restartPolicy <string>

DESCRIPTION:
     Restart policy for all containers within the pod. One of Always, OnFailure,
     Never. Default to Always. More info:
     https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy
```

파드의 컨테이너가 종료된 후, kubelet은 5분으로 제한되는 지수 백오프 지연(10초, 20초, 40초, …)으로 컨테이너를 재시작한다.

<br>

##### 지수 백오프(Log Backoff)

지수 백오프는 재시작하는 시간(유예시간)이 최대 30초 까지 점점 느려지는 현상을 의미한다. (지수 그래프)

존재하지 않는 이미지로 파드를 생성해서 지수 백오프 현상을 확인해보자.

```shell
$ kubectl get pods --watch
NAME    READY   STATUS              RESTARTS   AGE
myweb   0/1     ContainerCreating   0          5s
myweb   0/1     ErrImagePull        0          5s
myweb   0/1     ImagePullBackOff    0          16s
myweb   0/1     ErrImagePull        0          35s
myweb   0/1     ImagePullBackOff    0          50s
myweb   0/1     ErrImagePull        0          68s
myweb   0/1     ImagePullBackOff    0          82s
myweb   0/1     ErrImagePull        0          2m3s
myweb   0/1     ImagePullBackOff    0          2m16s
myweb   0/1     ErrImagePull        0          3m32s
myweb   0/1     ImagePullBackOff    0          3m44s
myweb   0/1     ErrImagePull        0          6m19s
myweb   0/1     ImagePullBackOff    0          6m34s
myweb   0/1     ErrImagePull        0          11m
myweb   0/1     ImagePullBackOff    0          11m
```

재시작 정책이 `Always`로 되어있기 때문에 계속 재시작하게 되고, `ImagePullBackOff` 간격이 점점 늘어나는 것을 확인할 수 있다.

지수(`log`)라는 개념 없이 선형적으로 `Backoff`를 시도하게 되면, 

리소스가 한 두개일 때는 크게 관계 없으나, 여러개일 때는 계속 재시도를 하면서 **리소스를 불필요하게 소모**하게된다. 

<br>

참고로 `--watch`는 변화가 생길 때만 찍히게 되고, 싱글 리소스 타입만 가능하다. (여러개 타입 지정 불가능)

<br>

##### 프로브 메커니즘

프로브를 사용하여 컨테이너를 체크하는 방법에는 4가지가 있다


- `exec` 
  - 컨테이너 내에서 지정된 명령어를 실행
  - 명령어가 상태 코드 0으로 종료되면 진단이 성공한 것으로 간주
  - 예 : `mysqladmin ping`

```shell
$ kubectl explain pods.spec.containers.livenessProbe.exec
KIND:     Pod
VERSION:  v1

RESOURCE: exec <Object>

DESCRIPTION:
     One and only one of the following should be specified. Exec specifies the
     action to take.

     ExecAction describes a "run in container" action.

FIELDS:
   command      <[]string>
     Command is the command line to execute inside the container, the working
     directory for the command is root ('/') in the container's filesystem. The
     command is simply exec'd, it is not run inside a shell, so traditional
     shell instructions ('|', etc) won't work. To use a shell, you need to
     explicitly call out to that shell. Exit status of 0 is treated as
     live/healthy and non-zero is unhealthy.
```

- `tcpSocket` : 네트워크 서비스인 경우

  - 지정된 포트에서 컨테이너의 IP 주소에 대해 TCP 검사를 수행

  - 해당 포트 TCP 연결
  - 포트를 반드시 지정해야함

```shell
$ kubectl explain pods.spec.containers.livenessProbe.tcpSocket
KIND:     Pod
VERSION:  v1

RESOURCE: tcpSocket <Object>

DESCRIPTION:
     TCPSocket specifies an action involving a TCP port. TCP hooks not yet
     supported

     TCPSocketAction describes an action based on opening a socket

FIELDS:
   host <string>
     Optional: Host name to connect to, defaults to the pod IP. #디폴트 값은 파드의 IP

   port <string> -required-
     Number or name of the port to access on the container. Number must be in
     the range 1 to 65535. Name must be an IANA_SVC_NAME.
```

- `grpc` 
  - gRPC를 사용하여 원격 프로시저 호출을 수행
  - gRPC 프로토콜 연결

- `httpGet` : Web, WebApp인 경우

  - 지정한 포트 및 경로에서 컨테이너의 IP 주소에 대한 HTTP `GET` 요청을 수행

  - 요청을 했을 때, 상태 코드가 몇 번인 지에 대한 것
  - 응답의 상태 코드가 200 이상 400 미만이면 진단이 성공한 것으로 간주
  - 포트를 반드시 지정해야함

```shell
$ kubectl explain pods.spec.containers.livenessProbe.httpGet
KIND:     Pod
VERSION:  v1

RESOURCE: httpGet <Object>

DESCRIPTION:
     HTTPGet specifies the http request to perform.

     HTTPGetAction describes an action based on HTTP Get requests.

FIELDS:
   host <string> #host를 지정하지 않으면 파드의 IP
     Host name to connect to, defaults to the pod IP. You probably want to set
     "Host" in httpHeaders instead.

   httpHeaders  <[]Object>
     Custom headers to set in the request. HTTP allows repeated headers.

   path <string>
     Path to access on the HTTP server.

   port <string> -required-
     Name or number of the port to access on the container. Number must be in
     the range 1 to 65535. Name must be an IANA_SVC_NAME.

   scheme       <string>
     Scheme to use for connecting to the host. Defaults to HTTP. #default는 HTTP
```

- `periodSeconds` : `probe` 체크 주기성, 몇 초에 1번씩 진행할 것인지

  - 최소값은 1초부터 가능하며, 기본값은 10초이다. 

  - 너무 짧게 설정하면 부하가 될 수 있으므로, 적당한 간격을 두는 것이 좋다.

```shell
$ kubectl explain pods.spec.containers.livenessProbe.periodSeconds
KIND:     Pod
VERSION:  v1

FIELD:    periodSeconds <integer>

DESCRIPTION:
     How often (in seconds) to perform the probe. Default to 10 seconds. Minimum
     value is 1.
```

- `failureThreshold` : 상태가 `Failure`가 되기 위한 기준
  - 연속적으로 몇번 실패해야하는 지
  - 최솟값은 1이며, default는 3번

```shell
$ kubectl explain pods.spec.containers.livenessProbe.failureThreshold
KIND:     Pod
VERSION:  v1

FIELD:    failureThreshold <integer>

DESCRIPTION:
     Minimum consecutive failures for the probe to be considered failed after
     having succeeded. Defaults to 3. Minimum value is 1.
```

- `successThreshold` : 상태가 `Success`가 되기 위한 기준
  - 연속적으로 몇번 성공해야는 지
  - 최솟값은 1이며, default도 1번

```shell
$ kubectl explain pods.spec.containers.livenessProbe.successThreshold
KIND:     Pod
VERSION:  v1

FIELD:    successThreshold <integer>

DESCRIPTION:
     Minimum consecutive successes for the probe to be considered successful
     after having failed. Defaults to 1. Must be 1 for liveness and startup.
     Minimum value is 1.
```

- `initialDelaySeconds` 
  - 기본적으로 setting하지 않으면 0
  - **최초의 프로브를 보내기 전 delay를 두는 것**이다.
  - 실행하는데 시간이 오래 걸기는 애플리케이션의 경우, 실행이 완료되기 전에 프로브를 보내면 응답이 없을 수 있다.
  - 애플리케이션 실행이 평균적으로 얼마나 걸릴 지는 체크해보고, 여유있게 설정해주는 것이 좋다.

```shell
$ kubectl explain pods.spec.containers.livenessProbe.initialDelaySeconds
KIND:     Pod
VERSION:  v1

FIELD:    initialDelaySeconds <integer>

DESCRIPTION:
     Number of seconds after the container has started before liveness probes
     are initiated. More info:
     https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
```

- `timeoutSecoonds`
  - 프로브를 전송한 후 응답이 돌아오는데 몇 초 까지 허용을 하는가에 대한 것
  - 최솟값은 1초이며, default도 1초이다.

```shell
$ kubectl explain pods.spec.containers.livenessProbe.timeoutSeconds
KIND:     Pod
VERSION:  v1

FIELD:    timeoutSeconds <integer>

DESCRIPTION:
     Number of seconds after which the probe times out. Defaults to 1 second.
     Minimum value is 1. More info:
     https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
```

<br>

#### 컨테이너 프로브(Probe)

*프로브*는 [kubelet](https://kubernetes.io/docs/reference/command-line-tools-reference/kubelet/)에 의해 컨테이너의 상태를 주기적으로 체크하는 것이다.

진단을 수행하기 위해서, kubelet은 컨테이너 안에서 코드를 실행하거나, 네트워크 요청을 전송한다

<br>

##### 프로브 결과

컨테이너로 ` probe signal`을 보낸다.

- `Success` : 컨테이너가 진단을 통과함
- `Faliure` : 컨테이너가 진단에 실패함 -> 잘못된 값이 돌아오는 경우
- `Unknown` : 진단 자체가 실패함 -> 아무런 응답이 돌아오지 않는 경우

<br>

##### 프로브 메커니즘

프로브를 사용하여 컨테이너를 체크하는 방법에는 4가지가 있다

- `exec` 
  - 컨테이너 내에서 지정된 명령어를 실행
  - 명령어가 상태 코드 0으로 종료되면 진단이 성공한 것으로 간주
  - 예 : `mysqladmin ping`

```shell
$ kubectl explain pods.spec.containers.livenessProbe.exec
KIND:     Pod
VERSION:  v1

RESOURCE: exec <Object>

DESCRIPTION:
     One and only one of the following should be specified. Exec specifies the
     action to take.

     ExecAction describes a "run in container" action.

FIELDS:
   command      <[]string>
     Command is the command line to execute inside the container, the working
     directory for the command is root ('/') in the container's filesystem. The
     command is simply exec'd, it is not run inside a shell, so traditional
     shell instructions ('|', etc) won't work. To use a shell, you need to
     explicitly call out to that shell. Exit status of 0 is treated as
     live/healthy and non-zero is unhealthy.
```

- `tcpSocket` : 네트워크 서비스인 경우

  - 지정된 포트에서 컨테이너의 IP 주소에 대해 TCP 검사를 수행

  - 해당 포트 TCP 연결
  - 포트를 반드시 지정해야함

```shell
$ kubectl explain pods.spec.containers.livenessProbe.tcpSocket
KIND:     Pod
VERSION:  v1

RESOURCE: tcpSocket <Object>

DESCRIPTION:
     TCPSocket specifies an action involving a TCP port. TCP hooks not yet
     supported

     TCPSocketAction describes an action based on opening a socket

FIELDS:
   host <string>
     Optional: Host name to connect to, defaults to the pod IP. #디폴트 값은 파드의 IP

   port <string> -required-
     Number or name of the port to access on the container. Number must be in
     the range 1 to 65535. Name must be an IANA_SVC_NAME.
```

- `grpc` 
  - gRPC를 사용하여 원격 프로시저 호출을 수행
  - gRPC 프로토콜 연결

- `httpGet` : Web, WebApp인 경우

  - 지정한 포트 및 경로에서 컨테이너의 IP 주소에 대한 HTTP `GET` 요청을 수행

  - 요청을 했을 때, 상태 코드가 몇 번인 지에 대한 것
  - 응답의 상태 코드가 200 이상 400 미만이면 진단이 성공한 것으로 간주
  - 포트를 반드시 지정해야함

```shell
$ kubectl explain pods.spec.containers.livenessProbe.httpGet
KIND:     Pod
VERSION:  v1

RESOURCE: httpGet <Object>

DESCRIPTION:
     HTTPGet specifies the http request to perform.

     HTTPGetAction describes an action based on HTTP Get requests.

FIELDS:
   host <string> #host를 지정하지 않으면 파드의 IP
     Host name to connect to, defaults to the pod IP. You probably want to set
     "Host" in httpHeaders instead.

   httpHeaders  <[]Object>
     Custom headers to set in the request. HTTP allows repeated headers.

   path <string>
     Path to access on the HTTP server.

   port <string> -required-
     Name or number of the port to access on the container. Number must be in
     the range 1 to 65535. Name must be an IANA_SVC_NAME.

   scheme       <string>
     Scheme to use for connecting to the host. Defaults to HTTP. #default는 HTTP
```

- `periodSeconds` : `probe` 체크 주기성, 몇 초에 1번씩 진행할 것인지

  - 최소값은 1초부터 가능하며, 기본값은 10초이다. 

  - 너무 짧게 설정하면 부하가 될 수 있으므로, 적당한 간격을 두는 것이 좋다.

```shell
$ kubectl explain pods.spec.containers.livenessProbe.periodSeconds
KIND:     Pod
VERSION:  v1

FIELD:    periodSeconds <integer>

DESCRIPTION:
     How often (in seconds) to perform the probe. Default to 10 seconds. Minimum
     value is 1.
```

- `failureThreshold` : 상태가 `Failure`가 되기 위한 기준
  - 연속적으로 몇번 실패해야하는 지
  - 최솟값은 1이며, default는 3번

```shell
$ kubectl explain pods.spec.containers.livenessProbe.failureThreshold
KIND:     Pod
VERSION:  v1

FIELD:    failureThreshold <integer>

DESCRIPTION:
     Minimum consecutive failures for the probe to be considered failed after
     having succeeded. Defaults to 3. Minimum value is 1.
```

- `successThreshold` : 상태가 `Success`가 되기 위한 기준
  - 연속적으로 몇번 성공해야는 지
  - 최솟값은 1이며, default도 1번

```shell
$ kubectl explain pods.spec.containers.livenessProbe.successThreshold
KIND:     Pod
VERSION:  v1

FIELD:    successThreshold <integer>

DESCRIPTION:
     Minimum consecutive successes for the probe to be considered successful
     after having failed. Defaults to 1. Must be 1 for liveness and startup.
     Minimum value is 1.
```

- `initialDelaySeconds` 
  - 기본적으로 setting하지 않으면 0
  - **최초의 프로브를 보내기 전 delay를 두는 것**이다.
  - 실행하는데 시간이 오래 걸기는 애플리케이션의 경우, 실행이 완료되기 전에 프로브를 보내면 응답이 없을 수 있다.
  - 애플리케이션 실행이 평균적으로 얼마나 걸릴 지는 체크해보고, 여유있게 설정해주는 것이 좋다.

```shell
$ kubectl explain pods.spec.containers.livenessProbe.initialDelaySeconds
KIND:     Pod
VERSION:  v1

FIELD:    initialDelaySeconds <integer>

DESCRIPTION:
     Number of seconds after the container has started before liveness probes
     are initiated. More info:
     https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
```

- `timeoutSecoonds`
  - 프로브를 전송한 후 응답이 돌아오는데 몇 초 까지 허용을 하는가에 대한 것
  - 최솟값은 1초이며, default도 1초이다.

```shell
$ kubectl explain pods.spec.containers.livenessProbe.timeoutSeconds
KIND:     Pod
VERSION:  v1

FIELD:    timeoutSeconds <integer>

DESCRIPTION:
     Number of seconds after which the probe times out. Defaults to 1 second.
     Minimum value is 1. More info:
     https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes
```

<br>

##### 프로브 종류

프로브 종류는 복수로 사용할 수 있다. 복수로 사용할 경우, 모두 성공해야 `Success` 이다.

- `livenessProbe` : `Start`이 후 컨테이너 애플리케이션의 동작(활성) 여부를 나타낸다 
  - 실패하면 컨테이너는 재시작 정책에 의해서 재시작을 하게된다.
  - `livenessProbe`설정을 하지 않는 경우 기본적으로 프로브의 상태는`Success`이다.
  - 실제 작동여부와는 상관없이 컨테이너가 `start`하게 되면 살아있다고(`Live`)라고 생각하게된다. 
  - 실행되었지만, 실행중에 오류가 나는 경우 : `mysql` 변수 지정 안한 경우
- `readinessProbe` : 컨테이너가 요청을 처리할 준비가 되엇는지 여부를 나타낸다
- `startupProbe` : 컨테이너 내의 애플리케이션이 시작되었는지를 나타낸다
  - `startupProbe` 가 `Success`가 되어야 `livenessProbe` 를 실행

<br>

**💻실습 1** : startupProbe 에러

`startupProbe`가 `Success`가 되기전에는 `livenessProbe` 가 실행되지 않는 것을 확인해보자.

먼저 성공할 수 없는 `startupProbe`(없는 디렉토리 `/tmp/abd`)로 설정된 파드를 생성한다.

`myweb-startup.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myweb-startup
spec:
  containers:
    - name: myweb
      image: httpd
      ports:
        - containerPort: 80
          protocol: TCP   
      livenessProbe:
        httpGet: 
          path: "/"
          port: 80
      startupProbe:
        exec:
          command:
           - "ls /tmp/abc" 
```

```shell
$ kubectl create -f myweb-startup.yaml
```

```shell
$ kubectl describe pods myweb-startup
```

`Events`를 확인해보면 계속 ` Startup probe error`가 발생하며, `livenessprobe`가 실행되지 않는 것을 확인할 수 있다.

```shell
Events:
  Type     Reason     Age   From               Message
  ----     ------     ----  ----               -------
  Normal   Scheduled  29s   default-scheduler  Successfully assigned default/myweb-startup to node3
  Normal   Pulling    29s   kubelet            Pulling image "httpd"
  Normal   Pulled     27s   kubelet            Successfully pulled image "httpd" in 1.932269787s
  Normal   Created    27s   kubelet            Created container myweb
  Normal   Started    27s   kubelet            Started container myweb
  Warning  Unhealthy  19s   kubelet            Startup probe errored: rpc error: code = Unknown desc = failed to exec in container: failed to start exec "764392f078aba0b891ccc8567510fa917b432f429ea742be4a8c125a796eb72f": OCI runtime exec failed: exec failed: container_linux.go:380: starting container process caused: exec: "ls /tmp/abc": stat ls /tmp/abc: no such file or directory: unknown
  Warning  Unhealthy  9s    kubelet            Startup probe errored: rpc error: code = Unknown desc = failed to exec in container: failed to start exec "f0fa928375e82fb66bf1b9c8ea05a1428e2233b962451883d08d625362b56c6b": OCI runtime exec failed: exec failed: container_linux.go:380: starting container process caused: exec: "ls /tmp/abc": stat ls /tmp/abc: no such file or directory: unknown
```

<br>

**💻 실습 2 : livenessProbe 에러**

`myweb-liveness-err.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myweb-liveness-err
spec:
  containers:
    - name: myweb
      image: httpd
      ports:
        - containerPort: 80
          protocol: TCP   
      livenessProbe:
        httpGet: 
          path: "/"
          port: 8080
```

```shell
$ kubectl create -f myweb-liveness-err.yaml
```

```shell
$ kubectl describe -f myweb-liveness-err.yaml
```

`Events`를 확인해보면, `Unhealthy : Liveness probe failed`를 확인할 수 있다.

```shell
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  81s                default-scheduler  Successfully assigned default/myweb-liveness-err to node2
  Normal   Pulled     78s                kubelet            Successfully pulled image "httpd" in 2.189370421s
  Normal   Pulled     48s                kubelet            Successfully pulled image "httpd" in 1.959721028s
  Normal   Killing    21s (x2 over 51s)  kubelet            Container myweb failed liveness probe, will be restarted
  Normal   Pulling    20s (x3 over 80s)  kubelet            Pulling image "httpd"
  Normal   Created    18s (x3 over 78s)  kubelet            Created container myweb
  Normal   Started    18s (x3 over 78s)  kubelet            Started container myweb
  Normal   Pulled     18s                kubelet            Successfully pulled image "httpd" in 1.823138424s
  Warning  Unhealthy  1s (x8 over 71s)   kubelet            Liveness probe failed: Get "http://10.233.96.13:8080/": dial tcp 10.233.96.13:8080: connect: connection refused
```

참고: [Dockerfile reference | Docker Documentation](https://docs.docker.com/engine/reference/builder/#healthcheck) : 도커의 `HEALTHCHECK`

쿠버네티스에서 `HEALTH CHECK` 기능을 제공하기 때문에 도커의 기능은 일반적으로 사용하지 않는다.

<br>

**💻 실습 3 : startupProbe, livenessProbe 성공**

`myweb-startup.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myweb-startup
spec:
  containers:
    - name: myweb
      image: httpd
      ports:
        - containerPort: 80
          protocol: TCP   
      livenessProbe:
        httpGet: 
          path: "/"
          port: 80
      startupProbe:
        httpGet: 
          path: "/"
          port: 80    
```

```shell
$ kubectl get pods 
NAME                 READY   STATUS             RESTARTS     AGE
myweb-startup        1/1     Running            0            81s
```

```shell
$ kubectl describe myweb-start
...
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  60s   default-scheduler  Successfully assigned default/myweb-startup to node3
  Normal  Pulling    59s   kubelet            Pulling image "httpd"
  Normal  Pulled     57s   kubelet            Successfully pulled image "httpd" in 1.976433269s
  Normal  Created    57s   kubelet            Created container myweb
  Normal  Started    57s   kubelet            Started container myweb
```

`myweb-startup`이 `Running` 상태이며, `Events`에서 오류가 발견되지 않으므로 `startupProbe`와 `livenessProbe`가 통과된 것을 확인할 수 있다.





