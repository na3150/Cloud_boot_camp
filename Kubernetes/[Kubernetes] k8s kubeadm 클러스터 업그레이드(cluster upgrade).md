# [Kubernetes] k8s kubeadm 클러스터 업그레이드(cluster upgrade)

[여기]()에 이어서, `kubeadm`**으로 생성된 쿠버네티스 클러스터**를 업그레이드해보자.

<br>

### 📌Index

- [버전 차이(skew) 정책](#버전-차이skew-정책)
- [kubeadm cluster 업그레이드](#kubeadm-cluster-업그레이드)

<br>

<br>

## 버전 차이(skew) 정책

[버전 차이(skew) 정책](https://v1-22.docs.kubernetes.io/ko/releases/version-skew-policy/)은 가능한 버전이 어디까지인가에 대한것으로, 쿠버네티스 구성 요소 간에 지원되는 최대 버전 차이를 설명한다.

쿠버네티스 버전은 `x.y.z `로 표현되는데, 여기서 `x` 는 메이저 버전, `y` 는 마이너 버전, `z`는 패치 버전을 의미한다.

<br>

#### kube-apiserver

마스터 노드가 여러개인 경우, `api server`가 여러개 있을 수 있는데,

최신 및 가장 오래된 `kube-apiserver` 인스턴스가 각각 한 단계 마이너 버전 내에 있어야 한다.

즉, 최신 버전을 기준으로해서 마이너 버전 한 단계 아래에 있을 수 있다. 

예시로 최신 `kube-apiserver` 버전이 `1.24` 일 때, 다른 `kube-apiserver` 는 `1.24` 및 `1.23` 을 지원한다.

<br>

#### kubelet

`kubelet`은 `kube-apiserver`보다 최신일 수 없으며, 2단계의 낮은 마이너 버전까지 지원한다.

즉,  `kube-apiserver` 를 `kubelet` 보다 먼저 업그레이드해야한다는 뜻이다. 

예시로  `kube-apiserver` 가 `1.24`일 때, `kubelet`은 `1.24`, `1.23`, `1.22` 를 지원한다.

만약  `kube-apiserver` 가 여러개인 경우에는, 최신 버전의 `kube-apiserver` 에서 2단계 낮은 버전까지만 지원한다.

<br>

#### kube-controller-manager, kube-scheduler ,cloud-controller-manager

`kube-controller-manager`, `kube-scheduler` , `cloud-controller-manager`는 통신하는 `kube-apiserver` 인스턴스보다 최신 버전이면 안 된다. 즉,`kube-apiserver` 를 먼저 업데이트해야하며, 최대 한 단계 낮은 마이너 버전까지만 허용한다(실시간 업그레이드를 지원하기 위해서).

<br>

#### kubectl

`kubectl`은 `kube-apiserver`의 한 단계 마이너 버전(이전 또는 최신) 내(`±1`)에서 지원한다. 

예시로 `kube-apiserver`이 **1.24**라면 `kubectl`은 **1.25**, **1.24** 및 **1.23** 을 지원한다.

`k-proxy` 는 `kubectl`과 함께 작동하기 때문에, `k-proxy`와 `kubectl`는 같다고 보면 된다.

<br>

원칙은 `Control Plane` 작업을 먼저 해준 뒤 `Worker Node` 작업을 해주는 것이다.

`kube-apiserver`, `kube-controller-manager`,` kube-cloud-controller-manage`, `kube-scheduler`는

`Master Node`에만 존재하는 것이고, 나머지는 `Mater Node`와 `Worker Node` 모두에 존재한다. 

<br>

> `kubelet`은 컨테이너를 제어하는 것으로, `kubelet`을 업데이트하면 컨테이너가 중단되어 다운타임이 발생한다.
>
> 따라서 `kubelet` 마이너 버전 업그레이드를 수행하기 전에, 해당 노드의 `pod`를 `drain` (삭제)해야한다.
>
> 단, 기존에 있던 것을 없애버리면 서비스에 문제가 생길 수 있기 때문에 중복(복제본)을 제거한다.

<br>

버전 차이(skew) 정책에 따라 업그레이드 순서를 정리하면 다음과 같다.

1. `kube-apiserver`
2. `kube-controller-manager`,` kube-cloud-controller-manage`, `kube-scheduler`
3. `kubelet`(Control Plane -> Worker Node)
4. `kube-proxy`(Control Plane -> Worker Node)

<br>

단순하게 정리하면 다음과 같다. 

`Control Plane`(`api` -> `c-m`, `c-c-m`, `sched` -> `kubelet`,`k-proxy`) --> `Work Node`(`kubelet`, `proxy`)

이 순서를 섞게되면, 클러스터가 망가져서 복구가 불가능해진다.

> 참고 사항
>
>  `etcd`는 별개의 문제로, 꼭 업그레이드해야하는 것은 아니다.
>
> 컨테이너의 버전을 업데이트한 다는 것은 이미지를 교체한다는 것과 같다.

<br>

<br>

## kuberadm k8s cluster 업그레이드
`k8s cluster`의 버전을 `v1.22.8` (현재)에서 `v1.22.9` 로 업그레이드해보자.

```shell
$ kubectl get nodes
NAME     STATUS   ROLES                  AGE     VERSION
docker   Ready    control-plane,master   45h     v1.22.8
worker   Ready    <none>                 3h10m   v1.22.8
```

<br>

 `k8s cluster` 업그레이드 작업 절차를 정리하면 다음과 같다. 

```
1. Control Plane의 kubeadm 업그레이드
2. Control Plane의 kubeadm으로 api, cm, sched 업그레이드
3. Control Plane의 kubelet, kubectl 업그레이드
4. Worker Node의 kubeadm 업그레이드
5. Worker Node의 kubeadm으로 업그레이드
6. Worker Node의 kubelet, kubectl 업그레이드
```

<br>

[kubeadm-upgrade](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)을 따라 업그레이드를 진행해보자.

먼저, 추상적인 업그레이드 작업 절차는 다음과 같다.

```
1. 기본 컨트롤 플레인 노드를 업그레이드한다.
2. 추가 컨트롤 플레인 노드를 업그레이드한다.
3. 워커(worker) 노드를 업그레이드한다
```

`Control Plane`이 여러개인 경우에, 아무거나 하나를 선택하여 `기본 Control Plane`으로 보는 것이다.

<br>

#### Control Plane

 `Control Plane` 작업을 먼저 해준 뒤 `Worker Node` 작업을 해주는 것이 원칙으로,

`Control Plane` 작업을 먼저 진행해보자.

`kubeadm`이 업그레이드 도구이기 때문에 `kubeadm`를 가장 첫번째로 업그레이드 해줘야한다. 

<br>

**kubeadm 업그레이드**

먼저 `unhold`로 잠김을 풀어줘야 업그레이드를 할 수 있다.

```
$ sudo apt-mark unhold kubeadm
```

```
$ sudo apt update
```

```
$ sudo apt upgrade kubeadm=1.22.9-00 -y
```

버전에 맞게 잘 설치되었는지 확인한다. 

```shell
$ kubeadm version
kubeadm version: &version.Info{Major:"1", Minor:"22", GitVersion:"v1.22.9", GitCommit:"6df4433e288edc9c40c2e344eb336f63fad45cd2", GitTreeState:"clean", BuildDate:"2022-04-13T19:56:28Z", GoVersion:"go1.16.15", Compiler:"gc", Platform:"linux/amd64"}
```

`kubeadm` 업데이트 후, 다시 잠금(`hold`) 해준다.

```
$ sudo apt-mark hold kubeadm
```

```
$ sudo kubeadm upgrade plan
```

```
$ sudo kubeadm upgrade apply v1.22.9
```

필요한 경우 `CNI`도 업그레이드한다.

우리가 사용하는 것은 `Calico`로 현재는 업데이트할 필요가 없으므로, 진행하지 않고 넘어간다.

<br>

**kubelet, kubectl 업그레이드**

```
$ sudo apt-mark unhold kubelet kubectl
```

```
$ sudo apt upgrade kubectl=1.22.9-00 kubelet=1.22.9-00 -y
```

업그레이드를 완료한 후에는 다시 `hold` 해준다.

```
$ sudo apt-mark hold kubelet kubectl
```

```
$ kubelet --version
Kubernetes v1.22.9
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"22", GitVersion:"v1.22.9", GitCommit:"6df4433e288edc9c40c2e344eb336f63fad45cd2", GitTreeState:"clean", BuildDate:"2022-04-13T19:57:43Z", GoVersion:"go1.16.15", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"22", GitVersion:"v1.22.9", GitCommit:"6df4433e288edc9c40c2e344eb336f63fad45cd2", GitTreeState:"clean", BuildDate:"2022-04-13T19:52:02Z", GoVersion:"go1.16.15", Compiler:"gc", Platform:"linux/amd64"}
```

접은글 

> drain 작업
>
> 원래는 여기서 `drain` 작업을 해야하지만, 
>
> 현재 기본적인 것 위에 추가적인 `pod`를 구성하지 않았으므로 `drain`과 `uncordon` 작업은 생략하고 넘어간다.

```shell
$ sudo systemctl daemon-reload #패키지를 새로 설치하기 때문에, 데몬 정보를 다시 읽어옴
$ sudo systemctl restart kubelet
```

> `uncordon  `작업 : `drain` 하지 않았으므로 생략한다.

<br>

```
$ systemctl status kubelet
```

`v1.22.9` 버전으로 바뀐 것을 확인할 수 있다.

```shell
$ kubectl get nodes
NAME     STATUS   ROLES                  AGE    VERSION
docker   Ready    control-plane,master   44h    v1.22.9
worker   Ready    <none>                 170m   v1.22.8
```

여기가 까지가 하나의 사이클이다.

<br>

#### Work Node

`Control Plane` 작업이 끝났고, `Work Node` 작업을 진행해보자.

<br>

**kubeadm 업그레이드**

`kubeadm`을 업그레이드하는 과정은 `Control Plane`과 동일하게 진행된다. 

```
$ sudo apt-mark unhold kubeadm
```

```
$ sudo apt update
```

접은글

만약 `sudo apt update`가 너무 느리다면??

Ubuntu 패키지 저장소 변경함으로써 더 빠르게 진행할 수 있다.
```shell
$ sed -i 's/security.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list
$ sed -i 's/archive.ubuntu.com/mirror.kakao.com/g' /etc/apt/sources.list
$ sudo apt update
```

```
$ sudo apt upgrade kubeadm=1.22.9-00 -y
```

```
$ kubeadm version
```

```
$ sudo apt-mark hold kubeadm
```
여기서부터 `Control Plane`과 조금 달라진다.

`Worker Node`를 업그레이드할 때는 `Control Plane(plan)`과 달리 `node`이다.

```
$ sudo kubeadm upgrade node
```

> drain 작업
>
> 원래는 여기서 `drain` 작업을 해야하지만, 앞서 `Control Plane`에서 설명한 것과 같은 이유로 생략한다. 

<br>

**kubelet, kubectl 업그레이드**

```
$ sudo apt-mark unhold kubelet kubectl
```

```
$ sudo apt upgrade kubectl=1.22.9-00 kubelet=1.22.9-00 -y
```

```
$ sudo apt-mark hold kubelet kubectl
```

```
$ kubelet --version
Kubernetes v1.22.9
$ kubectl version
Client Version: version.Info{Major:"1", Minor:"22", GitVersion:"v1.22.9", GitCommit:"6df4433e288edc9c40c2e344eb336f63fad45cd2", GitTreeState:"clean", BuildDate:"2022-04-13T19:57:43Z", GoVersion:"go1.16.15", Compiler:"gc", Platform:"linux/amd64"}
```

```
$ sudo systemctl daemon-reload
$ sudo systemctl restart kubelet
```

> `uncordon  `작업 : `drain` 하지 않았으므로 생략한다.

`v1.22.9` 버전으로 바뀐 것을 확인할 수 있다.

```shell
$ kubectl get nodes
NAME     STATUS   ROLES                  AGE     VERSION
docker   Ready    control-plane,master   45h     v1.22.9
worker   Ready    <none>                 3h10m   v1.22.9
```

