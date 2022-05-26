# [Kubernetes] Pod Scheduling : nodeName, nodeSelector

<br>

### 📌Index

- [nodeName](#nodename)
- [nodeScheduler](#nodescheduler)

<br>

<br>

## nodeName

[nodeName](https://kubernetes.io/ko/docs/concepts/scheduling-eviction/assign-pod-node/#nodename)을 설정하면, 스케쥴러에 영향을 받지 않고 

사용자가 원하는 노드에 강제로 배치시킬 수 있다.

nodeName을 설정하지 않으면 스케쥴러에 의해 노드에 배치된다.

<br>

그러나 nodeName은 몇가지 제한 사항으로 인해 되도록이면 사용하지 않는 것을 권장한다.

`nodeName` 을 사용해서 노드를 선택할 때의 몇 가지 제한은 다음과 같다.

- 만약 명명된 노드가 없으면, 파드가 실행되지 않고 따라서 자동으로 삭제될 수 있다.
- 만약 명명된 노드에 파드를 수용할 수 있는 리소스가 없는 경우 파드가 실패하고, 그 이유는 다음과 같이 표시된다. 예: OutOfmemory 또는 OutOfcpu.
- 클라우드 환경의 노드 이름은 항상 예측 가능하거나 안정적인 것은 아니다.

<br>

**리소스 정의 방법 확인**

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

**💻 실습** : nodeName으로 특정 노드에 배치하기

다음과 같이 `nodeName: node2`로 설정된 ReplicaSet을 작성한다.

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

생성 후, 상태를 확인하면 **파드가 모두 node2에 생성**된 것을 확인할 수 있다.

```shell
$ kubectl get po -o wide
NAME                                      READY   STATUS    RESTARTS       AGE    IP              NODE    NOMINATED NODE   READINESS GATES
myweb-rs-nn-ck9hx                         1/1     Running   0              35s    10.233.96.16    node2   <none>           <none>
myweb-rs-nn-gqkwg                         1/1     Running   0              35s    10.233.96.18    node2   <none>           <none>
myweb-rs-nn-w298z                         1/1     Running   0              35s    10.233.96.23    node2   <none>           <none>
```

그러나 고가용성을 위해 복제본을 여러개 구성하더라도,

동일한 노드에 배치가 되다보니 노드에 장애가 발생했을 시, 해당되는 애플리케이션이 실행될 수 없기 때문에

이러한 경우에는 nodeName을 사용하는 장점이 없다.

<br>

nodeName은 실제로 일반적으로는 사용하지 않는다.

<br>

<br>

## nodeSelector

[nodeSelector](https://kubernetes.io/ko/docs/concepts/scheduling-eviction/assign-pod-node/#노드-셀렉터-nodeselector)는 가장 간단하고 권장되는 **노드 선택 제약 조건**의 형태이다. 

`nodeSelector` 는 PodSpec의 필드로, **key-value 쌍의 매핑으로 지정**한다. 

파드가 노드에서 동작할 수 있으려면, **노드는 키-값의 쌍으로 표시되는 레이블을 각자 가지고 있어야 한다**

(이는 추가 레이블을 가지고 있을 수 있다). 

일반적으로 하나의 key-value 쌍이 사용되며, 모든 컨트롤러에는 `nodeSelector`가 존재한다.

<br>

**리소스 정의 방법 확인**

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

**노드의 레이블과 매칭**시킨다.

<br>

#### 노드 레이블

현재 글쓴이는 노드가 총 3개 존재하고, 노드 레이블을 확인해보면 다음과 같다.

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
node-role.kubernetes.io/control-plane=                         #controlplane만 존재
node-role.kubernetes.io/master=                                #controlplane만 존재
node.kubernetes.io/exclude-from-external-load-balancers=       #controlplane만 존재
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

**💻 실습**

명령형 커맨드로 다음과 같이 노드에 레이블을 설정한다.

```shell
$ kubectl label node node1 gpu=highend 
node/node1 labeled
$ kubectl label node node2 gpu=midrange
node/node2 labeled
$ kubectl label node node3 gpu=lowend  
node/node3 labeled                6d23h   v1.22.8   lowend
```

`-L` 옵션을 사용하면, 지정한 key가 필드로 보인다.

```shell
$ $ kubectl get nodes -L gpu           
NAME    STATUS   ROLES                  AGE     VERSION   GPU
node1   Ready    control-plane,master   9d      v1.22.8   highend
node2   Ready    <none>                 9d      v1.22.8   midrange
node3   Ready    <none>                 9d      v1.22.8   lowend
```

`nodeSelector`가 `gpu: lowend`로 설정된 ReplicaSets을 다음과 같이 작성한다.

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

모두 레이블이 `gpu: lowend`인 node3에 생성되는 것을 확인할 수 있다.

```shell
$ kubectl get po -o wide
NAME                                      READY   STATUS    RESTARTS       AGE     IP              NODE    NOMINATED NODE   READINESS GATES
myweb-rs-ns-2zv7d                         1/1     Running   0              40s     10.233.92.170   node3   <none>           <none>
myweb-rs-ns-ngcxs                         1/1     Running   0              40s     10.233.92.166   node3   <none>           <none>
myweb-rs-ns-sz26z                         1/1     Running   0              40s     10.233.92.171   node3   <none>           <none>
```

node2의 레이블을 ` gpu=lowend`로 수정하고, `app=web`레이블을 가진 파드들을 삭제하면,

ReplicaSet에 의해 파드들이 새로 생성되고,  node2,3에 걸쳐서 생성되는 것을 확인할 수 있다.

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