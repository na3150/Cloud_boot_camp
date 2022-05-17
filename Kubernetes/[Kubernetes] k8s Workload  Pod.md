# [Kubernetes] k8s Workload : Pod

<br>

### 📌Index

- [파드(Pod)란?](#파드pod란)

- [Pod 생성 및 관리](#pod-생성-및-관리)
- [YAML 파일로 파드 정의](#yaml-파일로-파드-정의)
- [Pod 디자인](#pod-디자인)
- [Pod 포트포워딩](#pod-포트포워딩)

<br>

<br>

## 파드(Pod)란?

[워크로드](https://kubernetes.io/ko/docs/concepts/workloads/)는 쿠버네티스에서 구동되는 애플리케이션이다. 

워크로드가 단일 컴포넌트이거나 함께 작동하는 여러 컴포넌트이든 관계없이, 

**쿠버네티스에서는 워크로드를 일련의 [파드](https://kubernetes.io/ko/docs/concepts/workloads/pods) 집합 내에서 실행**한다.

<br>

`Pod`는 하나 이상의 컨테이너 그룹으로, 컨테이너를 실행하기 위한 오브젝트이다.

**쿠버네티스에서 관리할 수 있는 가장 작은 `Workload`는  `Pod`**이다.

즉, **쿠버네티스는 컨테이너를 직접 컨트롤하지 않고, 파드만 관리**할 수 있다

참고로 하나의 파드는 하나의 호스트에만 배치되고, 하나의 노드에 배치된다.

<br>

##### 파드의 사용

1. **단일 컨테이너를 실행하는 파드**
   파드가 하나의 컨테이너만 포함하는 경우이다. 파드는 단순히 컨테이너를 둘러싼 래퍼이며, **쿠버네티스는 컨테이너를 직접 관리하는 대신 파드를 관리**한다.
2. **함께 작동해야하는 여러 컨테이너를 실행하는 파드**
   함께 배치된 컨테이너는 밀접한 결합성을 가지며 리소스를 공유한다. 이들은 하나의 **결합된 서비스 단위**를 형성한다.

<br>

**하나의 파드에는 밀접한 관계를 가진 컨테이너를 배치**해야한다.

WordPress를 예시로 생각해보자. 하나의 파드에 WordPress 컨테이너와 MySQL 컨테이너를 두어도 될까❔

불가능한것은 아니나, 하나의 파드에 wordpress 컨테이너와 mysql 컨테이너를 두는 것은 `Anti-Pattern`이다.

**하나의 파드에는 반드시 하나의 `Main Application`만 있을 수 있어야한다.** 

파드는 특정 노드에 배치되는데, 해당 노드에 문제가 발생한다면 서비스를 사용할 수 없게될 수 있다.

`logs`와 같이 떨어져있으면 의미가 없는 경우에만 하나의 파드에 배치한다. 

<br>

<br>

## Pod 생성 및 관리

##### 명령형 커맨드로 파드 실행

```shell
$ kubectl run
```

```shell
$ kubectl run NAME --image=image [--env="key=value"] [--port=port] [--dry-run=server|client] [--overrides=inline-json]
[--command] -- [COMMAND] [args...] [options]
```

예시

```shell
$ kubectl run myweb --image httpd
pod/myweb created
```

<br>

##### 파드 상세 정보 확인

```shell
$ kubectl get pods
NAME    READY   STATUS    RESTARTS   AGE
myweb   1/1     Running   0          46s
```

- `NAME` : `Pod`의 이름

- `READY` : `준비된 컨테이너의 개수/컨테이너의 총 개수`

- `RESTARTS` : 재시작 횟수

- `AGE` : 현재를 기준으로 만들어진 시각

<br>
`-o wide` 옵션을 사용하면 더 상세한 정보까지 확인할 수 있다.

```shell
$ kubectl get pods -o wide
NAME    READY   STATUS    RESTARTS   AGE     IP            NODE    NOMINATED NODE   READINESS GATES
myweb   1/1     Running   0          2m58s   10.233.96.1   node2   <none>           <none>
```

원하는 형식으로 `etcd`에 저장된 로우 데이터를 확인하는 것도 가능하다.

```shell
$ kubectl get pods -o yaml
$ kubectl get pods -o json
```

<br>

**kubectl describe**

좀 더 깔끔하게 정돈된 형태로 확인할 수 있다.

```shell
$ kubectl describe pods myweb
Name:         myweb
Namespace:    default
Priority:     0
Node:         node2/192.168.100.101
Start Time:   Tue, 17 May 2022 01:37:27 +0000
Labels:       run=myweb
Annotations:  cni.projectcalico.org/containerID: d934f2835963f3a41399d163e4831b1019a6d26cfaf8313078a6e0641bdfcc03
              cni.projectcalico.org/podIP: 10.233.96.1/32
              cni.projectcalico.org/podIPs: 10.233.96.1/32
Status:       Running
IP:           10.233.96.1
IPs:
  IP:  10.233.96.1
Containers:
  myweb:
    Container ID:   containerd://a4c734defa9212f176c05f3318560b0c218ab65ca2f021d7157e0c7cbd2bf0f3
    Image:          httpd
    Image ID:       docker.io/library/httpd@sha256:2d1f8839d6127e400ac5f65481d8a0f17ac46a3b91de40b01e649c9a0324dea0
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Tue, 17 May 2022 01:38:07 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-2g9hd (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  kube-api-access-2g9hd:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
  Normal  Scheduled  6m57s  default-scheduler  Successfully assigned default/myweb to node2
  Normal  Pulling    6m57s  kubelet            Pulling image "httpd"
  Normal  Pulled     6m38s  kubelet            Successfully pulled image "httpd" in 18.992429786s
  Normal  Created    6m17s  kubelet            Created container myweb
  Normal  Started    6m17s  kubelet            Started container myweb
```

여기서 `Events`는 지정한 리소스의 `lifecycle`에 대한 정보이다.

`Events` 정보는 `kubectl describe`를 통해서만 확인할 수 있다.

로그라고도 할 수 있는데, 쿠버네티스에서 리소스 자체에 대한 이벤트 로그로, 시간 순으로 나타난다.

<br>

접은글?

`Events`에 대해서 더 자세히 살펴보자. 설명을 위해 임의로 번호를 붙였다

```
Events:
  Type    Reason     Age    From               Message
  ----    ------     ----   ----               -------
 1.  Normal  Scheduled  6m57s  default-scheduler  Successfully assigned default/myweb to node2
 2.  Normal  Pulling    6m57s  kubelet            Pulling image "httpd"
 3.  Normal  Pulled     6m38s  kubelet            Successfully pulled image "httpd" in 18.992429786s
 4.  Normal  Created    6m17s  kubelet            Created container myweb
 5.  Normal  Started    6m17s  kubelet            Started container myweb
```

1. 파드를 만들 때 가장 먼저하는 것은 스케쥴링으로, 스케쥴러가 어느 노드에 배치할 지 결정해야한다.

첫번째 이벤트가 `default-scheduler`로 부터 생성된 것을 확인할 수 있다.

2. `node2`의 `kubelet`으로 부터 이미지를 pulling 한다.

1번에서 스케쥴러가 `node2`에 배치했기 때문이다.

3. `Pulled`이므로, 이미지 pulling이 완료되었다.
4. `kubelet`이 `myweb` 컨테이너를 생성했다.
5. `kubelet`이 `myweb` 컨테이널르 실행하였다.

<br>

만약 `Pod`가 제대로 작동이 안한다면 크게 2가지를 봐야한다.

- `Pod`가 제대로 만들어졌는지 -> 오브젝트 리소스 자체의 로그 확인
- 컨테이너는 제대로 만들어졌으나, 애플리케이션이 잘 실행 안될 때 --> 애플리케이션 로그 확인(아래에서 설명)

<br>

##### 애플리케이션 로그 확인하기

```shell
$ kubectl logs [Pod]
```

 `kubectl get pods`와 같이 서브 커맨드 뒤에 종류를 지정하는 것이 일반적인데,

애플리케이션 로그를 볼 수 있는 것은 `pod` 밖에 없기 때문에 별도로 `pods`를 붙이지 않는다.

```shell
$ kubectl logs myweb
```

<br>

##### 파드 삭제

```shell
$ kubectl delete pods [pod]
```

예시

```shell
$ kubectl delete pods myweb
```

<br>

<br>

##### ⭐알아둘 사항

`ubuntu:focal` 이미지를 사용해서 `pod` 를 생성해보자

```shell
$ kubectl run myubuntu --image ubuntu:focal
```

시간이 조금 지난 뒤 확인해보면 `CrashLoopBackOff` 상태가 되는 것을 확인할 수 있다.

```shell
$ kubectl get pods
NAME       READY   STATUS             RESTARTS       AGE
myubuntu   0/1     CrashLoopBackOff   2 (18s ago)    7m38s
```

`kubectl describe pods` 명령어를 통해 이벤트 로그를 확인해보자

```shell
Events:
  Type     Reason     Age               From               Message
  ----     ------     ----              ----               -------
  Normal   Scheduled  49s               default-scheduler  Successfully assigned default/myubuntu to node3
  Normal   Pulled     7s (x4 over 48s)  kubelet            Container image "ubuntu:focal" already present on machine
  Normal   Created    7s (x4 over 48s)  kubelet            Created container myubuntu
  Normal   Started    7s (x4 over 48s)  kubelet            Started container myubuntu
  Warning  BackOff    7s (x5 over 47s)  kubelet            Back-off restarting failed container
```

마지막 이벤트에 `Back-off restarting failed container`를 확인할 수 있다.

`pod`는 종료되지 않는 애플리케이션을 실행하는 것이 기본 원칙인데,

쿠버네티스는 기본적으로 무조건 `detach`모드로 실행한다. 

`ubuntu`는 원래 `attach`모드(`-it`)로만 실행해야 유효하기 때문에, 애플리케이션이 종료되었기 때문이다.

참고로 `-d` 옵션은 기본이기 때문에 안붙여도되고, `-it` 옵션을 제공하기는 한다. 

```shell
$ kubectl run myubuntu2 --image ubuntu:focal -it bash
```

<br>

<br>

## YAML 파일로 파드 정의

명령형이랑 섞어서 사용해도 상관없다.

`myweb.yaml`

```shell
apiVersion: v1
kind: Pod
metadata:
  name: myweb
spec:
  containers:
    - name: myweb
      image: httpd
```

**파드 생성**

```
$ kubectl create -f myweb.yaml
```

**파드 확인**

```
$ kubectl get -f myweb.yaml
NAME    READY   STATUS    RESTARTS      AGE
myweb   1/1     Running   1 (22m ago)   4h53m
```

**상세 정보 확인 및 이벤트 정보 확인**

```
$ kubectl describe -f myweb.yaml
```

**파드 삭제**

```
$ kubectl delete -f myweb.yaml
```

<br>

<br>

## Pod 디자인

<img src="https://d33wubrfki0l68.cloudfront.net/aecab1f649bc640ebef1f05581bfcc91a48038c4/728d6/images/docs/pod.svg" alt="파드 생성 다이어그램" width=500/>

`Web Server`가 메인 기능

- **단일 컨테이너** : 일반적인 형태
- **멀티 컨테이너** : 메인 애플리케이션이 존재하고, 메인 애플리케이션 기능을 확장하기 위한 컨테이너를 배치
  - `Main Car`(메인), `Side Car`(보조)

<br>

파드는 기본적으로 파드에 속한 컨테이너에 네트워킹과 스토리지라는 두 가지 종류의 공유 리소스를 제공하고,

하나의 **Pod는 네트워크와 볼륨을 공유**한다. 

Pod는 네트워크를 공유하므로, **Pod에는 하나의 IP만 부여**된다.

<br>

##### 사이드카 패턴

[The Distributed System ToolKit: Patterns for Composite Containers | Kubernetes](https://kubernetes.io/blog/2015/06/the-distributed-system-toolkit-patterns/)

`Composite Container` == `Multi Container` 

3가지 타입 : 큰 범위에서 보면 모두 사이드카인데, 기능적으로 분류한 것이다.

- 사이드카 : 메인 컨테이너의 기능을 확장 (예: Log Saving)
- 앰버서더 : 네트워크 흐름을 컨테이너 내부에서 pod 외부로의 흐름을 가지고 있는 사이드카 (예: Proxy)
  - 내부에서 외부로 나가는 트래픽을 조정
- 어댑터 : 네트워크의 흐름이 외부에서 내부로의 흐름을 가지고 있는 사이드카
  - 컨테이너의 출력을 표준화, 로그를 가공해서 포맷팅(표준화)

**파드는 보조적인 기능을 하는 사이드카를 함께 올리는 것이지 메인 앱을 함께 올리는 것은 안티패턴**이다

<br>

##### ⭐알아둘 사항

다음 yaml 파일을 통해 파드를 생성해보자.

`myweb.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myweb
spec:
  containers:
    - name: myweb
      image: httpd
    - name: myweb2
      image: httpd
```

```shell
$ kubectl create -f myweb.yaml
```

시간이 조금 지난 뒤 `kubectl get pods`로 확인해보면 2개의 컨테이너 중 1개만 준비된 상태이며,

`STATUS`가 `CrashLoopBackoff`인 것을 확인할 수 있다. 

```shell
$ kubectl get pods
NAME    READY   STATUS             RESTARTS      AGE
myweb   1/2     CrashLoopBackOff   1 (20s ago)   27s
```

`kubectl describe`로 상세 정보를 확인해보자

```shell
Containers:
  myweb:
    Container ID:   containerd://bcbebcc7b1a80523e9a10b31da831a18b426b005f134fdc31b2376ee92e80766
    Image:          httpd
    Image ID:       docker.io/library/httpd@sha256:2d1f8839d6127e400ac5f65481d8a0f17ac46a3b91de40b01e649c9a0324dea0
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Tue, 17 May 2022 10:41:34 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-pdj86 (ro)
  myweb2:
    Container ID:   containerd://bbd5515d5fe51161004306dd5f70de320e167ace1de3682f111a0bbb097d307a
    Image:          httpd
    Image ID:       docker.io/library/httpd@sha256:2d1f8839d6127e400ac5f65481d8a0f17ac46a3b91de40b01e649c9a0324dea0
    Port:           <none>
    Host Port:      <none>
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       Error
      Exit Code:    1
      Started:      Tue, 17 May 2022 10:43:19 +0000
      Finished:     Tue, 17 May 2022 10:43:19 +0000
    Ready:          False
    Restart Count:  4
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-pdj86 (ro)
```

`myweb1`은 정상적으로 실행되지만, `myweb2` 계속`Start`과  `Backoff` 을 반복하고 있다. 왜 그럴까❔

파드는 동일한 네트워크를 공유하므로, **포트가 겹치기 때문**이다.

그런데 왜 `myweb1`이 아닌, `myweb2`가 안되는 것일까?

`Containers`는 리스트로, 순서가 있다. `myweb1`이 먼저 생성되기 때문이다.

<br>

참고로 아래의 명령을 실행하면 에러가 발생한다. 

```shell
$ kubectl logs myweb
error: a container name must be specified for pod myweb, choose one of: [myweb myweb2]
```

 `Pod`에 컨테이너가 한개일 때는 컨테이너를 지정하지 않아도 되지만, **여러개로 구성된 경우 컨테이너를 지정**해야한다.

`-c` 옵션을 통해 컨테이너를 지정할 수 있다.

```shell
$ kubectl logs myweb -c myweb2
AH00558: httpd: Could not reliably determine the server's fully qualified domain name, using 10.233.92.11. Set the 'ServerName' directive globally to suppress this message
(98)Address already in use: AH00072: make_sock: could not bind to address [::]:80
(98)Address already in use: AH00072: make_sock: could not bind to address 0.0.0.0:80
no listening sockets available, shutting down
AH00015: Unable to open logs
```

`could not bind to address` : 포트 에러가 난 것을 확인할 수 있다.

<br>

또한 `pod`에 컨테이너가 몇개이든 하나의 노드(`node3`)에 배치되는 것을 확인할 수 있다.

```shell
$ kubectl get pods -o wide
NAME    READY   STATUS             RESTARTS      AGE     IP             NODE    NOMINATED NODE   READINESS GATES
myweb   1/2     CrashLoopBackOff   6 (69s ago)   7m11s   10.233.92.11   node3   <none>           <none>
```

다음 명령어로 네트워크를 공유하는 것도 확인할 수 있다

```shell
$ kubectl describe pods
```

<br>

<br>

## Pod 포트포워딩

파드의 포트포워딩이 가능은 하나, 파드의 포트포워딩은 외부로 노출시키기 위해 사용하는 것이 아니다.

포그라운드(foreground) 상태로 작동하며, 테스트 & 디버깅 목적으로 사용한다.

```
$ kubectl port-forward TYPE/NAME [options] [LOCAL_PORT]:[REMOTE_PORT]
```

쿠버네티스는 외부에 노출시키기 위해 네트워크(서비스) 오브젝트를 사용해야한다.

<br>

💻 실습

`myweb.yaml`

```shell
apiVersion: v1
kind: Pod
metadata:
  name: myweb
spec:
  containers:
    - name: myweb
      image: httpd
      ports:
        - containerPort: 80
          protocol: TCP     
```

```shell
$ kubectl create -f myweb.yaml 
```

0~1023번 포트는 열려면 관리자 권한이 필요하므로 `8080` 포트로 진행한다.

```shell
$ kubectl port-forward pods/myweb 8080:80
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
```

다른 터미널 창을 열어 확인해보면 정상적으로 작동하는 것을 확인할 수 있다.

```shell
$ curl localhost:8080
<html><body><h1>It works!</h1></body></html>
```

<br>

<br>