# [Kubernetes] k8s Cordon과 Drain

<br>

### 📌Index

- [Cordon](#cordon)
- [Drain](#drain)

<br>

<br>

## Cordon

Cordon은 지정된 노드에 더이상 포드들이 스케쥴링 되지 않도록 한다.

<br>

**Cordon 설정하기** : Scheduling 금지하기

```shell
$ kubectl cordon <NODENAME>
```

해당 노드에 이미 존재하는 것들은 관계없다.

**새롭게 생성되는 파드들은 더 이상 해당 노드에 배치되지 않는다.**

<br>

**Cordon  해제**

```shell
$ kubectl uncordon <NODENAME>
```

<br>

<br>

**💻 실습**

현재 노드들의 상태는 다음과 같고,

```shell
$ kubectl get nodes             
NAME    STATUS   ROLES                  AGE    VERSION
node1   Ready    control-plane,master   9d     v1.22.8
node2   Ready    <none>                 9d     v1.22.8
node3   Ready    <none>                 7d1h   v1.22.8
```

node2를 cordon 해보자.

```shell
$ kubectl cordon node2          
node/node2 cordoned                <none>                 7d1h   v1.22.8
```

node2가 `SchedulingDisabled` 상태가 된 것을 확인할 수 있다.

```shell
$ kubectl get nodes   
NAME    STATUS                     ROLES                  AGE    VERSION
node1   Ready                      control-plane,master   9d     v1.22.8
node2   Ready,SchedulingDisabled   <none>                 9d     v1.22.8
node3   Ready      
```

<br>

다음과 같이 복제본 2개를 생성하는 ReplicaSets을 작성한다.

podAntiAffinity 설정으로, 복제본이 같은 노드에 배치될 수 없도록 구성하였다.

affinity에 대한 자세한 설명은  [affinity와 anti-affinity](https://nayoungs.tistory.com/entry/Kubernetes-k8s-%EC%96%B4%ED%94%BC%EB%8B%88%ED%8B%B0Affinity%EC%99%80-%EC%95%88%ED%8B%B0-%EC%96%B4%ED%94%BC%EB%8B%88%ED%8B%B0Anti-Affinity)에서 확인할 수 있다.

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
          image: ghcr.io/c1t1d0s7/go-mywe
```

```shell
$ kubectl create -f myweb-a.yaml
replicaset.apps/myweb-a created
```

node2가 금지(Cordon)되었기 때문에 node1,3에 배치될 수 밖에 없고,  

최종적으로 node1,3에 배치된 것을 확인할 수 있다.

```shell
$ kubectl get po -o wide        
NAME                                      READY   STATUS    RESTARTS        AGE   IP              NODE    NOMINATED NODE   READINESS GATES
myweb-a-7ll7d                             1/1     Running   0               12s   10.233.92.176   node3   <none>           <none>
myweb-a-kpq68                             1/1     Running   0               12s   10.233.90.241   node1   <none>           <none>
```

이 상태에서 스케일링을 통해 replicas를 3으로 변경해보자.

```shell
$ kubectl scale rs myweb-a --replicas=3
```

2번은 금지되었고, 1,3번은 안티어피니티 때문에 배치될 수 없어 Pending 상태가 지속된다.

```shell
$ kubectl get po -o wide               
NAME                                      READY   STATUS              RESTARTS        AGE     IP              NODE     NOMINATED NODE   READINESS GATES
myweb-a-7ll7d                             1/1     Running             0               2m30s   10.233.92.176   node3    <none>           <none>
myweb-a-dhdnd                             0/1     Pending             0               3s      <none>          <none>   <none>           <none>
myweb-a-kpq68                             1/1     Running             0               2m30s   10.233.90.241   node1    <none>           <none>
```

파드의 Events를 살펴보면 1개는 스케쥴링이 안되고, 2개는 anti-affinity 때문에 배치가 안된다는 설명을 확인할 수 있다.

```shell
Events:
  Type     Reason            Age                  From               Message
  ----     ------            ----                 ----               -------
  Warning  FailedScheduling  12m                  default-scheduler  0/3 nodes are available: 1 node(s) were unschedulable, 2 node(s) didn't match pod anti-affinity rules.
```

Cordon을 해제하고 다시 확인하면,

```shell
$ kubectl uncordon node2
node/node2 uncordoned
```

파드가 다시 생성되어, node2에 배치된 것을 확인할 수 있다.

```shell
$ kubectl get po -o wide               
NAME                                      READY   STATUS              RESTARTS        AGE     IP              NODE     NOMINATED NODE   READINESS GATES
myweb-a-7ll7d                             1/1     Running             0               2m30s   10.233.92.176   node3    <none>           <none>
myweb-a-dhdnd                             0/1     Running             0               3s      10.233.92.185   node2    <none>           <none>
myweb-a-kpq68                             1/1     Running             0               2m30s   10.233.90.241   node1    <none>           <none>
```

<br>

<br>

## Drain

Drain은 **기존 파드를 제거하는 설정으로, drain하면 자동으로 uncordon**되고, 파드들을 노드에서 쫓아낸다.

복제본을 제공하는 것(RS, Deployment 등)은 삭제되어도 다른 곳에 다시 만들어지기 때문에  크게 상관없으나, 

**데몬셋, 파드와 같은 경우는 노드에서 쫓겨나면 갈 곳이 없는 것이기 때문에 아예 삭제된다.** (없어지는 것이다)

<br>

다음과 같이 node2에 drain을 시도하면 에러가 발생한다.

```shell
$ kubectl drain node2
node/node2 cordoned
DEPRECATED WARNING: Aborting the drain command in a list of nodes will be deprecated in v1.23.
The new behavior will make the drain command go through all nodes even if one or more nodes failed during the drain.
For now, users can try such experience via: --ignore-errors
error: unable to drain node "node2", aborting command...

There are pending nodes to be drained:
 node2
cannot delete Pods not managed by ReplicationController, ReplicaSet, Job, DaemonSet or StatefulSet (use --force to override): dev/myweb, dev/myweb-label
cannot delete DaemonSet-managed Pods (use --ignore-daemonsets to ignore): ingress-nginx/ingress-nginx-controller-xbj69, kube-system/calico-node-9mxkg, kube-system/kube-proxy-cbzbn, kube-system/nodelocaldns-g74tc, metallb-system/speaker-vzw82
```

node2에 데몬셋에 의해 관리되는 파드들이 존재하기 때문이다.

<br>

에러를 무시하고 Drain하려면 `--ignore-daemonsets` 옵션을 사용하면 된다.

```shell
$ kubectl drain node2 --ignore-daemonsets
```

drain하게되면, 자동적으로 Cordon 상태가 되고,

재부팅해도 Cordon 상태 이기 때문에 **drain 후 반드시 uncordon 해줘야한다.**

<br>
사용 예시

- 패치
- 커널 업데이트

<br>

<br>