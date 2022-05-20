# [kubernetes] Controller: DaemonSets

[데몬셋](https://kubernetes.io/ko/docs/concepts/workloads/controllers/daemonset/)은 모든 노드의 파드를 실행하도록 하며, `daemonset`(DS)은 일반적으로 `systemctl`에서 제어하는 모는 것을 의미한다.

(스케쥴러를 조정하면, 일부로 조절 가능하긴하다)

데몬셋는 반드시 **하나의 노드에 하나씩 존재하기 때문에, 각각의 노드에 분산되는 것을 보장**한다. 

따라서 노드가 클러스터에 추가되면 파드도 추가되고, 노드가 클러스터에서 제거되면 가비지(garbage)로 수집된다.

반면에, 예로 ReplicaSets은 각각의 노드에 배치되는 것이 가장 고가용성을 구축하는 방법임에도,

`sched`은 스케쥴러에 의해 제어되기 때문에 노드에 분산되는 것을 보장할 수 없으며, 어느 노드에 파드가 배치될지 알 수없다.

<br>

데몬셋의 대표적인 용도는 다음과 같다.

- 모든 노드에서 클러스터 스토리지 데몬 실행
- 모든 노드에서 로그 수집 데몬 실행
- 모든 노드에서 노드 모니터링 데몬 실행

<br>

데몬셋 목록 확인하기

```shell
$ kubectl get ds -n kube-system
NAME           DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
calico-node    3         3         3       3            3           kubernetes.io/os=linux   2d9h
kube-proxy     3         3         3       3            3           kubernetes.io/os=linux   2d9h
nodelocaldns   3         3         3       3            3           kubernetes.io/os=linux   2d9h
```

- 현재 노드가 3개 있어서 `kube-proxy`도 3개가 존재한다. `kube-proxy`는 네트워크 정책을 담당한다.

- `nodelocaldns`는 `dns` 서버이다.

- `calico-node`는 실제 네트워크 구현체이다.

<br>

<br>

`daemonsets`는 `apps`그룹에 속한다.

```shell
$ kubectl api-resources | grep daemonsets                 
daemonsets                        ds           apps/v1                                true         DaemonSet
```

<br>

##### Selector

`matchExpression`가 파드의 `label`과 `AND`연산으로 매칭이 되어야한다

```shell
kubectl explain ds.spec.selector       
KIND:     DaemonSet
VERSION:  apps/v1

RESOURCE: selector <Object>

DESCRIPTION:
     A label query over pods that are managed by the daemon set. Must match in
     order to be controlled. It must match the pod template's labels. More info:
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

metadata의 labels는 matchLabels와는 맞춰줘야하는 것이 맞고, 

controller의 label은 사실 metadata의 label과는 관련이 없지만, 

다음과 같이 **Controller의 label과 metadata의 label을 일치하게 설정해주는 것이 관습**이다.

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata: 
  name: myweb-ds
  labels:
  	app: myweb
  	env: env
spec:
  selector:
    matchLabels:
    	app: myweb
    	env: dev
  template:
    metadata:
      labels:
        app: myweb
        env: dev
    spec:
      containers:
        - name: myweb
          image: ghcr.io/c1t1d0s7/go-myweb
          ports:
            - containerPort: 8080
              protocol: TCP             
```

<br>

**💻 실습 1** : 노드의 분배 확인

`myweb-ds.yaml`

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata: 
  name: myweb-ds
spec:
  selector:
    matchExpressions:
      - key: app
        operator: In
        values: 
          - myweb
      - key: env
        operator: Exists
  template:
    metadata:
      labels:
        app: myweb
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
$ kubedctl create -f myweb-ds.yaml
```

```shell
$ kubectl get ds                 
NAME       DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
myweb-ds   3         3         3       3            3           <none>          22s
```

DS가 각 노드에 분포되어있는 것을 확인할 수 있다.

```shell
$ kubectl get pods -o wide      
NAME             READY   STATUS    RESTARTS   AGE   IP             NODE    NOMINATED NODE   READINESS GATES
myweb-ds-64l84   1/1     Running   0          37s   10.233.92.49   node3   <none>           <none>
myweb-ds-gqz4b   1/1     Running   0          37s   10.233.96.42   node2   <none>           <none>
myweb-ds-xtkbw   1/1     Running   0          37s   10.233.90.39   node1   <none>           <none>
```

다시 한번 언급하지만, DS는 무조건 각 노드마다 하나씩 존재한다. 

<br>

**💻 실습 2** : kubespray를 이용한 노드의 제거

[Readme (kubespray.io) : Removing Node](https://kubespray.io/#/docs/getting-started?id=remove-nodes)

Removing Node 형식

```shell
$ ansible-playbook -i inventory/mycluster/hosts.yml remove-node.yml -b -v \
--private-key=~/.ssh/private_key \
--extra-vars "node=nodename,nodename2"
```

- `default key`를 사용하기 때문에, 여기서는 별도로 키를 지정하지 않는다

- `--extra-vars`를 통해 변수에 값을 할당하여 인벤토리의 제거할 노드를 지정한다. 

- `reset` : 쿠버네티스에 설치된 구성 요소까지 함께 제거하는 것으로,` --extra-vars reset_nodes=false` 로 지정하면 `reset`을 건너뛸 수 있다. default는 false 이나 기본적으로 reset 해주는 것이 좋다.

<br>

`kubespray`를 이용하여 `node3`를 제거해보자. 현재는 `node1`, `node2`, `node3`가 있는 상태이다.

```shell
$ pwd         
/home/vagrant/kubespray
$ ansible-playbook -i inventory/mycluster/inventory.ini remove-node.yml -b --extra-vars="node=node3" --extra-vars reset_nodes=true
```

3개에서 2개로 감소한 것을 확인할 수 있다.

```shell
 kubectl get ds                               k8s-node1: Thu May 19 01:22:41 2022

NAME       DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
myweb-ds   2         2         2       2            2           <none>          6m42s
$ kubectl get nodes       
NAME    STATUS   ROLES                  AGE     VERSION
node1   Ready    control-plane,master   2d10h   v1.22.8
node2   Ready    <none>                 2d10h   v1.22.8
```

단, `vm`이 종료된 것은 아니다

<br>

**💻 실습 3** : kubespray를 이용한 노드의 추가

이번에는 노드를 추가해보자

```shell
$ pwd         
/home/vagrant/kubespray
$ ansible-playbook -i inventory/mycluster/inventory.ini scale.yml -b                               
```

명령 실행 후 노드가 2개에서 3개로 1개 늘어난 것을 확인할 수 있다.

```shell
 kubectl get ds                               k8s-node1: Thu May 19 01:38:43 2022

NAME       DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR   AGE
myweb-ds   3         3         3       3            3           <none>          22m
$ kubectl get nodes         
NAME    STATUS   ROLES                  AGE     VERSION
node1   Ready    control-plane,master   2d12h   v1.22.8
node2   Ready    <none>                 2d12h   v1.22.8
node3   Ready    <none>                 116m    v1.22.8
```

<br>

**💻 실습 4** : 파드 제거하기

3개의 파드 중 1개의 파드를 지정하여 삭제해보자

```shell
$ kubectl get po                                       
NAME                         READY   STATUS              RESTARTS   AGE
myweb-ds-4bqj8               1/1     Running             0          7s
myweb-ds-6nqc6               1/1     Running             0          7s
myweb-ds-9trzj               1/1     Running             0          7s
$ kubectl delete pods myweb-ds-9trzj          
pod "myweb-ds-9trzj" deleted
```

파드가 지워지면 데몬셋 컨트롤러는새로운 파드를 만들게된다.

```shell
$ kubectl get po
NAME                         READY   STATUS             RESTARTS   AGE
myweb-ds-629ff               0/1     ContainerCreating  0          57s
myweb-ds-629ff               1/1     Running            0          8s
myweb-ds-6nqc6               1/1     Running            0          57s
```

<br>





