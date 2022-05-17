# [Kubernetes] k8s Namespace

<br>

### 📌Index

- [이름과 UID](#이름과-uid)

- [Namespace](#namespace)

<br>

<br>

## 이름과 UID

[오브젝트 이름과 ID | Kubernetes](https://kubernetes.io/ko/docs/concepts/overview/working-with-objects/names/)

클러스터의 각 오브젝트는 해당 유형의 리소스에 대하여 고유한 [*이름*](https://kubernetes.io/ko/docs/concepts/overview/working-with-objects/names/#names) 을 가지고 있다. 이름은 Namespace 내에서 유일하면 된다.

`Namespace`는 분리하기 위한 용도와, DNS이름이 분리되는 용도를 위해 사용한다.

기본적으로는 `default Namespace`를 사용한다.   

<br>

오브젝트를 리소스로 만들 때 쿠버네티스의 컨트롤러 매니저는 해당되는 리소스에 `UID`를 붙이게 되고,

모든 쿠버네티스 오브젝트는 **전체 클러스터에 걸쳐 고유한 [*UID*](https://kubernetes.io/ko/docs/concepts/overview/working-with-objects/names/#uids)** 를 가지고 있다.

<br>

<br>

## Namespace

namespace란, **쿠버네티스 클러스터 내의 논리적인 분리 단위**이다.

다음과 같이 리소스를 분리할 수 있다.

**리소스 분리**

- 서비스 별
- 사용자 별
- 환경: 개발, 스테이징, 프로덕션

기본 작업 공간은 `default` namespace이다. 

<br>

##### 네임스페이스 확인하기

```shell
$ kubectl get namespaces
```

```shell
$ kubectl get ns
```

`--namespace` 옵션을 명시하지 않으면 모두 default 네임스페이스에서 수행된다.

`-n` == `--namespace`

예시 : `default` 네임스페이스에서 생성된 포드 확인하기

```shell
$ kubectl get pods --namespace default
NAME    READY   STATUS    RESTARTS   AGE
myweb   1/1     Running   0          47m
```

<br>

##### 모든 네임스페이스의 리소스 확인

`-A` == `--all-namespaces`

```shell
$ kubectl get <RESOURCE> namespaces -A
```

```shell
$ kubectl get <RESOURCE> --all-namespaces
```

예시

```shell
$ kubectl get pods --all-namespaces
```

<br>

- kube-system: Kubernetes의 핵심 컴포넌트
- kube-public: 모든 사용자가 읽기 권한(슈퍼유저는 어떤 `Namespace`든 읽고 쓸 수 있다)
- kube-node-lease: 노드의 HeartBeat 체크를 위한 Lease 리소스가 존재
- default: 기본 작업 공간

```shell
$ kubectl get pods -n kube-public
```

<br>

##### lease

`leases`는 HB(Heart Beat) 즉, 노드가 죽어있는지 살아있는지 체크할 때 사용하는 리소스이다.

```shell
$ kubectl get leases -n kube-node-leases
```

결과는 노드의 목록과 같다.

<br>

##### Namespace 생성하기

명령형 커맨드로 생성하기

```shell
$ kubectl create namespace developments
```

`yaml` 파일로 생성하기

<br>

예시1

`ns-dev.yaml`

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: dev
```

예시2

`myweb-dev.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myweb
  namesapce: dev
spec:
  containers:
    - name: myweb
      image: httpd
      ports:
        - containerPort: 80
          protocol: TCP
```

생성한 `yaml` 파일로 파드를 생성한다.

```shell
vagrant@k8s-node1:~/pod$ kubectl create -f dev-ns.yaml 
namespace/dev created
vagrant@k8s-node1:~/pod$ kubectl get ns
NAME              STATUS   AGE
default           Active   14h
dev               Active   3s
kube-node-lease   Active   14h
kube-public       Active   14h
kube-system       Active   14h
```

namespace가 다르면 pod의 이름은 같아도 되고, 아래 2개의 `myweb`는 서로 다른 것이다.

-->  `default` 네임스페이스의 `myweb`과 `dev` 네임스페이스의 `myweb`

```shell
$ kubectl get pods
NAME    READY   STATUS    RESTARTS   AGE
myweb   1/1     Running   0          33m
$ kubectl get pods -n dev
NAME    READY   STATUS    RESTARTS   AGE
myweb   1/1     Running   0          38m
```

<br>

##### Namespace 삭제하기

단, 지울 때는 네임스페이스에 리소스가 없어야한다. 

```shell
$ kubectl delete ns <NAMESPACE>
```

```shell
$ kubectl delete pods <Pod> -n <NAMESPACE>
```

`pod` 삭제 시, `-n` 옵션을 붙이지 않으면 `default namespace`에서 삭제되므로 주의해야한다.

<br>

<br>
참고 사항

`namespace.spec`을 확인하면 `finalizers`라는 필드를 확인할 수 있다.

```shell
$ kubectl explain namespace.spec
KIND:     Namespace
VERSION:  v1

RESOURCE: spec <Object>

DESCRIPTION:
     Spec defines the behavior of the Namespace. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status

     NamespaceSpec describes the attributes on a Namespace.

FIELDS:
   finalizers   <[]string>
     Finalizers is an opaque list of values that must be empty to permanently
     remove object from storage. More info:
     https://kubernetes.io/docs/tasks/administer-cluster/namespaces/
```

`Finalizers` 는 리소스를 지울 때 어떻게 할 것인지에 대한 설정을 하는 것이다.

`yaml` 파일을 통해 파드를 생성할 때, 아주 드물에 `spec`이 없는 경우가 있는데,

namespace는 `Finalizers`라는 필드가 없으면 `spec`을 설정할 이유가 없다.

<br>

<br>