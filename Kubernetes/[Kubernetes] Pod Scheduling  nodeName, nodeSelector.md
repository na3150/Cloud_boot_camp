# [Kubernetes] Pod Scheduling : nodeName, nodeSelector

<br>

### πIndex

- [nodeName](#nodename)
- [nodeScheduler](#nodescheduler)

<br>

<br>

## nodeName

[nodeName](https://kubernetes.io/ko/docs/concepts/scheduling-eviction/assign-pod-node/#nodename)μ μ€μ νλ©΄, μ€μΌμ₯΄λ¬μ μν₯μ λ°μ§ μκ³  

μ¬μ©μκ° μνλ λΈλμ κ°μ λ‘ λ°°μΉμν¬ μ μλ€.

nodeNameμ μ€μ νμ§ μμΌλ©΄ μ€μΌμ₯΄λ¬μ μν΄ λΈλμ λ°°μΉλλ€.

<br>

κ·Έλ¬λ nodeNameμ λͺκ°μ§ μ ν μ¬ν­μΌλ‘ μΈν΄ λλλ‘μ΄λ©΄ μ¬μ©νμ§ μλ κ²μ κΆμ₯νλ€.

`nodeName` μ μ¬μ©ν΄μ λΈλλ₯Ό μ νν  λμ λͺ κ°μ§ μ νμ λ€μκ³Ό κ°λ€.

- λ§μ½ λͺλͺλ λΈλκ° μμΌλ©΄, νλκ° μ€νλμ§ μκ³  λ°λΌμ μλμΌλ‘ μ­μ λ  μ μλ€.
- λ§μ½ λͺλͺλ λΈλμ νλλ₯Ό μμ©ν  μ μλ λ¦¬μμ€κ° μλ κ²½μ° νλκ° μ€ν¨νκ³ , κ·Έ μ΄μ λ λ€μκ³Ό κ°μ΄ νμλλ€. μ: OutOfmemory λλ OutOfcpu.
- ν΄λΌμ°λ νκ²½μ λΈλ μ΄λ¦μ ν­μ μμΈ‘ κ°λ₯νκ±°λ μμ μ μΈ κ²μ μλλ€.

<br>

**λ¦¬μμ€ μ μ λ°©λ² νμΈ**

```shell
$ kubectl explain pod.spec.nodeName
KIND:     Pod
VERSION:  v1

FIELD:    nodeName <string>

DESCRIPTION:
     NodeName is a request to schedule this pod onto a specific node. If it is
     non-empty, the scheduler simply schedules this pod onto that node, assuming
     that it fits resource requirements.
```

<br>

**π» μ€μ΅** : nodeNameμΌλ‘ νΉμ  λΈλμ λ°°μΉνκΈ°

λ€μκ³Ό κ°μ΄ `nodeName: node2`λ‘ μ€μ λ ReplicaSetμ μμ±νλ€.

`myweb-rs-nn.yaml`

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: myweb-rs-nn
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      nodeName: node2
      containers:
        - name: myweb
          image: ghcr.io/c1t1d0s7/go-myweb
```

```shell
$ kubectl create -f myweb-rs-nn.yaml
```

μμ± ν, μνλ₯Ό νμΈνλ©΄ **νλκ° λͺ¨λ node2μ μμ±**λ κ²μ νμΈν  μ μλ€.

```shell
$ kubectl get po -o wide
NAME                                      READY   STATUS    RESTARTS       AGE    IP              NODE    NOMINATED NODE   READINESS GATES
myweb-rs-nn-ck9hx                         1/1     Running   0              35s    10.233.96.16    node2   <none>           <none>
myweb-rs-nn-gqkwg                         1/1     Running   0              35s    10.233.96.18    node2   <none>           <none>
myweb-rs-nn-w298z                         1/1     Running   0              35s    10.233.96.23    node2   <none>           <none>
```

κ·Έλ¬λ κ³ κ°μ©μ±μ μν΄ λ³΅μ λ³Έμ μ¬λ¬κ° κ΅¬μ±νλλΌλ,

λμΌν λΈλμ λ°°μΉκ° λλ€λ³΄λ λΈλμ μ₯μ κ° λ°μνμ μ, ν΄λΉλλ μ νλ¦¬μΌμ΄μμ΄ μ€νλ  μ μκΈ° λλ¬Έμ

μ΄λ¬ν κ²½μ°μλ nodeNameμ μ¬μ©νλ μ₯μ μ΄ μλ€.

<br>

nodeNameμ μ€μ λ‘ μΌλ°μ μΌλ‘λ μ¬μ©νμ§ μλλ€.

<br>

<br>

## nodeSelector

[nodeSelector](https://kubernetes.io/ko/docs/concepts/scheduling-eviction/assign-pod-node/#λΈλ-μλ ν°-nodeselector)λ κ°μ₯ κ°λ¨νκ³  κΆμ₯λλ **λΈλ μ ν μ μ½ μ‘°κ±΄**μ ννμ΄λ€. 

`nodeSelector` λ PodSpecμ νλλ‘, **key-value μμ λ§€νμΌλ‘ μ§μ **νλ€. 

νλκ° λΈλμμ λμν  μ μμΌλ €λ©΄, **λΈλλ ν€-κ°μ μμΌλ‘ νμλλ λ μ΄λΈμ κ°μ κ°μ§κ³  μμ΄μΌ νλ€**

(μ΄λ μΆκ° λ μ΄λΈμ κ°μ§κ³  μμ μ μλ€). 

μΌλ°μ μΌλ‘ νλμ key-value μμ΄ μ¬μ©λλ©°, λͺ¨λ  μ»¨νΈλ‘€λ¬μλ `nodeSelector`κ° μ‘΄μ¬νλ€.

<br>

**λ¦¬μμ€ μ μ λ°©λ² νμΈ**

```shell
$ kubectl explain pod.spec.nodeSelector
KIND:     Pod
VERSION:  v1

FIELD:    nodeSelector <map[string]string>

DESCRIPTION:
     NodeSelector is a selector which must be true for the pod to fit on a node.
     Selector which must match a node's labels for the pod to be scheduled on
     that node. More info:
     https://kubernetes.io/docs/concepts/configuration/assign-pod-node/
```

**λΈλμ λ μ΄λΈκ³Ό λ§€μΉ­**μν¨λ€.

<br>

#### λΈλ λ μ΄λΈ

νμ¬ κΈμ΄μ΄λ λΈλκ° μ΄ 3κ° μ‘΄μ¬νκ³ , λΈλ λ μ΄λΈμ νμΈν΄λ³΄λ©΄ λ€μκ³Ό κ°λ€.

```shell
$ kubectl get nodes --show-labels                               
```

node1 : Controlplane + worker

```yaml
beta.kubernetes.io/arch=amd64
beta.kubernetes.io/os=linux
kubernetes.io/arch=amd64
kubernetes.io/hostname=node1
kubernetes.io/os=linux
node-role.kubernetes.io/control-plane=                         #controlplaneλ§ μ‘΄μ¬
node-role.kubernetes.io/master=                                #controlplaneλ§ μ‘΄μ¬
node.kubernetes.io/exclude-from-external-load-balancers=       #controlplaneλ§ μ‘΄μ¬
```

node2 : worker

```yaml
beta.kubernetes.io/arch=amd64
beta.kubernetes.io/os=linux
kubernetes.io/arch=amd64
kubernetes.io/hostname=node2
kubernetes.io/os=linux
```

node3 : worker

```yaml
beta.kubernetes.io/arch=amd64
beta.kubernetes.io/os=linux
kubernetes.io/arch=amd64
kubernetes.io/hostname=node3
kubernetes.io/os=linux
```

<br>

<br>

**π» μ€μ΅**

λͺλ Ήν μ»€λ§¨λλ‘ λ€μκ³Ό κ°μ΄ λΈλμ λ μ΄λΈμ μ€μ νλ€.

```shell
$ kubectl label node node1 gpu=highend 
node/node1 labeled
$ kubectl label node node2 gpu=midrange
node/node2 labeled
$ kubectl label node node3 gpu=lowend  
node/node3 labeled                6d23h   v1.22.8   lowend
```

`-L` μ΅μμ μ¬μ©νλ©΄, μ§μ ν keyκ° νλλ‘ λ³΄μΈλ€.

```shell
$ $ kubectl get nodes -L gpu           
NAME    STATUS   ROLES                  AGE     VERSION   GPU
node1   Ready    control-plane,master   9d      v1.22.8   highend
node2   Ready    <none>                 9d      v1.22.8   midrange
node3   Ready    <none>                 9d      v1.22.8   lowend
```

`nodeSelector`κ° `gpu: lowend`λ‘ μ€μ λ ReplicaSetsμ λ€μκ³Ό κ°μ΄ μμ±νλ€.

`myweb-rs-ns.yaml`

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: myweb-rs-ns
spec:
  replicas: 3
  selector:
    matchLabels:
      app: web
  template:
    metadata:
      labels:
        app: web
    spec:
      nodeSelector:
        gpu: lowend
      containers:
        - name: myweb
          image: ghcr.io/c1t1d0s7/go-myweb
```

```shell
$ kubectl create -f myweb-rs-ns.yaml
```

λͺ¨λ λ μ΄λΈμ΄ `gpu: lowend`μΈ node3μ μμ±λλ κ²μ νμΈν  μ μλ€.

```shell
$ kubectl get po -o wide
NAME                                      READY   STATUS    RESTARTS       AGE     IP              NODE    NOMINATED NODE   READINESS GATES
myweb-rs-ns-2zv7d                         1/1     Running   0              40s     10.233.92.170   node3   <none>           <none>
myweb-rs-ns-ngcxs                         1/1     Running   0              40s     10.233.92.166   node3   <none>           <none>
myweb-rs-ns-sz26z                         1/1     Running   0              40s     10.233.92.171   node3   <none>           <none>
```

node2μ λ μ΄λΈμ ` gpu=lowend`λ‘ μμ νκ³ , `app=web`λ μ΄λΈμ κ°μ§ νλλ€μ μ­μ νλ©΄,

ReplicaSetμ μν΄ νλλ€μ΄ μλ‘ μμ±λκ³ ,  node2,3μ κ±Έμ³μ μμ±λλ κ²μ νμΈν  μ μλ€.

```shell
$ kubectl label node node2 gpu=lowend --overwrite 
node/node2 labeled
$ kubectl delete po -l app=web     
pod "myweb-rs-ns-2zv7d" deleted
pod "myweb-rs-ns-ngcxs" deleted
pod "myweb-rs-ns-sz26z" deleted
$ kubectl get pod -o wide         
NAME                                      READY   STATUS    RESTARTS       AGE   IP              NODE    NOMINATED NODE   READINESS GATES
myweb-rs-ns-bbltv                         1/1     Running   0              13s   10.233.96.22    node2   <none>           <none>
myweb-rs-ns-dxmx5                         1/1     Running   0              13s   10.233.92.169   node3   <none>           <none>
myweb-rs-ns-z8j9s                         1/1     Running   0              12s   10.233.92.173   node3   <none>           <none>
```

<br>

<br>