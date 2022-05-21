# [Kubernetes] Service : NodePort

<br>

#### ✔Service : NodePort 타입

NodePort는 **모든 워커 노드들의 특정 포트(port)를 이용하여 접근하도록 설정하는 타입**으로,

**클러스터 외부에서 접근하는 포인트**라고 할 수 있다.

NodePort 타입을 사용해도, 기본적으로 ClusterIP기반의 구성이 되는데, 

즉 **NodePort = NodePort + ClusterIP** 라고 할 수 있다. 

<br>

![img](https://blog.kakaocdn.net/dn/EIArC/btq5u3ZGQt4/SJHUeDKwJVkaEorWjWvO2k/img.png)

출처: https://kim-dragon.tistory.com/52

<br>

NodePort의 단점은 노드가 사라졌을때 자동으로 다른노드를 통해 접근이 불가능하다는 것이다.

따라서 자동으로 다른 노드에 접근을 하려면 별도의 Loadbalancer가 필요하다.

<br>

NodePort를 사용하면 포트당 하나의 서비스를 사용하며, `30000-32767`범위 내의 포트를 사용 가능하다.

이는 다음과 같이 `kube-apiserver.yaml` 파일에서 확인할 수 있다. 

```shell
$ sudo grep node-port /etc/kubernetes/manifests/kube-apiserver.yaml
    - --service-node-port-range=30000-32767
```

물론, kubespray 또는 kubeadm으로 설치할 때 해당 옵션을 통해 NodePort의 범위를 지정할 수 있다.

단, 0~1023범위 포트는 Wellknown Port(일반적으로 서비스에 사용하는 포트)이기 때문에 

포트의 충돌이 발생할 수 있으므로 사용하면 안된다.

<br>

**☁️ 참고**

포트의 범위에 대한 더 자세한 사항은 [(iana.org)](https://www.iana.org/assignments/service-names-port-numbers/service-names-port-numbers.xhtml) 에서 확인할 수 있다.

- `0~1023` : System Port(Wellknown Port)

  - 루트 권한이 필요함
  - 일반적으로 주요 서비스에 사용하는 포트

- `1024 ~ 49151` : User Port(Registered port)

  - 등록해서 사용할 수 있는 포트
  - 주요하지 않은 서비스에 사용하는 포트

  - 강제 사항은 없음

- `49152 ~ 65535` : Dynamin port(Private Port)

  - 클라이언트가 사용하는 포트

<br>

##### nodePort

- `svc.spec.ports.nodePort`

```shell
$ kubectl explain svc.spec.ports.nodePort
KIND:     Service
VERSION:  v1

FIELD:    nodePort <integer>

DESCRIPTION:
     The port on each node on which this service is exposed when type is
     NodePort or LoadBalancer. Usually assigned by the system. If a value is
     specified, in-range, and not in use it will be used, otherwise the
     operation will fail. If not specified, a port will be allocated if this
     Service requires one. If this field is specified when creating a Service
     which does not need it, creation will fail. This field will be wiped when
     updating a Service to no longer need it (e.g. changing type from NodePort
     to ClusterIP). More info:
     https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport
```

<br>

**💻 실습 1 :** NodePort 서비스 

`myweb-svc-np.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myweb-svc-np
spec:
  type: NodePort
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 8080    
```

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
$ kubectl create -f .
```

`myweb-svc-np`의 포트를 별도로 지정하지 않았기 때문에,

 30000-32767 범위에서 랜덤으로 30749 포트가 지정된 것을 확인할 수 있다.

```shell
$ kubectl get rs,po,svc
NAME                       DESIRED   CURRENT   READY   AGE
replicaset.apps/myweb-rs   3         3         3       35h

NAME                 READY   STATUS    RESTARTS        AGE
pod/myweb-rs-kvsjs   1/1     Running   1 (10m ago)     35h
pod/myweb-rs-vjrp6   1/1     Running   1 (9m10s ago)   35h
pod/myweb-rs-xzx7j   1/1     Running   1 (9m41s ago)   35h

NAME                   TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/kubernetes     ClusterIP   10.233.0.1      <none>        443/TCP        35h
service/myweb-svc-np   NodePort    10.233.33.194   <none>        80:30749/TCP   34s
```

다음에서도  `kube-proxy`에 의해서  `30749` 포트가 열려있는 것을 확인할 수 있다.

```shell
$ sudo ss -tnlp
State      Recv-Q      Send-Q             Local Address:Port            Peer Address:Port     Process       ...     
LISTEN     0           4096                     0.0.0.0:30749                0.0.0.0:*         users:(("kube-proxy",pid=2007,fd=13))                                                        
...                                                  
```

node2와 node3도 동일한 것을 확인할 수 있다. 즉 **모든 노드에 포트가 열린다.**

```shell
$ ssh node2 sudo ss -tnlp | grep proxy
LISTEN   0         4096                 0.0.0.0:30749            0.0.0.0:*       users:(("kube-proxy",pid=2120,fd=12))                                          
...                                         
$ ssh node3 sudo ss -tnlp | grep proxy
LISTEN   0         4096                 0.0.0.0:30749            0.0.0.0:*       users:(("kube-proxy",pid=2245,fd=13))                                          
...                                         
```

외부에서 이러한 노드 포트를 통해 접근할 수 있게 되는 것이고, 노드포트를 통해 접근하면 iptables에 세팅된다.

이해를 돕기 위해 현재 상황을 다이어그램으로 나타내면 아래와 같다고 볼 수 있다. 

<br>

<img src="https://raw.githubusercontent.com/na3150/typora-img/main/img/kubernetes-nodeport-diagram.svg" alt="kubernetes-nodeport-diagram" style="zoom:67%;" />

<br>

```shell
$ kubectl get svc      
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
myweb-svc-np   NodePort    10.233.33.194   <none>        80:30749/TCP   106m
```

현재 NodePort를 사용하고 있지만, NodePort는 결국 ClusterIP 기반의 구성이되었다.

즉, **NodePort는 ClusterIP 기능에 NodePort가 추가되는 것**⭐이다 :  `NodePort = NodePort + ClusterIP`

그러므로 외부로 노출 시킬 수 있는 것이다. (가장 처음 첨부했던 다이어그램에서 확인할 수 있다)

<br>

기본적으로 **라운드로빈**이 되는 것도 확인할 수 있다.

```shell
$ curl 192.168.100.100:30749
Hello World!
myweb-rs-xzx7j
$ curl 192.168.100.100:30749
Hello World!
myweb-rs-vjrp6
$ curl 192.168.100.100:30749
Hello World!
myweb-rs-kvsjs
```

node2, node3로 해도 동일하다. 즉, **어떤 포트로 접속하든 해당 서비스로 연결**된다.

```shell
$ curl 192.168.100.101:30749
Hello World!
myweb-rs-xzx7j
$ curl 192.168.100.102:30749
Hello World!
myweb-rs-xzx7j
```

<br>

**💻 실습 1 :** NodePort 서비스의 포트 직접 지정하기

`svc.spec.ports.nodePort`을30000-32767 범위 내에서 아무 포트로 지정해보자.

<br>

`myweb-svc-np.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myweb-svc-np
spec:
  type: NodePort
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 8080   
      nodePort: 31313
```

```shell
$ kubectl create -f myweb-svc-np.yaml   
service/myweb-svc-np created
```

`31313` 포트로 설정된 것을 확인할 수 있다.

```shell
$ kubectl get svc                    
NAME           TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes     ClusterIP   10.233.0.1      <none>        443/TCP        37h
myweb-svc-np   NodePort    10.233.48.144   <none>        80:31313/TCP   4s
```

접속 확인

```shell
$ curl 192.168.100.100:31313         
Hello World!
myweb-rs-xzx7j
```

<br>

<br>

<br>

NodePort를 이용하여 외부로 노출시키는 방법이 불가능한 것은 아니나,

포트를 직접 지정해서 접속하는 경우가 드물고, 번거롭다고 여기기 때문에 

일반적으로 로드밸런서를 이용하여 외부에 노출시킨다. 





