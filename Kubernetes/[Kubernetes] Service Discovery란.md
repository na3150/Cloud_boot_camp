# [kubernetes] Service Discovery란?

 Auto-scaling, 업그레이드, 확장 등의 이유로 생성, 소멸되면서 서비스의 IP가 동적으로 변경되는 일이 많다.
그러나 클라이언트 애플리케이션은 이러한 변경 사항을 알기 어렵다.
Auto-scaling이 되어 서버가 하나 더 생성되었더라도 이를 알아차리고 생성된 서버에 트래픽을 분산시키기 어렵다는 뜻이다.
이런 상황에서 클라이언트가 서비스의 Location(IP주소와 포트)을 알아내려면 어떻게 해야할까?
바로 이런 역할을 Service Discovery가 해준다.

<br>

**애플리케이션이 해당되는 서비스를 찾아내는 것을 Service Discovery**(SD)라고 한다.

<br>

![Kubernetes Patterns : The Service Discovery Pattern](https://www.magalix.com/hubfs/service%20discovery%207.png)

출처: https://www.magalix.com/blog/kubernetes-patterns-the-service-discovery-pattern

<br>

랜덤한 IP에 대응하기 위해, k8s는 앞에 서비스를 만들고, 레이블과 셀렉터를 사용하여 서비스의 백엔드로 연결시킨다.

그러나, 서비스 자체도 IP가 랜덤하기 때문에 애플리케이션이 서비스의 IP를 알 수가 없다.

 따라서 고정된 문자형태의 이름이 필요하다. 

결론적으로, 클라이언트 애플리케이션 입장에서 서비스 디스커버리를 해야한다. 

<br>

### 환경 변수를 이용한 Service Discovery

모든 파드는 기본적으로 **파드가 실행되는 시점의 서비스 목록을 `etcd`에서 읽어 환경변수로 제공**한다.

환경 변수명의 구조는 정해져있고, 파드가 생성된 이후에 생성된 서비스는 파드에 반영이 안된다.

```shell
MYWEB_SVC_PORT_80_TCP_PORT=80 #etcd에서 정보를 읽어서 세팅해줌
MYWEB_SVC_PORT_80_TCP_PROTO=tcp
MYWEB_SVC_PORT_80_TCP=tcp://10.233.18.231:80
MYWEB_SVC_SERVICE_HOST=10.233.18.231
MYWEB_SVC_SERVICE_PORT=80
MYWEB_SVC_PORT=tcp://10.233.18.231:80
KUBERNETES_SERVICE_PORT_HTTPS=443
MYWEB_SVC_PORT_80_TCP_ADDR=10.233.18.231
```

따라서 파드 생성 시점에 서비스 목록을 변수화시키기 위해 **서비스를 먼저 만들고 애플리케이션 파드를 나중에** 띄워야한다. 

<br>

또한 애플리케이션을 만들 때 서비스 이름을 미리 구상한 뒤, 서비스를 만들기 전에

애플리케이션 환경 변수에 서비스 이름을 참조해두면

나중에 변수를 읽어서 값이 대치되고, 애플리케이션이 서비스를 디스커버리할 수 있게된다. 

<br>

**💻실습** 

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
$ kubectl get rs,po,svc                            
NAME                       DESIRED   CURRENT   READY   AGE
replicaset.apps/myweb-rs   3         3         3       4s

NAME                 READY   STATUS    RESTARTS   AGE
pod/myweb-rs-kvsjs   1/1     Running   0          4s
pod/myweb-rs-vjrp6   1/1     Running   0          4s
pod/myweb-rs-xzx7j   1/1     Running   0          4s

NAME                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
service/kubernetes   ClusterIP   10.233.0.1      <none>        443/TCP   18s
service/myweb-svc    ClusterIP   10.233.18.231   <none>        80/TCP    4s
```

파드를 하나 생성해서 환경변수를 확인해보자.

```shell
$ kubectl run nettool -it --image ghcr.io/c1t1d0s7/network-multitool --rm

If you don't see a command prompt, try pressing enter.
/ # env
KUBERNETES_PORT=tcp://10.233.0.1:443
KUBERNETES_SERVICE_PORT=443
MYWEB_SVC_PORT_80_TCP_PORT=80 #etcd에서 정보를 읽어서 세팅해줌
MYWEB_SVC_PORT_80_TCP_PROTO=tcp
HOSTNAME=nettool
SHLVL=1
HOME=/root
MYWEB_SVC_PORT_80_TCP=tcp://10.233.18.231:80
TERM=xterm
KUBERNETES_PORT_443_TCP_ADDR=10.233.0.1
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_PROTO=tcp
MYWEB_SVC_SERVICE_HOST=10.233.18.231
MYWEB_SVC_SERVICE_PORT=80
MYWEB_SVC_PORT=tcp://10.233.18.231:80
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT_443_TCP=tcp://10.233.0.1:443
KUBERNETES_SERVICE_HOST=10.233.0.1
PWD=/
MYWEB_SVC_PORT_80_TCP_ADDR=10.233.18.231
```

<br>

<br>

### DNS를 이용한 Service Discovery

모든 UNIX 시스템은 `/etc/resolv.conf`에 지정되어있는 DNS에게 질의를 한다.

해당 파일의 nameserver는 `kube-dns`이고, 정확하게는 최종적으로 `coredns`에게 질의를 한다.

```shell
/ # cat /etc/resolv.conf 
search default.svc.cluster.local svc.cluster.local cluster.local
nameserver 169.254.25.10 #DNS서버-> coreDNS
options ndots:5
```

`host` 커맨드를 통해 `DNS Query`를 보내면 DNS 서버는 `DNS Answer`를 준다.

```shell
/ # host myweb-svc
myweb-svc.default.svc.cluster.local has address 10.233.18.231
```

`-v ` 옵션을 사용하면, 어떻게 요청과 질의가 오가는지 확인할 수 있다.

```shell
    / # host -v myweb-svc 
    Trying "myweb-svc.default.svc.cluster.local"
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 21427  #콜론 2개는 주석
    ;; flags: qr aa rd; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 0
    
    ;; QUESTION SECTION:
    ;myweb-svc.default.svc.cluster.local. IN        A
    
    ;; ANSWER SECTION:
    myweb-svc.default.svc.cluster.local. 5 IN A     10.233.18.231
    
    Received 104 bytes from 169.254.25.10#53 in 0 ms
    Trying "myweb-svc.default.svc.cluster.local"
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 8273
    ;; flags: qr aa rd; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 0
    
    ;; QUESTION SECTION:
    ;myweb-svc.default.svc.cluster.local. IN        AAAA
    
    ;; AUTHORITY SECTION:
    cluster.local.          5       IN      SOA     ns.dns.cluster.local. hostmaster.cluster.local. 1653013606 7200 1800 86400 5
    
    Received 146 bytes from 169.254.25.10#53 in 4 ms
    Trying "myweb-svc.default.svc.cluster.local"
    ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 13019
    ;; flags: qr aa rd; QUERY: 1, ANSWER: 0, AUTHORITY: 1, ADDITIONAL: 0
    
    ;; QUESTION SECTION:
    ;myweb-svc.default.svc.cluster.local. IN        MX
    
    ;; AUTHORITY SECTION:
    cluster.local.          5       IN      SOA     ns.dns.cluster.local. hostmaster.cluster.local. 1653013606 7200 1800 86400 5
    
    Received 146 bytes from 169.254.25.10#53 in 0 ms
```

앞선 `DNS Query`를 다시 한번 살펴보자

```shell
/ # host myweb-svc
myweb-svc.default.svc.cluster.local has address 10.233.18.231
```

`myweb-svc.default.svc.cluster.local`은 FQDN으로, 실제 `myweb-svc`의 실제이름이다. 

**FQDN(Fully Qualified Domain Name)이란, 전체 도메인 이름**을 의미한다.

- `default` : Namespace
- `svc` : Type
- `cluster.local` : 기본 Domain, 클러스터 내부에서만 사용

```shell
$ vi /home/vagrant/kubespray/inventory/mycluster/group_vars/k8s_cluster/k8s-cluster.yml
```

본 파일의 `cluster_name`이 `cluster.local`이기 때문에 도메인명으로 cluster.local이 붙어있는 것이다.

```shell
...
cluster_name: cluster.local
...
```

Service 생성하면 해당 이름으로 FQDN이  DNS 서버에 등록된다.

**구조**

```
[서비스 이름].[네임스페이스].[오브젝트 타입].[도메인]
```

다음을 보면 모두 동일한 결과를 반환하는 것을 확인할 수 있다. 

```shell
/ # host myweb-svc
myweb-svc.default.svc.cluster.local has address 10.233.18.231
/ # host myweb-svc.default
myweb-svc.default.svc.cluster.local has address 10.233.18.231
/ # host myweb-svc.default.svc
myweb-svc.default.svc.cluster.local has address 10.233.18.231
/ # host myweb-svc.default.svc.cluster.local
myweb-svc.default.svc.cluster.local has address 10.233.18.231
```

이러한 것은 항상 가능한 것은 아니고, `/etc/resolv.conf` 파일을 보면 `search` 설정을 확인할 수 있다.

```shell
# cat /etc/resolv.conf
search default.svc.cluster.local svc.cluster.local cluster.local
nameserver 169.254.25.10
options ndots:5
```

`myweb-svc`는 FQDN이 아니고, 실제로 이것으로 질의를 하는 것을 불가능하며, 완전한 FQDN으로 질의를 해야한다.

`myweb-svc`로만 질의하는 경우, search 뒤의 첫번째 요소 `default.svc.cluster.local`이 뒤에 붙게된다.

즉 `myweb-svc`라고 쓰더라도 내부적으로는 `myweb-svc.default.svc.cluster.local`을 DNS 서버에 질의하게 된다.

여기서 결과가 잘 돌아오면 그대로 반환하고, 돌아오지 않으면 두번째 것 `svc.cluster.local`을 붙여서 질의한다.

그리고 또 응답이 돌아오지 않으면 세번째를 붙여서 질의하고, 여기서도 응답이 돌아오지 않으면

도메인이 없다는 의미의 `NXDOMAIN` 오류를 낸다.

즉, **search 옆에 질의할 순서대로 나열**되어있는 것이고 이런 것들을 search domain이라고 한다.

이렇게 **search domain을 지정해놓으면 이름만으로 질의가 가능**하게 되는 것이다.

<br>

**💻실습** 

다음과 같이 서로 다른 네임스페이트의 서비스와 파드를 통신해보자

```
nettool Pod(dev NS) --> myweb-svc SVC(default NS)
```

<br>

먼저 `dev` 네임스페이스를 만든다

```shell
$ kubectl create ns dev
```

dev 네임스페이스에서 파드를 실행해보자

```shell
$ kubectl run nettool -it --image ghcr.io/c1t1d0s7/network-multitool -n dev --rm
/#
```

다른 터미널을 열어서 dev 네임스페이스에 파드가 실행중인 것을 확인한다.

```shell
$ kubectl get po -n dev 
NAME          READY   STATUS    RESTARTS       AGE
nettool       1/1     Running   0              92s
```

dev NS의`nettool ` 파드에서 default NS의` myweb-svc`에 질의를 보내보자. 정상적으로 응답이 온다.

```shell
/ # host myweb-svc
myweb-svc.default.svc.cluster.local has address 10.233.18.231
```

search 도메인을 `myweb-svc`에 하나씩 붙여서 질의를 보내보면, nettool과 myweb-svc의 네임스페이스가 다르기 때문에 

마지막 서치 도메인인 `default.svc.cluster.local`를 붙여서 보낼 때만 정상적으로 응답을 받는 것을 확인할 수 있다.

```shell
/ # cat /etc/resolv.conf
search dev.svc.cluster.local svc.cluster.local cluster.local default.svc.cluster.local
nameserver 169.254.25.10
options ndots:5
/ # host myweb-svc.dev.svc.cluster.local
Host myweb-svc.dev.svc.cluster.local not found: 3(NXDOMAIN)
/ # host myweb-svc.svc.cluster.local
Host myweb-svc.svc.cluster.local not found: 3(NXDOMAIN)
/ # host myweb-svc.cluster.local
Host myweb-svc.cluster.local not found: 3(NXDOMAIN)
/ # host myweb-svc.default.svc.cluster.local
myweb-svc.default.svc.cluster.local has address 10.233.18.231
```

사실 몇버전 이전까지만해도 default 네임서버의 FQDN은 서치도메인에 등록되지 않았었고,

따라서 다른 네임스페이스간에 이름으로의 검색이 불가능했었다.

이것은 버전 마다 다르기 때문에, **이름 뒤에 네임스페이스를 붙이는 것을 권장**한다⭐: `myweb-svc.default`

<br>

또한, 네임스페이스를 붙이지 않으면 잘못된 결과를 초래하게될 수도 있다.

예를 들어, default NS에도 myweb-svc가 있고, dev NS에도 myweb-svc가 있다고 해보자.

리소스의 이름은 NS에서만 유일하면 되고, default와 dev는 서로 다른 NS이기 때문에 같은 이름을 사용해도 무방하다.

서치 도메인에서 가장 먼저 `dev.svc.cluster.local`을 붙여서 질의를 보내는데, 

dev에 myweb-svc가 있으므로 dev의 myweb-svc에 접속하게된다. 

따라서 만약 **같은 이름의 리소스가 있다면 엉뚱한 것에 접속될 수도 있다.**

**네임스페이스까지 지정해주는 것이 권장사항이지만 가장 안전한 방법은 풀네임을 작성해주는 것**이다.

```shell
/ # cat /etc/resolv.conf
search dev.svc.cluster.local svc.cluster.local cluster.local default.svc.cluster.local
nameserver 169.254.25.10
options ndots:5
```

`ndots:5`은 FQDN에 점 `.`이 5개 있어야함을 의미한다 => `myweb-svc.default.svc.cluster.local.`

도메인 마지막에는 항상 점이 존재하기 때문에 생략한 것이지 원래는 점이 있다.

<br>

#### nodelocal DNS

[NodeLocal DNSCache](https://kubernetes.io/docs/tasks/administer-cluster/nodelocaldns/) : `v1.18` 부터 `[stable]`

모든 파드는 기본적으로 dns서버로 `169.254.25.10`을 바라보고 있다.

```shell
$ ip a s
...
4: nodelocaldns: <BROADCAST,NOARP> mtu 1500 qdisc noop state DOWN group default 
    link/ether ca:2b:b0:12:4f:20 brd ff:ff:ff:ff:ff:ff
    inet 169.254.25.10/32 scope global nodelocaldns
       valid_lft forever preferred_lft forever
...     
```

다음에서 확인할 수 있듯이 `169.254.25.10:9254`로 질의를 하면, `node-cache`(DNS Cache Server)가 받는다.

```shell
$ sudo ss -tnlp            
State      Recv-Q      Send-Q             Local Address:Port            Peer Address:Port     Process                                                                                       
LISTEN     0           4096               169.254.25.10:9254                 0.0.0.0:*         users:(("node-cache",pid=62761,fd=7))                  
```

<br>

<img src="https://d33wubrfki0l68.cloudfront.net/bf8e5eaac697bac89c5b36a0edb8855c860bfb45/6944f/images/docs/nodelocaldns.svg" alt="NodeLocal DNSCache flow" style="zoom:67%;" />

<br>

1. Client Pod가 Local DNS Cache에 Query 요청
   - Local DNS Cache가 알고있는 경우: **Cache Hit**
2. Local DNS Cache가 모르는 경우: **Cache miss**

3. KubeDNS pods에 Query 요청 후 Cache에 저장(TTL 만큼 저장)
4. LocalDNS가 Client Pod에 Answer 응답

<br>

`nodelocaldns` 파드가 존재하는 것을 확인할 수 있고,  **nodelocaldns의 IP는 각 호스트의 IP가 부여**된다. 

```shell
$ kubectl get po -A -o wide| grep nodelocaldns
kube-system   nodelocaldns-4vt4h                        1/1     Running   10 (14h ago)    37h     192.168.100.102   node3   <none>           <none>
kube-system   nodelocaldns-g74tc                        1/1     Running   70 (14h ago)    3d23h   192.168.100.101   node2   <none>           <none>
kube-system   nodelocaldns-l2lz7                        1/1     Running   210 (12h ago)   3d23h   192.168.100.100   node1   <none>           <none>
```

아무거나 하나를 선택해서 상세정보를 확인해보자.

`169.254.25.10`  IP를 확인할 수 있다.

```shell
$ kubectl get po -n kube-system nodelocaldns-4vt4h -o yaml
...
  containers:
  - args:
    - -localip
    - 169.254.25.10 #IP확인
    - -conf
    - /etc/coredns/Corefile
    - -upstreamsvc
    - coredns
    image: k8s.gcr.io/dns/k8s-dns-node-cache:1.21.1
    imagePullPolicy: IfNotPresent
    livenessProbe:
      failureThreshold: 10
      httpGet:
        host: 169.254.25.10 #IP확인
...
```

`coredns` 파드도 확인할 수 있고, 앞서 말했듯이 **coredns가 실제 DNS서버 역할을 한다.**

```shell
$ kubectl get po -A | grep coredns
kube-system   coredns-8474476ff8-lgmhr                  1/1     Running   18 (14h ago)    3d23h
kube-system   coredns-8474476ff8-ql8zk                  1/1     Running   8 (14h ago)     37h
```

coredns 서비스도 확인할 수 있다.

```shell
$ kubectl get svc -n kube-system  
NAME      TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)                  AGE
coredns   ClusterIP   10.233.0.3   <none>        53/UDP,53/TCP,9153/TCP   3d23h
```

coredns 서비스명과 동일한 coredns 엔드포인트가 생성되어있는 것을 확인할 수 있고, 

ENDPOINTS는 좀 전에 봤던 coredns파드들이다. 

즉, coredns 서비스로 접근하면, coredns 파드들로 접근하게 된다.

```shell
$ kubectl get ep -n kube-system 
NAME      ENDPOINTS                                                     AGE
coredns   10.233.90.62:53,10.233.96.70:53,10.233.90.62:53 + 3 more...   3d23h
```

<br>

왜 cache 서버를 두게 되었을까❔

coredns 파드는 ControlPlane에만 존재하며, ControlPlane은 일반적으로 3개만 구성하기 때문에 coredns도 3개인 경우가 대부분이다.

노드와 파드가 매우 많은 경우, 파드들의 모든 요청을 3개의 coredns에 하게되기 때문에 엄청난 부하를 받게된다.

이러한 문제를 보완하기 위해 로컬에 cache서버를 두어 아는 정보는 파드가 로컬에 요청하여 응답을 받을 수 있게 구성한 것이다. 

<br>

nodelocal DNS 캐시 사용를 사용하는 경우

- **Pod --dns--> 169.254.25.10(node-cache): DNS Cache Server --> coredns SVC(kube-system NS) -> coredns POD**

nodelocal DNS 캐시 사용하지 않는 경우

- Pod --dns--> coredns SVC(kube-system NS) -> coredns POD

<br>

<br>

<br>

결론적으로 Service Discovery를 하는 방식에는 환경 변수와 DNS가 있는데, 실제로 DNS가 더 유용한 방법이다.

DNS를 이용한 방식은, 나중에 서비스가 생성되더라도 해당 서비스는 coredns 서버에 자동으로 생성되어

나중에 생성된 서비스도 얼마든지 질의할 수 있기 때문이다. 

