# [Kubernetes] k8s Taint와 Tolereation

[테인트(Taints)와 톨러레이션(Tolerations) | Kubernetes](https://kubernetes.io/ko/docs/concepts/scheduling-eviction/taint-and-toleration/)

<br>

### 📌Index

- [Taint](#taint)
- [Toleration](#toleration)

<br>

<br>

## Taint

특정 노드에 Taint를 지정할 수 있는데, **Taint를 설정한 노드에는 포드가 scheduling되지 않는다.**

참고 : [kubectl taint](https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands#taint)

<br>

**Taint 추가하기**

```shell
$ kubectl taint node [nodename] [key]=[value]:[effect]
```

value는 필수는 아니다.

<br>

**Taint 제거하기**

```shell
$ kubectl taint node [nodename] [key]=[value]:[effect]-
```

<br>

참고로 **[Cordon](https://nayoungs.tistory.com/entry/Kubernetes-k8s-Cordon%EA%B3%BC-Drain)을 설정하면 자동으로 Taint가 추가**된다.

```shell
$ kubectl cordon node2
node/node2 cordoned
$ kubectl describe node node2 | grep -i taint
Taints:             node.kubernetes.io/unschedulable:NoSchedule
$ kubectl uncordon node2                     
node/node2 uncordoned
$ kubectl describe node node2 | grep -i taint
Taints:             <none>
```

<br>

예시

taint 추가

```shell
$vkubectl taint nodes node1 key1=value1:NoSchedule
```

taint 제거

```shell
$ kubectl taint nodes node1 key1=value1:NoSchedule-
```

<br>

<br>

## Toleration

**노드에 Taint가 설정되어있는 경우, Toleration을 설정하여 스케쥴링이 가능하게 할 수 있다.**

<br>

**리소스 정의 방법 확인**

```shell
$ kubectl explain pod.spec.tolerations
```

- `operator`
  - `Exists` : 동일한 key만 존재하면 된다.
  - `Equal` : key와 value가 모두 동일해야한다.
- `effect` 
  - `NoSchedule` : 스케쥴링이 불가능하다(hard)
    - 스케쥴링할 때만 확인한다. (기존의 것 체크 X)
  - `PreferNoSchedule` : 스케쥴링이 불가능하도록 시도하지만, 보장은 하지 않는다(soft)
    - 스케쥴링할 때만 확인한다. (기존의 것 체크 X)
    - 클러스터내에 자원이 부족한 경우, taint가 걸려있는 노드에서도 pod가 스케줄링될 수 있다.
  - `NoExecute` : toleration이 없으면 스케쥴링되지 않으며, 기존에 실행되던 pod도 toleration이 없으면 종료시킨다.
    - 예시
      - tolertation `:NoExecute op=Exists` 
      - 아무 key와 관계 없이 NoExecute는 실행할 수 있다 => taint가 걸려있어도 상관없다(무적)
  - 효과: `NoSchedule`  ⊂ `NoSchedule`  ⊂ `NoExecute` 

<br>

결론적으로, Taint는 일차원적으로 봤을 때는 Scheduling을 못하게하는 것이라고 생각할 수 있지만,

이차원적으로 생각하면 **Taint는 특정 노드에 역할을 부여하는 것**⭐이라고 할 수 있다.

Taint를 통해 역할을 설정하고, Toleration으로 해당 수행을 가능하게 하는 것이다.

Taint란 노드에 역할을 부여한다고 해석하는 것이 쿠버네티스의 Taint의 의도를 정확히 파악한 것이라고 할 수 있다.

말그대로 Scheduling을 못하게만 하려한다면 Taint가 아닌, [Cordon](https://nayoungs.tistory.com/entry/Kubernetes-k8s-Cordon%EA%B3%BC-Drain)을 사용하면 된다.

<br>

**💻 실습** : Taint와 Toleration

먼저 node1에 다음과 같이 taint를 추가한다.

그 후, `kubectl describe` 명령으로 taint를 확인할 수 있다.

```shell
$ kubectl taint node node1 node-role.kubernetes.io/master:NoSchedule
node/node1 tainted
$ kubectl describe node node1 | grep -i taint
Taints:             node-role.kubernetes.io/master:NoSchedule
```

복제본을 3개 생성하며, 

같은 노드에 배치되지 않도록 anti-affinity가 설정된 ReplicaSet을 다음과 같이 작성한다. 

([여기](https://nayoungs.tistory.com/entry/Kubernetes-k8s-%EC%96%B4%ED%94%BC%EB%8B%88%ED%8B%B0Affinity%EC%99%80-%EC%95%88%ED%8B%B0-%EC%96%B4%ED%94%BC%EB%8B%88%ED%8B%B0Anti-Affinity)에서 사용한 예시)

`myweb-a.yaml`

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: myweb-a
spec:
  replicas: 3
  selector:
    matchLabels:
      app: a
  template:
    metadata:
      labels:
        app: a
    spec:
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 10
              preference:
                matchExpressions:
                  - key: gpu
                    operator: Exists
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                 matchLabels:
                   app: a
              topologyKey: "kubernetes.io/hostname"
      containers:
        - name: myweb
          image: ghcr.io/c1t1d0s7/go-myweb
```

```shell
$ kubectl create -f myweb-a.yaml             
replicaset.apps/myweb-a created
```

1개가 pending 상태인 것을 확인할 수 있다

```shell
$ kubectl get po -o wide
NAME                                      READY   STATUS    RESTARTS        AGE     IP              NODE     NOMINATED NODE   READINESS GATES
myweb-a-gcwd2                             0/1     Pending   0               32s     <none>          <none>   <none>           <none>
myweb-a-lz5bj                             1/1     Running   0               32s     10.233.92.192   node3    <none>           <none>
myweb-a-z6ksb                             1/1     Running   0               32s     10.233.96.44    node2    <none>           <none>
```

podAntiAffinity로 인해, 3개가 각각 다른 노드에 배치되어야하는데,

node1에 taint 설정이 되어있어서 파드가 배치될 수 없고, 따라서 pending 상태가 된 것이다.

<br>
pending 상태의 파드를 `kubectl describe` 명령을 통해 Events를 확인해보면,

1개의 노드는 taint 때문에 배치가 불가능하고, 2개의 노드는 anti-affinity 때문에 배치가 불가능하며,

toleration이 없다는 설명을 볼 수 있다.

```shell
Events:
  Type     Reason            Age               From               Message
  ----     ------            ----              ----               -------
  Warning  FailedScheduling  2s (x2 over 77s)  default-scheduler  0/3 nodes are available: 1 node(s) didn't match pod anti-affinity rules, 1 node(s) had taint {node-role.kubernetes.io/master: }, that the pod didn't tolerate, 1 node(s) were unschedulable.
```

이제 toleration 설정을 해보자.

먼저 ReplicaSet을 delete하고, 

```shell
$ kubectl delete -f myweb-a.yaml
```

ReplicaSets의 yaml 파일에 다음과 같이 node1에 파드를 배치할 수 있도록 toleration을 추가한다.

```yaml
tolerations:
        - key: node-role.kubernetes.io/master
          operator: Exists
          effect: NoSchedule
```

`myweb-a.yaml`

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: myweb-a
spec:
  replicas: 3
  selector:
    matchLabels:
      app: a
  template:
    metadata:
      labels:
        app: a
    spec:
      tolerations:
        - key: node-role.kubernetes.io/master
          operator: Exists
          effect: NoSchedule
      affinity:
        nodeAffinity:
          preferredDuringSchedulingIgnoredDuringExecution:
            - weight: 10
              preference:
                matchExpressions:
                  - key: gpu
                    operator: Exists
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                 matchLabels:
                   app: a
              topologyKey: "kubernetes.io/hostname"
      containers:
        - name: myweb
          image: ghcr.io/c1t1d0s7/go-myweb
```

```shell
$ kubectl creat -f myweb-a.yaml
```

실행 후 확인해보면, node1에도 파드가 배치되어있는 것을 확인할 수 있다.

```shell
$ kubectl get po -o wide        
NAME                                      READY   STATUS    RESTARTS       AGE     IP              NODE    NOMINATED NODE   READINESS GATES
myweb-a-c7qs8                             1/1     Running   0              5s      10.233.92.191   node3   <none>           <none>
myweb-a-dtbm9                             1/1     Running   0              5s      10.233.90.1     node1   <none>           <none>
myweb-a-gfkh4                             1/1     Running   0              5s      10.233.96.47    node2   <none>           <none>
```

<br>

**☁️ 참고**

ControlPlane은 일반적으로 다음과 같은 Taint가 설정되어있다. (Worker X)

`node-role.kubernetes.io/master:NoSchedule`

ControlPlane에는 해당 toleration이 없으면 파드가 배치되지 않고, 

결론적으로, ControlPlane에 스케쥴링되지 않는이유는 Taint 때문이었다.

<br>

<br>

<br>
참고

https://gruuuuu.github.io/cloud/k8s-taint-toleration/
