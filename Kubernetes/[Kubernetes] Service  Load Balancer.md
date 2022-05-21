# [Kubernetes] Service : Load Balancer

<br>

#### ✔Service : LoadBalaner 타입

Nodeport 타입의 확장판이라고 할 수 있으며, 서비스를 외부에 노출 시킬 수 있다.

LoadBalaner 타입을 사용하는 경우, ClusteIP와 NodePort기반의 구성이 되는데

즉, **LoadBalancer = ClusterIP + NodePort + LoadBalancer** 라고 할 수 있다. 

<br>

![img](https://blog.kakaocdn.net/dn/btDfCd/btq5BmxMptL/HD3MVK1d9enyIaAwoWh6ak/img.png)

출처: https://kim-dragon.tistory.com/52

<br>

NodePort타입 앞단에 Loadbalancer가 붙어서 살아있는 노드를 체크하여 트래픽을 전달 할 수 있는 장점이 있다. 

<br>

<br>

`myweb-svc-lb.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: myweb-svc-lb
spec:
  type: LoadBalancer
  selector:
    app: web
  ports:
    - port: 80
      targetPort: 8080    
      nodePort: 31313
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

Type이 LB인 것과, 포트 31313이 할당된 것, EXTERNAL-IP가 pending 상태인 것을 확인할 수 있다.

```shell
$ kubectl get svc    
NAME           TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes     ClusterIP      10.233.0.1      <none>        443/TCP        38h
myweb-svc-lb   LoadBalancer   10.233.19.105   <pending>     80:31313/TCP   22s
```

여기서 `EXTERNAL_IP`는 클러스터 외부이기 때문에 쿠버네티스 자체에서 할 수 없다.

클라우드를 연동하여 실제 외부에 로드 밸런서를 만들어야한다.

<br>

##### METALB - Addon

[METALB](https://metallb.universe.tf/) 오픈소스를 사용해보자.

METALB는 베타버전이지만, 실제로 프로덕션 환경에 많이 사용되며, 

국내에서도 많이 사용되는 오픈소스이다.

bare metal 시스템 k8s 클러스터에서 로드밸런서를 구현해주는 것으로,

외부에 로드밸런서 기능을 하는 파드를 띄운다.

 <br>

설치형을 사용하는 경우 직접 홈페이지 설명에 따라 METALAB을 설치할 수 있지만,

Kubespray에서 기능을 제공하므로, Kubespray를 이용해보자.

먼저 다음을 보고 kubespray 파일에서 몇가지를 수정한다.

` kubespray/inventory/mycluster/group_vars/k8s_cluster/addons.yml` 

```yaml
...
138 # MetalLB deployment
139 metallb_enabled: true #true로 수정
140 metallb_speaker_enabled: true
141 metallb_ip_range:     #주석 해제
142   - "192.168.100.240-192.168.100.249" #범위 수정
...
168 metallb_protocol: "layer2" #주석 해제
...
```

`~/kubespray/inventory/mycluster/group_vars/k8s-cluster/k8s-cluster.yml`

```shell
# configure arp_ignore and arp_announce to avoid answering ARP queries from kube-ipvs0 interface
# must be set to true for MetalLB to work
kube_proxy_strict_arp: true
```

파일을 수정 후 다시 플레이북을 다시 실행하면 된다.

```shell
$ cd kubespray
$ ansible-playbook -i inventory/mycluster/inventory.ini cluster.yml -b
```

<br>

**☁️참고**

MetalLB는 2가지 모드 `layer2`와 `BGP`모드가 있고, default는 `layer2`이다.

- [layer2](https://metallb.universe.tf/concepts/layer2/)
  - 먼저 데몬셋 형태로 모든 노드에 `speaker`라고하는 파드가 생성된다.
  - 이때, speaker와 함께 하나의 controller 파드가 설치된다.
  - NodePort가 speaker 파드로 연결되고, speaker 파드들은 controller로 연결된다.
  - controller파드가 로드밸런서 역할을 하게되는데, 앞서 설정했던 `addons.yml`의 IP 범위 `192.168.100.240-192.168.100.249` 중 하나를 로드밸런서가 사용하게된다. 
  - 외부에서 이 로드밸런서의 IP로 접속하게되면, 어느 노드든 상관없이 speaker를 통해 controller로 연결되고, controller는 다시 NodePort(여기서는 31313)로 분배해준다.
  - 그리고 NodePort가 내부의 실제 서비스로 다시 연결해준다.
  - 최종적으로 이 서비스가 다시 파드로 연결시켜준다.

 순서만 간략하게 나타내면 다음과 같다.

```shell
외부에서 접속 -> NodePort -> speaker 파드 -> controller 파드 -> NodePort -> 실제 서비스 -> 파드
```

정리하자면 로드밸런서를 외부에 두지 않고, 내부에 파드로 구현시킨 형태가 layer2라고 할 수 있다.

<img src="https://raw.githubusercontent.com/na3150/typora-img/main/img/MetaLB%20layer2.jpg" alt="MetaLB layer2" style="zoom: 50%;" />

(그림 대충 그린점 양해부탁드립니다)

- [BGP](https://metallb.universe.tf/concepts/bgp/)
  - L3스위치(스위칭 기능을 가진 라우터)를 사용하며, 이 라우터가 로드밸런싱 기능을 가진다.
  - 외부에서 라우터의 IP로 접속하면 실제 서비스로 연결 시켜준 뒤, 서비스가 파드로 연결시켜준다. 

<img src="https://blog.kakaocdn.net/dn/dAa5iv/btqZ7KXntx9/tPm90KfWoLmM22IE06SSl0/img.png" alt="img" style="zoom: 67%;" />

출처: https://cyuu.tistory.com/170

<br>

설치가 완료되면 `metallb-system`이라는 네임스페이스가 생성된 것을 확인할 수 있다.

```shell
$ kubectl get ns 
NAME              STATUS   AGE
...
metallb-system    Active   48m
```

`speaker` 파드와 `controller` 파드가 생성된 것을 확인할 수 있다.

```shell
$ kubectl get po -n metallb-system 
NAME                         READY   STATUS             RESTARTS   AGE
controller-77c44876d-dbcx5   1/1     Running            0          49m
speaker-7jgsg                0/1     ImagePullBackOff   0          49m
speaker-jkfcg                1/1     Running            0          49m
speaker-vzw82                0/1     ImagePullBackOff   0          49m
```

speaker 파드를 생성하는 데몬셋도 확인할 수 있다.

```shell
$ kubectl get ds -n metallb-system 
NAME      DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
speaker   3         3         1       3            1           kubernetes.io/os=linux   50m
```

speaker 파드에는 호스트의 IP가 부여되고, controller가 실제 로드밸런서 역할을 한다.

```shell
$ kubectl get po -n metallb-system -o wide
NAME                         READY   STATUS             RESTARTS   AGE   IP                NODE    NOMINATED NODE   READINESS GATES
controller-77c44876d-dbcx5   1/1     Running            0          52m   10.233.92.248     node3   <none>           <none>
speaker-7jgsg                0/1     Running            0          52m   192.168.100.100   node1   <none>           <none>
speaker-jkfcg                1/1     Running            0          52m   192.168.100.102   node3   <none>           <none>
speaker-vzw82                0/1     Running            0          52m   192.168.100.101   node2   <none>           <none>
```

이제 `myweb-svc-np` 서비스에 `EXTERNAL-IP`가 부여된 것을 확인할 수 있다.

```shell
$ kubectl get svc                         
NAME              TYPE           CLUSTER-IP      EXTERNAL-IP       PORT(S)        AGE
myweb-svc-lb      LoadBalancer   10.233.19.105   192.168.100.240   80:31313/TCP   3h10m
```

접속 확인

```shell
$ curl 192.168.100.240
Hello World!
myweb-rs-h8jg5
```

외부에서도 접속 가능한 것을 확인할 수 있다.

<br>

![image-20220522050955931](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220522050955931.png)

로드밸런서는 NodePort기능과 ClusterIP기능도 포함하기 때문에 NodePort로도, ClusterIP로도 접속이 가능한 것을 확인할 수 있다. 

```shell
$ curl 192.168.100.100:31313
Hello World!
myweb-rs-jwvbh
```

```shell
$ kubectl run nettool -it --image ghcr.io/c1t1d0s7/network-multitool --rm

If you don't see a command prompt, try pressing enter.
/ # curl myweb-svc-lb
Hello World!
myweb-rs-jwvbh
```

로드밸런서 확인

```shell
$ sudo ipvsadm -ln
IP Virtual Server version 1.2.1 (size=4096)
Prot LocalAddress:Port Scheduler Flags
  -> RemoteAddress:Port           Forward Weight ActiveConn InActConn
TCP  169.254.25.10:31313 rr
  -> 10.233.90.71:8080            Masq    1      0          0         
  -> 10.233.92.249:8080           Masq    1      0          0         
  -> 10.233.96.84:8080            Masq    1      0          0         
TCP  192.168.100.100:31313 rr
  -> 10.233.90.71:8080            Masq    1      0          0         
  -> 10.233.92.249:8080           Masq    1      0          0         
  -> 10.233.96.84:8080            Masq    1      0          0         
TCP  192.168.100.240:80 rr
  -> 10.233.90.71:8080            Masq    1      0          0         
  -> 10.233.92.249:8080           Masq    1      0          0         
  -> 10.233.96.84:8080            Masq    1      0          0         
...
TCP  10.233.19.105:80 rr
  -> 10.233.90.71:8080            Masq    1      0          0         
  -> 10.233.92.249:8080           Masq    1      0          0         
  -> 10.233.96.84:8080            Masq    1      0          0         
TCP  10.233.90.0:31313 rr
  -> 10.233.90.71:8080            Masq    1      0          0         
  -> 10.233.92.249:8080           Masq    1      0          0         
  -> 10.233.96.84:8080            Masq    1      0          0         
...
```

<br>

<br>

<br>

<br>