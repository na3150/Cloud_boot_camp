# [Kubernetes] Services와 DNS

[서비스](https://kubernetes.io/ko/docs/concepts/services-networking/service/)는 **파드 집합에서 실행중인 애플리케이션을 네트워크 서비스로 노출**하는 추상화 방법이다. 

서비스를 이용하여 고유한 IP주소, DNS이름을 부여하여 접근할 수 있다. 

또한 서비스는 **기본적으로 로드밸런서의 기능**을 가지고 있기 때문에 트래픽을 분산해서 접근이 가능하게한다.

클라이언트 입장에서 어느 애플리케이션에 찾아가야할지 알 수 없기 때문에 서비스 리소스를 사용한다.

**서비스 리소스에는 셀렉터가 있고, 파드는 레이블을 가지고 있어서 서비스와 파드들이 연결**된다.

또한 **서비스에는 DNS이름이 부여**되는데, 이러한 이름이 부여되기 위해서는 `kube-dns`구성이 되어있어야한다. 

`kubeadm`에 의해 `kube-dns`는 무조건 설치되며, coredns를 dns서버로 사용한다. 

참고로 `kube-dns`는 클러스터 내부에서 사용하는 것이고,

외부에서 사용하기 위해서는 별도의 DNS서버를 구축해야한다. 

<br>

서비스는 Core 그룹에 속하며, 네임스페이스를 사용고 `Service`라는 `kind`를 사용하고 있다. 

```shell
$ kubectl api-resources | grep services
services                          svc          v1                                     true         Service
```

<br>

**리소스 사용법 확인**

```shell
$ kubectl explain svc
```

- `ClusterIPs`
  - 서비스의 IP를 사용자가 직접 할당하는 것이다.
  - `kube-dns`가 있기 때문에, 잘 사용되지 않는다.

```shell
 clusterIPs   <[]string>
     ClusterIPs is a list of IP addresses assigned to this service, and are
     usually assigned randomly. If an address is specified manually, is in-range
     (as per system configuration), and is not in use, it will be allocated to
     the service; otherwise creation of the service will fail. This field may
     not be changed through updates unless the type field is also being changed
     to ExternalName (which requires this field to be empty) or the type field
     is being changed from ExternalName (in which case this field may optionally
     be specified, as describe above). Valid values are "None", empty string
     (""), or a valid IP address. Setting this to "None" makes a "headless
     service" (no virtual IP), which is useful when direct endpoint connections
     are preferred and proxying is not required. Only applies to types
     ClusterIP, NodePort, and LoadBalancer. If this field is specified when
     creating a Service of type ExternalName, creation will fail. This field
     will be wiped when updating a Service to type ExternalName. If this field
     is not specified, it will be initialized from the clusterIP field. If this
     field is specified, clients must ensure that clusterIPs[0] and clusterIP
     have the same value.
```

- `ports`
  - 클라이언트가 접근하는 서비스의 포트
  - `ports.name` : 포트의 이름을 부여
  - `ports.port` : 실제 서비스에 노출시킬 포트
  - `ports.protocol` : TCP(default), UDP, SCTP(L4)
  - `ports.targetPort` : 파드의 포트 (서비스->파드) 

```shell
$ kubectl explain svc.spec.ports   
KIND:     Service
VERSION:  v1

RESOURCE: ports <[]Object>

DESCRIPTION:
     The list of ports that are exposed by this service. More info:
     https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies

     ServicePort contains information on service's port.

FIELDS:
   appProtocol  <string>
     The application protocol for this port. This field follows standard
     Kubernetes label syntax. Un-prefixed names are reserved for IANA standard
     service names (as per RFC-6335 and
     http://www.iana.org/assignments/service-names). Non-standard protocols
     should use prefixed names such as mycompany.com/my-custom-protocol.

   name <string>
     The name of this port within the service. This must be a DNS_LABEL. All
     ports within a ServiceSpec must have unique names. When considering the
     endpoints for a Service, this must match the 'name' field in the
     EndpointPort. Optional if only one ServicePort is defined on this service.

   nodePort     <integer>
     The port on each node on which this service is exposed when type is
     NodePort or LoadBalancer. Usually assigned by the system. If a value is
     specified, in-range, and not in use it will be used, otherwise the
     operation will fail. If not specified, a port will be allocated if this
     Service requires one. If this field is specified when creating a Service
     which does not need it, creation will fail. This field will be wiped when
     updating a Service to no longer need it (e.g. changing type from NodePort
     to ClusterIP). More info:
     https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport

   port <integer> -required-
     The port that will be exposed by this service.

   protocol     <string>
     The IP protocol for this port. Supports "TCP", "UDP", and "SCTP". Default
     is TCP.

   targetPort   <string>
     Number or name of the port to access on the pods targeted by the service.
     Number must be in the range 1 to 65535. Name must be an IANA_SVC_NAME. If
     this is a string, it will be looked up as a named port in the target Pod's
     container ports. If this is not specified, the value of the 'port' field is
     used (an identity map). This field is ignored for services with
     clusterIP=None, and should be omitted or set equal to the 'port' field.
     More info:
     https://kubernetes.io/docs/concepts/services-networking/service/#defining-a-service
```

- `selector`
  - 서비스가 연결하기 위한 파드의 레이블 셀렉터

```shell
$ kubectl explain svc.spec.selector
KIND:     Service
VERSION:  v1

FIELD:    selector <map[string]string>

DESCRIPTION:
     Route service traffic to pods with label keys and values matching this
     selector. If empty or not present, the service is assumed to have an
     external process managing its endpoints, which Kubernetes will not modify.
     Only applies to types ClusterIP, NodePort, and LoadBalancer. Ignored if
     type is ExternalName. More info:
     https://kubernetes.io/docs/concepts/services-networking/service/
```

- `type`
  - `ExternalName`, `ClusterIP`, `NodePort`,  `LoadBalancer`가 있고, defualt는 `ClusterIP`이다.
  - `NodePort`,  `LoadBalancer` 는 외부로 노출시키기 위한 것이다.
  - `ClusterIP`는 클러스터 내부이다.

```shell
$ kubectl explain svc.spec.type 
KIND:     Service
VERSION:  v1

FIELD:    type <string>

DESCRIPTION:
     type determines how the Service is exposed. Defaults to ClusterIP. Valid
     options are ExternalName, ClusterIP, NodePort, and LoadBalancer.
     "ClusterIP" allocates a cluster-internal IP address for load-balancing to
     endpoints. Endpoints are determined by the selector or if that is not
     specified, by manual construction of an Endpoints object or EndpointSlice
     objects. If clusterIP is "None", no virtual IP is allocated and the
     endpoints are published as a set of endpoints rather than a virtual IP.
     "NodePort" builds on ClusterIP and allocates a port on every node which
     routes to the same endpoints as the clusterIP. "LoadBalancer" builds on
     NodePort and creates an external load-balancer (if supported in the current
     cloud) which routes to the same endpoints as the clusterIP. "ExternalName"
     aliases this service to the specified externalName. Several other fields do
     not apply to ExternalName services. More info:
     https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types
```

<br>

**💻 실습**

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

`ContainerPort`가 8080이므로, 서비스의 `TargetPort`가 8080이어야한다. 

`myweb-svc.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myweb-svc
spec:
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 8080 
```

```shell
$ kubectl create -f myweb-rs.yaml -f myweb-svc.yaml          
replicaset.apps/myweb-rs created
service/myweb-svc created
```

`type`의 default가 ClusterIP이므로, ClusterIP가 적용되며 이 IP값은 랜덤으로 부여된다. 

외부주소는 없고, 내부에서 해당 IP와 포트로 접속할 수 있다.

```shell
$ kubectl get rs,po,svc
NAME                       DESIRED   CURRENT   READY   AGE
replicaset.apps/myweb-rs   3         3         3       14m

NAME                 READY   STATUS    RESTARTS        AGE
pod/myweb-rs-29wnw   1/1     Running   0               14m
pod/myweb-rs-2qhwb   1/1     Running   1 (6m31s ago)   14m
pod/myweb-rs-z7v8b   1/1     Running   1 (6m5s ago)    14m

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.233.0.1      <none>        443/TCP   3d
service/myweb-svc    ClusterIP   10.233.31.198   <none>        80/TCP    8h
```

```shell
$ kubectl get svc myweb-svc
NAME        TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
myweb-svc   ClusterIP   10.233.31.198   <none>        80/TCP    9h
$ kubectl describe svc myweb-svc
Name:              myweb-svc
Namespace:         default
Labels:            <none>
Annotations:       <none>
Selector:          app=web
Type:              ClusterIP
IP Family Policy:  SingleStack
IP Families:       IPv4
IP:                10.233.31.198
IPs:               10.233.31.198
Port:              <unset>  80/TCP
TargetPort:        8080/TCP
Endpoints:         10.233.90.54:8080,10.233.92.227:8080,10.233.96.65:8080
Session Affinity:  None
Events:            <none>
```

describe로 확인한 `Endpoints`가 파드들의 IP인 것을 확인할 수 있다.

또한, `TargetPort`가 8080이기 때문에, 엔트포인드에 :8080이 붙어있다.

```shell
$ kubectl get pod -o wide 
NAME             READY   STATUS    RESTARTS      AGE   IP              NODE    NOMINATED NODE   READINESS GATES
myweb-rs-29wnw   1/1     Running   0             27m   10.233.90.54    node1   <none>           <none>
myweb-rs-2qhwb   1/1     Running   1 (19m ago)   27m   10.233.96.65    node2   <none>           <none>
myweb-rs-z7v8b   1/1     Running   1 (19m ago)   27m   10.233.92.227   node3   <none>           <none>
```

접속 확인을 위해 임시로 파드를 하나 띄워보자

그리고 `curl`을 설치한다.

```shell
$ kubectl run client -it --image ubuntu bash
If you don't see a command prompt, try pressing enter.
root@client:/# apt update; apt install curl
```

**접속 확인**

서비스의 IP로 접속했을 때, 정상적으로 작동하는 것을 확인할 수 있다.

```shell
root@client:/# curl 10.233.31.198
Hello World!
myweb-rs-z7v8b
```

이때, 서비스는 로드밸런싱 기능을 가지고 있기 때문에, 자동으로 트래픽이 분산되어 엔드포인트들 중 하나로 연결된다.

<br>

☁️**참고**

현재 디렉토리의 모든 `yaml` 파일을 실행시키고 싶을 때 다음과 같이 명령할 수 있다.

```shell
$ kubectl create -f .     
```

`kubelet_max_pods`

☁️**참고**

```shell
 $ vi /home/vagrant/kubespray/inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml 
 ...
 # Kubernetes internal network for services, unused block of space.
 kube_service_addresses: 10.233.0.0/18 #서비스의 네트워크 대역
  
  # internal network. When used, it will assign IP
  # addresses from this range to individual pods.
  # This network must be unused in your network infrastructure!
  kube_pods_subnet: 10.233.64.0/18 #파드의 네트워크 대역
  ...
  #  - kubelet_max_pods: 110 #kubelet 하나당 110개의 파드로 제한이 걸림->한 노드당 110개를 넘어갈수없음
  ...
```

<br>

#### Endpoint

서비스를 생성하면, **서비스 이름과 동일한 이름의 엔드포인트가 만들어진다.**

`myweb-svc` 엔드포인트를 확인할 수 있다.

```shell
$ kubectl get endpoints         
NAME         ENDPOINTS                                                AGE
kubernetes   192.168.100.100:6443                                     3d
myweb-svc    10.233.90.54:8080,10.233.92.227:8080,10.233.96.65:8080   9h
```

서비스의 셀렉터가 파드를 셀렉팅하는데, 이러한 셀렉팅 정보는 엔드포인트가 갖고있다.

즉, **실제로 엔드포인트의 목록을 갖고있는 것은 서비스 이름과 동일한 엔드포인트(오브젝트 리소스)**이다. 

<br>

**💻 실습**

앞선 실습에 이어서 서비스에 연결된 파드 한 개(`myweb-rs-z7v8b`)를 삭제해보자. (client는 삭제하였다)

```shell
$ kubectl get po -o wide 
NAME             READY   STATUS    RESTARTS        AGE     IP              NODE    NOMINATED NODE   READINESS GATES
myweb-rs-29wnw   1/1     Running   0               37m     10.233.90.54    node1   <none>           <none>
myweb-rs-2qhwb   1/1     Running   1 (29m ago)     37m     10.233.96.65    node2   <none>           <none>
myweb-rs-z7v8b   1/1     Running   1 (29m ago)     37m     10.233.92.227   node3   <none>           <none>
$ kubectl delete po myweb-rs-z7v8b              
pod "myweb-rs-z7v8b" deleted                                                                                 
```

그러면 `ReplicaSets`에 의해 자동으로 파드가 하나 생성되고, 새로운 IP가 부여된다.

```shell
$ kubectl get po -o wide           
NAME             READY   STATUS    RESTARTS        AGE     IP              NODE    NOMINATED NODE   READINESS GATES
myweb-rs-29wnw   1/1     Running   0               37m     10.233.90.54    node1   <none>           <none>
myweb-rs-2qhwb   1/1     Running   1 (29m ago)     37m     10.233.96.65    node2   <none>           <none>
myweb-rs-wfqlg   1/1     Running   0               4s      10.233.92.229   node3   <none>           <none>
```

즉, 백엔드가 바뀌게 된 것이고, **백엔드가 바뀌면 엔드포인트가 알아서 감지해서 업데이트한다.**

```shell
$ kubectl get ep        
NAME         ENDPOINTS                                                AGE
kubernetes   192.168.100.100:6443                                     3d
myweb-svc    10.233.90.54:8080,10.233.92.229:8080,10.233.96.65:8080   9h
```

다시 한번 언급하자면 엔드포인트 목록을 가지고 있는 것은 서비스 이름과 동일한 엔트포인트 오브젝트 리소스이다.

<br>

이름을 통해 접속할 수 있는 것을 확인할 수 있다.

```shell
bash-5.1# host myweb-svc
myweb-svc.default.svc.cluster.local has address 10.233.31.198
bash-5.1# curl 10.233.31.198
Hello World!
myweb-rs-wfqlg
```

```shell
bash-5.1# cat /etc/resolv.conf
search default.svc.cluster.local svc.cluster.local cluster.local
nameserver 169.254.25.10 #CoreDNS서버
options ndots:5
bash-5.1# curl myweb-svc
Hello World!
myweb-rs-2qhwb
```



