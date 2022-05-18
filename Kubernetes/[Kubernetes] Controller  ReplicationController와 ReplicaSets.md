# [Kubernetes] Controller : ReplicationController와 ReplicaSets 

[워크로드 | Kubernetes](https://kubernetes.io/ko/docs/concepts/workloads/)

워크로드 리소스는 `Controller`이고, `Controller`는 `Pod`의 집합이다.

파드만을 직접 만드는 경우(싱글톤 파드)는 거의없고, 대부분은 `Controller`를 만들고,

`Controller`가 `Pod`를 만들고, `Pod`가 `Container`를 만든다.

<br>

쿠버네티스는 다음과 같이 여러 가지 빌트인(built-in) 워크로드 리소스를 제공한다.

```
Workload
- Pod
- Controller
  - ReplicationController
  - ReplicaSets
  - DaemonSets
  - Jobs
  - CronJobs
  - Deployments
  - StatefulSets
  - HorizontalPodAutoscaler(HPA)
```

- [`Deployment`](https://kubernetes.io/ko/docs/concepts/workloads/controllers/deployment/) 및 [`ReplicaSet`](https://kubernetes.io/ko/docs/concepts/workloads/controllers/replicaset/) (레거시 리소스 [레플리케이션컨트롤러(ReplicationController)](https://kubernetes.io/ko/docs/reference/glossary/?all=true#term-replication-controller)를 대체). `Deployment` 는 `Deployment` 의 모든 `Pod` 가 필요 시 교체 또는 상호 교체 가능한 경우, 클러스터의 스테이트리스 애플리케이션 워크로드를 관리하기에 적합하다.
  - `Legacy` : 옛날 것, 부정적인 의미로 많이 쓰이나 꼭 그런 것은 아니다.
- [`StatefulSet`](https://kubernetes.io/ko/docs/concepts/workloads/controllers/statefulset/)는 어떻게든 스테이트(state)를 추적하는 하나 이상의 파드를 동작하게 해준다. 예를 들면, 워크로드가 데이터를 지속적으로 기록하는 경우, 사용자는 `Pod` 와 [`PersistentVolume`](https://kubernetes.io/ko/docs/concepts/storage/persistent-volumes/)을 연계하는 `StatefulSet` 을 실행할 수 있다. 전체적인 회복력 향상을 위해서, `StatefulSet` 의 `Pods` 에서 동작 중인 코드는 동일한 `StatefulSet` 의 다른 `Pods` 로 데이터를 복제할 수 있다.
- [`DaemonSet`](https://kubernetes.io/ko/docs/concepts/workloads/controllers/daemonset/)은 노드-로컬 기능(node-local facilities)을 제공하는 `Pods` 를 정의한다. 이러한 기능들은 클러스터를 운용하는 데 기본적인 것일 것이다. 예를 들면, 네트워킹 지원 도구 또는 [add-on](https://kubernetes.io/docs/concepts/cluster-administration/addons/) 등이 있다. `DaemonSet` 의 명세에 맞는 노드를 클러스터에 추가할 때마다, 컨트롤 플레인은 해당 신규 노드에 `DaemonSet` 을 위한 `Pod` 를 스케줄한다.
- [`Job`](https://kubernetes.io/ko/docs/concepts/workloads/controllers/job/) 및 [`CronJob`](https://kubernetes.io/ko/docs/concepts/workloads/controllers/cron-jobs/)은 실행 완료 후 중단되는 작업을 정의한다. `CronJobs` 이 스케줄에 따라 반복되는 반면, 잡은 단 한 번의 작업을 나타낸다.

<br>

<br>

## ReplicationController

[레플리케이션 컨트롤러 | Kubernetes](https://kubernetes.io/ko/docs/concepts/workloads/controllers/replicationcontroller/)

`ReplicationController`는 `Core그룹`에 속한다.

```shell
$ kubectl api-resources | grep replicationcontroller
replicationcontrollers            rc           v1                                     true         ReplicationController
```

**Replication Controller(RC) 목록 확인**

```shell
$ kubectl get replicationcontrollers
$ kubectl get replicationcontroller
$ kubectl get rc
```

파드가 너무 많으면 Replication Controller가 추가적인 파드를 제거하고, 너무 적으면 파드를 시작한다.

노드 1개가 종료되어서 새로 만들려고 시도할 때, CPU 및 Memory 부족으로 새로운 파드 생성이 불가능한 경우와 같이 

RC가 해결할 수 없는 경우가 존재하기는 한다.  이와 같은 경우를 제외하고, RC는 사용자가 선언한 형태로 유지하도록 노력한다.

파드가 실패하거나 삭제되거나 종료되는 경우에는 자동으로 교체(새로운 것을 생성)된다.

<br>

**리소스 정의 방법 확인**

```shell
$ kubectl explain rc
```

`rc.spec`

- `replicas` : 생성할 replica의 개수, default는 1
- `selector` : pod의 label selector
- `template` : pod template
- `minReadySeconds` : 새로 생성된 포드가 준비되어야 하는 최소 시간, default는 0

<br>

##### Pod Template

`rc.spec.template` : RC가 Pod를 만들 때 사용할 정보, `Pod Template`

```shell
$ kubectl explain rc.spec.template
KIND:     ReplicationController
VERSION:  v1

RESOURCE: template <Object>

DESCRIPTION:
     Template is the object that describes the pod that will be created if
     insufficient replicas are detected. This takes precedence over a
     TemplateRef. More info:
     https://kubernetes.io/docs/concepts/workloads/controllers/replicationcontroller#pod-template

     PodTemplateSpec describes the data a pod should have when created from a
     template

FIELDS:
   metadata     <Object>      #파드의 메타데이터가 여기에 들어감, 즉 pod.spec* == rc.spec.template.spec.*
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata

   spec <Object>
     Specification of the desired behavior of the pod. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
```

- 템플릿의 메타데이터가 파드의 메타데이터이고, 템플릿의 spec이 파드의 spec이다.
- `pod.spec*` == `rc.spec.template.spec.*`

<br>

template은 파드가 만들어질 때 사용되는 것이기 때문에 , 

만약 이미 파드가 생성된 상태이고, **중간에 `template`을 수정해도 파드는 변경되지 않는다.**

변경된 template을 반영하고 싶다면 pod를 하나씩 지우면 rc가 변경된 template으로 다시 파드를 생성한다.

<br>

<br>

##### Selector

싱글톤 파드일 때는 `Label`이 없어도 무방하나, **`Controller`가 관리하는 모든 파드에는 `Label`이 붙어있어야한다.⭐**

 `Controller`가 여러개의 파드들 중에서 관리하는 파드들을` Selecting`해야한다.

이때, 동일한 `Controller`에 의해 제어되는 파드들은 동일한 `Label`을 가져야한다.

```shell
$ kubectl explain rc.spec.selector
KIND:     ReplicationController
VERSION:  v1

FIELD:    selector <map[string]string>

DESCRIPTION:
     Selector is a label query over pods that should match the Replicas count.
     If Selector is empty, it is defaulted to the labels present on the Pod
     template. Label keys and values that must match in order to be controlled
     by this replication controller, if empty defaulted to labels on Pod
     template. More info:
     https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors
```

`selector`와 `label`은 값이 항상 똑같아야한다. 다르면 아예 생성조차 되지 않는다. 

단, 파드에 레이블을 추가하는 형태는 가능하다. 셀렉팅만 가능하면 된다. --> `selector ⊂ label` 

예시

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: myweb-rc
spec: 
  replicas: 3
  selector: 
    app: web
  template: 
      metadata: 
        labels: 
          app: web 
          env: dev
      spec:
        containers:
          - name: myweb
            image: ghcr.io/c1t1d0s7/go-myweb
            ports:
              - containerPort: 8080
```

<br>

 `Label`은 검색할 때도 사용할 수 있지만, 제거할 때도 사용할 수 있다.

```shell
$ kubectl delete pods -l app=web
```

`-all` 옵션을 사용하여 한번에 모두 제거하는 것도 가능하다.

```shell
$ kubectl delete pods -all
```

<br>

**💻 실습 : pod template**

`myweb-rc.yaml`

```yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: myweb-rc
spec: 
  replicas: 3
  selector: 
    app: web
# Pod Configure
  template: 
      metadata:
        # name: 항상 똑같은 이름의 Pod를 생성할 것이 아니기 때문에 name은 지정하지 않는다
        # pod의 name은 controller의 이름 뒤에 랜덤한 값이 붙게된다. 
        labels: 
          app: web 
      spec:
        containers:
          - name: myweb
            image: ghcr.io/c1t1d0s7/go-myweb
            ports:
              - containerPort: 8080
                protocol: TCP
```

```shell
$ kubectl create -f myweb-rc.yaml
```

파드의 NAME이 Controller의 이름(myweb-rc) 뒤에 랜덤한 값이 붙어 생성된 것을 확인할 수 있다.

`replicas`에 설정된 값에 따라 설정된 `DESIRED`를 확인할 수 있다.  

```shell
$ kubectl get rc,pods
NAME                             DESIRED   CURRENT   READY   AGE
replicationcontroller/myweb-rc   3         3         3       2m53s

NAME                 READY   STATUS             RESTARTS   AGE
pod/myweb-rc-5j5s4   1/1     Running            0          2m53s
pod/myweb-rc-j47t8   1/1     Running            0          2m53s
pod/myweb-rc-ndf7c   1/1     Running            0          2m53s
```

```shell
$ kubectl get rc -o wide
NAME       DESIRED   CURRENT   READY   AGE    CONTAINERS   IMAGES                      SELECTOR
myweb-rc   3         3         3       4m3s   myweb        ghcr.io/c1t1d0s7/go-myweb   app=web
$ kubectl get pods --show-labels
NAME             READY   STATUS             RESTARTS   AGE     LABELS
myweb-rc-5j5s4   1/1     Running            0          4m12s   app=web
myweb-rc-j47t8   1/1     Running            0          4m12s   app=web
myweb-rc-ndf7c   1/1     Running            0          4m12s   app=web
```

이 상태에서 레이블을 바꿔보자.

`ReplicaController` 입장에서는 관리할 것이 2개가 된 것이기 때문에, 새로운 것을 하나 더 만들어낸다.

그리고 레이블이 변경된 파드는 더 이상 관리 대상이 아니게 된다.

```shell
Every 2.0s: kubectl get pods --show-labels               k8s-node1: Wed May 18 03:54:08 2022

NAME             READY   STATUS             RESTARTS   AGE     LABELS
myweb-rc-4zjl4   1/1     Running            0          5s      app=web
myweb-rc-5j5s4   1/1     Running            0          7m13s   app=web
myweb-rc-j47t8   1/1     Running            0          7m13s   app=web
myweb-rc-ndf7c   1/1     Running            0          7m13s   app=database
```

여기서 레이블을 다시 `app=web`으로 바꾸면 관리할 것이 RC입장에서는 관리 대상이 4개가 되므로 1개가 삭제된다.

이때, 가장 최근에 만들어진 것이 지워지게 된다.

<br>

#### RC 스케일링

##### 명령형 커맨드 구성

`--replicas` 옵션을 사용하여 스케일링한다.

```shell
$ kubectl scale rc myweb-rc --replicas=5
$ kubectl scale rc/myweb-rc --replicas=5
```

여기서 만약 `myweb-rc.yaml`의 `replicas`를 수정하고,

 `kubectl create`를 시도하게되면 해당 이름으로 된 것이 이미 존재하기 때문에 에러가 발생한다.

```shell
$ kuectl replace -f myweb-rc.yaml
Error from server (AlreadyExists): error when creating "myweb-rc.yaml": replicationcontrollers "myweb-rc" already exists
```

이때 사용하는 것이 `kubectl replace`이다.

<br>

##### 명령형 오브젝트 구성

##### kubectl replace

```shell
$ kubectl replace -f myweb.yaml
```

이와 같이 `replicas`를 수정하고 `replace`하면 설정된 수에 맞게 파드의 수가 조정된다.

단, `Template`을 수정한 경우에는 반영되지 않는다. 앞서 설명했듯이 Template은 파드가 생성될 때 참조하는 것이기 때문이다.

이러한 경우는 파드를 하나씩 지워나가면 RC가 변경된 template으로 다시 파드를 생성한다.

<br>

**`Template`은 언제든 중간에 수정 가능하지만(적용되는 시점은 파드가 생성될 때),** 

**`Replication Controller` 속성 중  `replicas` 를 제외한 대부분(예: `name`)은 수정하지 못한다.** 

<br>

##### kubectl Patch

패치할 부분을  `json` 형식으로 지정하여 변경할 수 있다.

replace는 수정하고자하는 완전 오브젝트(파일)를 제공해야하지만,

**patch는 변경하고자하는 일부분만 제공**하면 된다. 

간단하게 인라인 형태로 작업하거나 `json` 파일을 생성해서 `patch`할 수 있다.

- 인라인
  - `-f`로 지정한 파일은 리소스를 지칭하기 위한 용도로 사용한 것이므로,  `yaml` 파일의 값은 변경되지 않는다.

```shell
$ kubectl patch -f myweb-rc.yaml -p '{"spec": {"replicas": 3}}'
$ kubectl patch rc myweb-rc -p '{"spec": {"replicas": 3}}'
```

- `json` file

`replicas.json`

```json
{
    "spec":
    {"replicas": 2}
}
```

```shell
$ kubectl patch rc myweb-rc --patch-file raplicas.json
```

<br>

##### kubectl edit

edit을 사용하면 **`etcd` 리소스의 로우데이터를 `vi` 에디터를 통해 실시간 변경**할 수 있다.

```shell
$ kubectl edit -f myweb-rc.yaml
$ kubectl edit rc myweb-rc
```

`vi`에디터로 수정한 뒤 `wp`할 때 검증을 하고, 이상이 있으면 다시 리턴시킨다. 

커맨드에서 `-f`로 지정한 파일은 수정되는 것이 아니라, 리소스를 지칭하기 위한 용도로 사용한 것이다.

 <br>

#### 선언형 오브젝트 구성

##### kubectl apply

없으면 만들어주고, 변경되었으면 변경시켜주는 것까지 한번에 수행한다.

```shell
$ kubectl apply -f myweb-rc.yaml
```

<br>

`apply`만 사용하는 사람도 있고, `create` 한 뒤 `replace`, `patch`, `edit`하는 사람도 있다.

편의에 따라 선택하여 사용하면 된다.

<br>

##### kubectl log

컨트롤러는 로그가 없고, 파드에 로그가 있는 것이다.

따라서 다음과 같이 **컨트롤러가 관리하고 있는 파드를 지정**하여 실행해야한다.

```shell
$ kubectl logs rc/myweb-rc
```

다음과 같이 작성하면 `rc`를 파드의 이름으로 인식하기 때문에 안된다.

```shell
$ kubectl logs rc myweb-rc
```

<br>

#### RC 삭제

컨트롤러를 삭제하면 컨트롤러가 관리하는 파드도 함께 삭제된다.

그러나 `--cascade=orphan` 옵션을 사용하면 컨트롤러만 삭제되고, 파드는 남게된다. 

```shell
$ kubectl delete rc myweb-rc --cascade=orphan
```

<br>

<br>

## ReplicaSets

[레플리카셋 | Kubernetes](https://kubernetes.io/ko/docs/concepts/workloads/controllers/replicaset/)

`ReplicationController`는 `ReplicaSets`(RS)으로 대체 가능하며, 기능은 거의 동일하다.

RS는 `apps` 그룹에 속한다. 

```shell
$ kubectl api-resources | grep replicasets
replicasets                       rs           apps/v1                                true         ReplicaSet
```

컨트롤러의 대부분(daemonsets, deplyments, replicasets, statefulsets)은 `apps` 그룹에 속한다.

`ReplicationController` 달라지는 부분은 `selector`이다.

`ReplicationController` 의 `selector`는 하위가 더 없으나, `ReplicaSets`는 필드가 더 존재한다.

- `matchLabels`
- `matchExpressions`

```shell
$ kubectl explain rs.spec.selector
KIND:     ReplicaSet
VERSION:  apps/v1

RESOURCE: selector <Object>

DESCRIPTION:
     Selector is a label query over pods that should match the replica count.
     Label keys and values that must match in order to be controlled by this
     replica set. It must match the pod template's labels. More info:
     https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/#label-selectors

     A label selector is a label query over a set of resources. The result of
     matchLabels and matchExpressions are ANDed. An empty label selector matches
     all objects. A null label selector matches no objects.

FIELDS:
   matchExpressions     <[]Object>
     matchExpressions is a list of label selector requirements. The requirements
     are ANDed.

   matchLabels  <map[string]string>
     matchLabels is a map of {key,value} pairs. A single {key,value} in the
     matchLabels map is equivalent to an element of matchExpressions, whose key
     field is "key", the operator is "In", and the values array contains only
     "value". The requirements are ANDed.
```

<br>

##### matchLabels

```shell
$ kubectl explain rs.spec.selector.matchLabels
KIND:     ReplicaSet
VERSION:  apps/v1

FIELD:    matchLabels <map[string]string>

DESCRIPTION:
     matchLabels is a map of {key,value} pairs. A single {key,value} in the
     matchLabels map is equivalent to an element of matchExpressions, whose key
     field is "key", the operator is "In", and the values array contains only
     "value". The requirements are ANDed.
```

<br>**💻 실습** : matchLabels

`myweb-rs.yaml`

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: myweb-rs
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
      env: dev
  template:
    metadata:
      labels:
        app: web
        env: dev
    spec:
      containers:
        - name: myweb
          image: ghcr.io/c1t1d0s7/go-myweb
          ports:
            - containerPort: 8080
              protocol: TCP
```

```shell
$ kubectl create -f myweb-rs.yaml
```

```shell
$ kubectl get pods --show-labels
NAME             READY   STATUS    RESTARTS   AGE   LABELS
myweb-rs-dqn92   1/1     Running   0          51s   app=web,env=dev
myweb-rs-fk8k5   1/1     Running   0          51s   app=web,env=dev
myweb-rs-hg42m   1/1     Running   0          51s   app=web,env=dev
```

RS에 의해 관리되는 파드 중 하나의 `label`을 수정해보자 :  `app=web` 제거

`Label`이 바귀고, 더 이상 관리 대상이 아니게 된다.

또한 , RS 입장에서는 관리 대상이 1개 줄게 된 것이므로, 새로운 파드를 한개 더 생성한다.

```shell
$ kubectl label po myweb-rs-hg42m app-
pod/myweb-rs-hg42m labeled
$ kubectl get pods --show-labels
NAME             READY   STATUS    RESTARTS   AGE     LABELS
myweb-rs-dqn92   1/1     Running   0          3m11s   app=web,env=dev
myweb-rs-fk8k5   1/1     Running   0          3m11s   app=web,env=dev
myweb-rs-hg42m   1/1     Running   0          3m11s   env=dev
myweb-rs-tr4bx   1/1     Running   0          3s      app=web,env=dev
```

<br>

##### matchExpressions

`matchLabels`는 RC에서 selector만 사용한 것과 동일하고, RS에 추가된 것은 `matchExpressions` 이다. 

 `matchExpressions` 은 집합성 기준을 추가한 `LabelSelector`이다. 

필드

- `key` : label key
- `operator` : In, NotIn, Exists --> 집합성 기준
- `values` : value

```shell
$ kubectl explain rs.spec.selector.matchExpressions
KIND:     ReplicaSet
VERSION:  apps/v1

RESOURCE: matchExpressions <[]Object>

DESCRIPTION:
     matchExpressions is a list of label selector requirements. The requirements
     are ANDed.

     A label selector requirement is a selector that contains values, a key, and
     an operator that relates the key and values.

FIELDS:
   key  <string> -required-
     key is the label key that the selector applies to.

   operator     <string> -required-
     operator represents a key's relationship to a set of values. Valid
     operators are In, NotIn, Exists and DoesNotExist.

   values       <[]string>
     values is an array of string values. If the operator is In or NotIn, the
     values array must be non-empty. If the operator is Exists or DoesNotExist,
     the values array must be empty. This array is replaced during a strategic
     merge patch.
```

<br>

**💻 실습** : matchExpressions

앞선 matchLabels 실습에 이어서 진행한다.  

`myweb-rs-set.yaml`

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: myweb-rs-set
spec:
  replicas: 3
  selector:
    matchExpressions:
      - key: app
        operator: In
        values: 
          - web
      - key: env
        operator: Exists  
  template:
    metadata:
      labels:
        app: web
        env: dev
    spec:
      containers:
        - name: myweb
          image: ghcr.io/c1t1d0s7/go-myweb
          ports:
            - containerPort: 8080
              protocol: TCP
```

```shell
$ kubectl create -f myweb-rs-set.yaml
```

다음을 자세히 살펴봐보자.

```shell
$ kubectl get rs -o wide          
NAME           DESIRED   CURRENT   READY   AGE   CONTAINERS   IMAGES                      SELECTOR
myweb-rs       3         3         3       15s   myweb        ghcr.io/c1t1d0s7/go-myweb   app=web,env=dev
myweb-rs-set   3         3         3       12s   myweb        ghcr.io/c1t1d0s7/go-myweb   app in (web),env
$ kubectl get pods --show-labels  
NAME                 READY   STATUS    RESTARTS   AGE   LABELS
myweb-rs-l8tmv       1/1     Running   0          30s   app=web,env=dev
myweb-rs-lddhk       1/1     Running   0          30s   app=web,env=dev
myweb-rs-set-5fqt6   1/1     Running   0          27s   app=web,env=dev
myweb-rs-set-lgf45   1/1     Running   0          27s   app=web,env=dev
myweb-rs-set-srhkb   1/1     Running   0          27s   app=web,env=dev
myweb-rs-skhgx       1/1     Running   0          30s   app=web,env=dev
```

`myweb-rs`와 `myweb-rs-set`의 레이블이 동일하며, 둘 다 `SELECTOR`의  조건이 현재 파드 6개를 모두 셀렉팅할 수 있는 조건인데

어떻게 구분하는 것일까❔❔

파드 하나를 지정해서 상세 내용을 확인해보자

```shell
$ kubectl get pod/myweb-rs-set-srhkb -o yaml
```

`ownerReferences`를 살펴보면 `uid`가 존재하는 것을 확인할 수 있다.

파드에 어떤 컨트롤러에 의해 제어되는지 `ownerReferences` 정보가 추가된다. 

이 정보를 통해서 컨트롤러가 자신이 관리할 영역을 잘 찾을 수 있게된다.

```shell
ownerReferences:
  - apiVersion: apps/v1
    blockOwnerDeletion: true
    controller: true
    kind: ReplicaSet
    name: myweb-rs-set
    uid: be3036e5-797d-43e8-99b7-99fb72be9215
```

<br>

실제로는 `ReplicationController`는 잘 사용하지 않고, `ReplicaSets`가 쿠버네티스에서 가장 많이 사용하는 컨트롤러이다.

<br>

참고)

```shell
$ kubectl get -n kube-system rs
NAME                                DESIRED   CURRENT   READY   AGE
calico-kube-controllers-XXXXXXXXX   1         1         1       39h
coredns-XXXXXXXXX                   2         2         2       39h
dns-autoscaler-5ffdc7f89d           1         1         1       39h
```

- `calico-kube-controllers-XXXXXXXXX` 또한 다른 컨트롤러에 의해 만들어진 레플리카셋이다. 
- `coredns-XXXXXXXXX ` 는 `kube-dns` 이다.

<br>
