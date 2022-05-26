# [Kubernetes] k8s 어피니티(Affinity)와 안티-어피니티(Anti-Affinity)

[어피니티(Affinity)](https://kubernetes.io/ko/docs/concepts/scheduling-eviction/assign-pod-node/#어피니티-affinity-와-안티-어피니티-anti-affinity)란, 개념적으로 [nodeSelector](https://nayoungs.tistory.com/entry/Kubernetes-Pod-Scheduling-nodeName-nodeSelector)와 유사한 것으로, 

노드의 **레이블을 기반으로 파드를 스케줄할 수 있는 노드를 제한**할 수 있다.

<br>

<img src="https://blog.kakaocdn.net/dn/dV3SPu/btrrh4QdUEF/EAE3vtbr0XBcJPrIBRqB8k/img.png" alt="img" style="zoom:67%;" />

출처: https://kimjingo.tistory.com/145

<br>

#### Affinity 종류와 대상

Node 

- nodeAffinity

Pod

- podAffinity
- podAntiAffinity

<br>

#### Node Affinity

`pod.spec.affinity.nodeAffinity`

Node Affinity는 **Node 레이블을 기준으로 새로운 Pod가 특정 Worker Node로 배포되도록 스케쥴링**한다. 

<br>

|                                                    |                                                              |
| -------------------------------------------------- | ------------------------------------------------------------ |
| `preferredDuringSchedulingIgnoredDuringExecution ` | Pod를 조건에 따라 노드에 배포하려고 **시도는 하지만 보증할 수 없다**는 것을 의미한다. (Soft) |
| `requiredDuringSchedulingIgnoredDuringExecution `  | Pod가 노드에 스케줄 되도록 **반드시 규칙을 만족**해야 하는 것을 의미한다. (Hard) |

- `preferredDuringSchedulingIgnoredDuringExecution` 
  - `preference`
  - `weight` : 1-100사이의 가중치를 부여한다.
- `requiredDuringSchedulingIgnoredDuringExecution` 
  - `nodeSelectorTerms`
    - `matchExpressions`
      - `operater` :  `In`, `NotIn`, `Exists`, `DoesNotExist`
    - `matchFeilds`

<br>

`nodeSelector` 와 `nodeAffinity` 를 모두 지정한다면, 

파드가 후보 노드에 스케줄되기 위해서는 *둘 다* 반드시 만족해야 한다.

<br>

<br>

#### Pod Affinity

`pod.spec.affinity.podAffinity`

`pod.spec.affinity.podAntiAffinity`

기존에 **실행 중인 Pod를 참고하여 새로운 Pod가 Worker Node로 배포되도록 Scheduling**한다.

<br>

동일한 Pod가 **같은 Worker Node**에서 실행되어야한다면 **Pod Affinity**를 사용하고,
동일한 Pod가 **다른 Worker Node**에서 실행되어야한다면 **Pod AntiAffinity**를 사용해야한다.

<br>

|                                                    |                                                              |
| -------------------------------------------------- | ------------------------------------------------------------ |
| `preferredDuringSchedulingIgnoredDuringExecution ` | Pod를 조건에 따라 노드에 배포하려고 **시도는 하지만 보증할 수 없다**는 것을 의미한다. (Soft) |
| `requiredDuringSchedulingIgnoredDuringExecution `  | Pod가 노드에 스케줄 되도록 **반드시 규칙을 만족**해야 하는 것을 의미한다. (Hard) |

`preferredDuringSchedulingIgnoredDuringExecution `  

- `podAffinityTerm`
  - `labelSelector` : 레이블을 매칭한다.

  - `namespaceSelector` : 네임스페이스를 매칭한다.

  - `namespaces` : 네임스페이스를 매칭한다.

  - `topologyKey` :  노드의 레이블을 참조
    - 키를 기준으로 같은 노드에 구성(co-located) 또는 분리(not co-located)

    - 노드 어피니티에는 없는 필드로, 파드의 어피니티, 안티어피니에만 존재한다.
- `weight` : 1~100 사이의 가중치를 부여한다.

`requiredDuringSchedulingIgnoredDuringExecution `   

- `labelSelector`
- `namespaceSelector` 

- `namespaces`

- `topologyKey` (required)

<br>

노드와는 다르게 파드는 네임스페이스이기 때문에, 

파드 레이블위의 레이블 셀렉터는 **반드시 셀렉터가 적용될 네임스페이스를 지정해야 한다**.

<br>

**자주 사용되는 시나리오**

같은 컨트롤러로 만들어진 파드는 서로 anti-affinity 설정하여 같은 노드에 배치되지 못하도록하고,

Web과 DB는 affinity로 설정하여, 같은 노드에 배치되도록한다.

<br>

<br>

**💻 실습** : Affinity 실습

현재 node1, node2, node3에 gpu 레이블이 설정된 상태이다.

```shell
$ kubectl get nodes -L gpu        
NAME    STATUS                     ROLES                  AGE     VERSION   GPU
node1   Ready                      control-plane,master   9d      v1.22.8   highend
node2   Ready,SchedulingDisabled   <none>                 9d      v1.22.8   lowend
node3   Ready                      <none>                 7d10h   v1.22.8   lowend
```

다음과 같이 gpu key를 가진 node에 배치되도록 설정하는 nodeAffinity와

자기 자신을 배척하기 위한 podAntiAffinity가 설정된 ReplicaSet을 작성한다.

`myweb-a.yaml`

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: myweb-a
spec:
  replicas: 2
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
            - weight: 10 #가중치는 여러개 있을 때 의미가 있어진다.
              preference:
                matchExpressions:
                  - key: gpu
                    operator: Exists
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                 matchLabels:
                   app: a #자기 자신을 배척
              topologyKey: "kubernetes.io/hostname" #호스트명을 기준으로 분리
      containers:
        - name: myweb
          image: ghcr.io/c1t1d0s7/go-myweb
```

마찬가지로 자신을 배척하고, gpu 키를 가진 노드에 배치되도록하며,

`app:a` 레이블을 가진 파드와 같이 배치되도록하는 ReplicaSet을 다음과 같이 작성한다.

`myweb-b.yaml`

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: myweb-b
spec:
  replicas: 2
  selector:
    matchLabels:
      app: b
  template:
    metadata:
      labels:
        app: b
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
                   app: b #자기 자신을 배척
              topologyKey: "kubernetes.io/hostname"
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                 matchLabels:
                   app: a #a와 같이 배치되도록
              topologyKey: "kubernetes.io/hostname"
      containers:
        - name: myweb
          image: ghcr.io/c1t1d0s7/go-myweb
```

`myweb-a`는 자기 자신을 배척하기 때문에 (node1,node2) 또는 (node2,node3) 또는 (node1,node3)에 배치되어야한다.

```shell
$ kubectl create -f myweb-a.yaml   
replicaset.apps/myweb-a created
```

(node2,node3)에 배치된 것을 확인할 수 있다.

```shell
$ kubectl get po -o wide        
NAME                                      READY   STATUS    RESTARTS        AGE   IP              NODE    NOMINATED NODE   READINESS GATES
myweb-a-m8s9p                             1/1     Running   0               11s   10.233.96.27    node2   <none>           <none>
myweb-a-pwxl2                             1/1     Running   0               11s   10.233.92.175   node3   <none>           <none>
```

```shell
$ kubectl create -f myweb-b.yaml
replicaset.apps/myweb-b created
```

`myweb-b`는 자기 자신을 배척하기 때문에 (node1,node2) 또는 (node2,node3) 또는 (node1,node3)에 배치되어야하고,

`app:a` 레이블의 podAffinity가 있기 때문에,

`myweb-a`가 있는 (node2, node3)에만 배치되는 것을 확인할 수 있다.

```shell
$ kubectl get po -o wide        
NAME                                      READY   STATUS    RESTARTS        AGE   IP              NODE    NOMINATED NODE   READINESS GATES
myweb-a-m8s9p                             1/1     Running   0               11s   10.233.96.27    node2   <none>           <none>
myweb-a-pwxl2                             1/1     Running   0               11s   10.233.92.175   node3   <none>           <none>
myweb-b-84ltx                             1/1     Running   0               5s    10.233.96.26    node2   <none>           <none>
myweb-b-qj89t                             1/1     Running   0               5s    10.233.92.174   node3   <none>           <none>
```

<br>

<br>

<br>

<br>

참고 

https://ikcoo.tistory.com/89

https://velog.io/@hoonki/%EC%BF%A0%EB%B2%84%EB%84%A4%ED%8B%B0%EC%8A%A4-%EB%85%B8%EB%93%9C%EC%97%90-%ED%8C%8C%EB%93%9C%EB%A5%BC-%ED%95%A0%EB%8B%B9%ED%95%98%EB%8A%94-%EB%B0%A9%EB%B2%95-nodeSelector-affinity