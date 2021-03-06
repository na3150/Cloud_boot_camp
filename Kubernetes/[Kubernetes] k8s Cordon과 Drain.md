# [Kubernetes] k8s Cordon๊ณผ Drain

<br>

### ๐Index

- [Cordon](#cordon)
- [Drain](#drain)

<br>

<br>

## Cordon

Cordon์ ์ง์ ๋ ๋ธ๋์ ๋์ด์ ํฌ๋๋ค์ด ์ค์ผ์ฅด๋ง ๋์ง ์๋๋ก ํ๋ค.

<br>

**Cordon ์ค์ ํ๊ธฐ** : Scheduling ๊ธ์งํ๊ธฐ

```shell
$ kubectl cordon <NODENAME>
```

ํด๋น ๋ธ๋์ ์ด๋ฏธ ์กด์ฌํ๋ ๊ฒ๋ค์ ๊ด๊ณ์๋ค.

**์๋กญ๊ฒ ์์ฑ๋๋ ํ๋๋ค์ ๋ ์ด์ ํด๋น ๋ธ๋์ ๋ฐฐ์น๋์ง ์๋๋ค.**

<br>

**Cordon  ํด์ **

```shell
$ kubectl uncordon <NODENAME>
```

<br>

<br>

**๐ป ์ค์ต**

ํ์ฌ ๋ธ๋๋ค์ ์ํ๋ ๋ค์๊ณผ ๊ฐ๊ณ ,

```shell
$ kubectl get nodes             
NAME    STATUS   ROLES                  AGE    VERSION
node1   Ready    control-plane,master   9d     v1.22.8
node2   Ready    <none>                 9d     v1.22.8
node3   Ready    <none>                 7d1h   v1.22.8
```

node2๋ฅผ cordon ํด๋ณด์.

```shell
$ kubectl cordon node2          
node/node2 cordoned                <none>                 7d1h   v1.22.8
```

node2๊ฐ `SchedulingDisabled` ์ํ๊ฐ ๋ ๊ฒ์ ํ์ธํ  ์ ์๋ค.

```shell
$ kubectl get nodes   
NAME    STATUS                     ROLES                  AGE    VERSION
node1   Ready                      control-plane,master   9d     v1.22.8
node2   Ready,SchedulingDisabled   <none>                 9d     v1.22.8
node3   Ready      
```

<br>

๋ค์๊ณผ ๊ฐ์ด ๋ณต์ ๋ณธ 2๊ฐ๋ฅผ ์์ฑํ๋ ReplicaSets์ ์์ฑํ๋ค.

podAntiAffinity ์ค์ ์ผ๋ก, ๋ณต์ ๋ณธ์ด ๊ฐ์ ๋ธ๋์ ๋ฐฐ์น๋  ์ ์๋๋ก ๊ตฌ์ฑํ์๋ค.

affinity์ ๋ํ ์์ธํ ์ค๋ช์  [affinity์ anti-affinity](https://nayoungs.tistory.com/entry/Kubernetes-k8s-%EC%96%B4%ED%94%BC%EB%8B%88%ED%8B%B0Affinity%EC%99%80-%EC%95%88%ED%8B%B0-%EC%96%B4%ED%94%BC%EB%8B%88%ED%8B%B0Anti-Affinity)์์ ํ์ธํ  ์ ์๋ค.

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

node2๊ฐ ๊ธ์ง(Cordon)๋์๊ธฐ ๋๋ฌธ์ node1,3์ ๋ฐฐ์น๋  ์ ๋ฐ์ ์๊ณ ,  

์ต์ข์ ์ผ๋ก node1,3์ ๋ฐฐ์น๋ ๊ฒ์ ํ์ธํ  ์ ์๋ค.

```shell
$ kubectl get po -o wide        
NAME                                      READY   STATUS    RESTARTS        AGE   IP              NODE    NOMINATED NODE   READINESS GATES
myweb-a-7ll7d                             1/1     Running   0               12s   10.233.92.176   node3   <none>           <none>
myweb-a-kpq68                             1/1     Running   0               12s   10.233.90.241   node1   <none>           <none>
```

์ด ์ํ์์ ์ค์ผ์ผ๋ง์ ํตํด replicas๋ฅผ 3์ผ๋ก ๋ณ๊ฒฝํด๋ณด์.

```shell
$ kubectl scale rs myweb-a --replicas=3
```

2๋ฒ์ ๊ธ์ง๋์๊ณ , 1,3๋ฒ์ ์ํฐ์ดํผ๋ํฐ ๋๋ฌธ์ ๋ฐฐ์น๋  ์ ์์ด Pending ์ํ๊ฐ ์ง์๋๋ค.

```shell
$ kubectl get po -o wide               
NAME                                      READY   STATUS              RESTARTS        AGE     IP              NODE     NOMINATED NODE   READINESS GATES
myweb-a-7ll7d                             1/1     Running             0               2m30s   10.233.92.176   node3    <none>           <none>
myweb-a-dhdnd                             0/1     Pending             0               3s      <none>          <none>   <none>           <none>
myweb-a-kpq68                             1/1     Running             0               2m30s   10.233.90.241   node1    <none>           <none>
```

ํ๋์ Events๋ฅผ ์ดํด๋ณด๋ฉด 1๊ฐ๋ ์ค์ผ์ฅด๋ง์ด ์๋๊ณ , 2๊ฐ๋ anti-affinity ๋๋ฌธ์ ๋ฐฐ์น๊ฐ ์๋๋ค๋ ์ค๋ช์ ํ์ธํ  ์ ์๋ค.

```shell
Events:
  Type     Reason            Age                  From               Message
  ----     ------            ----                 ----               -------
  Warning  FailedScheduling  12m                  default-scheduler  0/3 nodes are available: 1 node(s) were unschedulable, 2 node(s) didn't match pod anti-affinity rules.
```

Cordon์ ํด์ ํ๊ณ  ๋ค์ ํ์ธํ๋ฉด,

```shell
$ kubectl uncordon node2
node/node2 uncordoned
```

ํ๋๊ฐ ๋ค์ ์์ฑ๋์ด, node2์ ๋ฐฐ์น๋ ๊ฒ์ ํ์ธํ  ์ ์๋ค.

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

Drain์ **๊ธฐ์กด ํ๋๋ฅผ ์ ๊ฑฐํ๋ ์ค์ ์ผ๋ก, drainํ๋ฉด ์๋์ผ๋ก uncordon**๋๊ณ , ํ๋๋ค์ ๋ธ๋์์ ์ซ์๋ธ๋ค.

๋ณต์ ๋ณธ์ ์ ๊ณตํ๋ ๊ฒ(RS, Deployment ๋ฑ)์ ์ญ์ ๋์ด๋ ๋ค๋ฅธ ๊ณณ์ ๋ค์ ๋ง๋ค์ด์ง๊ธฐ ๋๋ฌธ์  ํฌ๊ฒ ์๊ด์์ผ๋, 

**๋ฐ๋ชฌ์, ํ๋์ ๊ฐ์ ๊ฒฝ์ฐ๋ ๋ธ๋์์ ์ซ๊ฒจ๋๋ฉด ๊ฐ ๊ณณ์ด ์๋ ๊ฒ์ด๊ธฐ ๋๋ฌธ์ ์์ ์ญ์ ๋๋ค.** (์์ด์ง๋ ๊ฒ์ด๋ค)

<br>

๋ค์๊ณผ ๊ฐ์ด node2์ drain์ ์๋ํ๋ฉด ์๋ฌ๊ฐ ๋ฐ์ํ๋ค.

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

node2์ ๋ฐ๋ชฌ์์ ์ํด ๊ด๋ฆฌ๋๋ ํ๋๋ค์ด ์กด์ฌํ๊ธฐ ๋๋ฌธ์ด๋ค.

<br>

์๋ฌ๋ฅผ ๋ฌด์ํ๊ณ  Drainํ๋ ค๋ฉด `--ignore-daemonsets` ์ต์์ ์ฌ์ฉํ๋ฉด ๋๋ค.

```shell
$ kubectl drain node2 --ignore-daemonsets
```

drainํ๊ฒ๋๋ฉด, ์๋์ ์ผ๋ก Cordon ์ํ๊ฐ ๋๊ณ ,

์ฌ๋ถํํด๋ Cordon ์ํ ์ด๊ธฐ ๋๋ฌธ์ **drain ํ ๋ฐ๋์ uncordon ํด์ค์ผํ๋ค.**

<br>
์ฌ์ฉ ์์

- ํจ์น
- ์ปค๋ ์๋ฐ์ดํธ

<br>

<br>