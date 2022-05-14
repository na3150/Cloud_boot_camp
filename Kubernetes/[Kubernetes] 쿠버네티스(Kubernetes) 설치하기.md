# [Kubernetes] 쿠버네티스(K8s) 설치하기 : Kubeadm

쿠버네티스(K8s)를 설치하는 방법은 수십가지가 넘는다.

가장 일반적인 /핵심적인 방법은 다음과 같다

- `Kubeadm` : 표준 방법이나, 자동화가 불가능해서 관리는 힘들다
- `Kubespray` : `Kubeadm` + `Ansible` 방식
- `kOps` : 쿠버네티스를 AWS EC2에 설치해줌
- `Docker Desktop` : 쿠버네티스의 가장 기본 기능만 사용 가능함
- `minikube` : local에 VM으로 쿠버네티스를 구성(가장 많이 사용하는 방법), 멀티노드도 지원함

참고로 쿠버네티스는 버전이 3개월 마다 1번씩 나오고, 유지보수는 4개 버전만 한다.

따라서 쿠버네티스는 최소한 1년에 한번씩 업데이트를 해주어야한다. 

<br>

<br>

[Kubeadm으로 클러스터 구성하기](https://kubernetes.io/ko/docs/setup/production-environment/tools/kubeadm/)에 따라 진행해보자.

만약에 진행 도중 오류가 난다면 바로 구글링하지 말고 https://github.com/kubernetes/kubernetes을 참조해보자.

여기서 `issues`를 확인해보면서 이해하는 것이 좋다.

<br>

#### [Kubeadm 설치하기](https://kubernetes.io/ko/docs/setup/production-environment/tools/kubeadm/install-kubeadm/)

원래 가장 먼저 런타임을 설치해야하는데, 글쓴이는 Docker가 이미 설치되어있어서

생략하고 넘어간다. Docker 설치에 대한 방법은 [여기](https://nayoungs.tistory.com/149?category=1277797)를 참조하면 된다!

<br>

**kubeadm, kubelet, kubectl 도구 설치**

- `kubeadm`: 클러스터를 부트스트랩하는 명령
- `kubelet`: 클러스터의 모든 머신에서 실행되는 파드와 컨테이너 시작과 같은 작업을 수행하는 컴포넌트(`kubelet`, `k-proxy`)
- `kubectl`: 클러스터와 통신하기 위한 커맨드 라인 유틸리티(클리이언트)

<br>

1. `apt` 패키지를 업데이트하고, 쿠버네티스 `apt` 리포지터리를 사용하는 데 필요한 패키지를 설치한다.

```shell
$ sudo apt-get update
$ sudo apt-get install -y apt-transport-https ca-certificates curl
```

2. 구글 클라우드의 공개 사이닝 키(서명키)를 다운로드한다.

```shell
$ sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
```

3. 쿠버네티스 `apt` 리포지터리를 추가한다. 

```shell
$ echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

확인

```shell
$ cat /etc/apt/sources.list.d/kubernetes.list
deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main
```

4. `apt` 패키지를 업데이트(리포지토리를 추가했으므로)한 뒤,`kubelet`, `kubeadm`, `kubectl`을 설치하고 해당 버전을 고정한다.
   - 버전을 지정하지 않으면 항상 최신 버전을 설치하게 된다.
   - `kubeadm` 버전 확인하기 : `apt-cache madison kubeadm `
   - `kubelet`, `kubeadm`, `kubectl`을 설치하느냐가 `K8s`의 버전을 결정한다.
   - 패키지 업데이트시 쿠버네티스까지 업데이트되면 안되기때문에 `apt-mark hold`로 잠금해준다.

```shell
$ sudo apt-get update # 저장소 추가했으니까 업데이트
$ sudo apt-get install kubeadm=1.22.8-00 kubelet=1.22.8-00 kubectl=1.22.8-00
$ sudo apt-mark hold kubelet kubeadm kubectl
```

<br>

<br>

#### [K8s 클러스터 생성하기](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)

**kubeadm init**

- `--control-plane-endpoint` : VM의 주소
- `--pod-network-cidr` : 네트워크가 사용할 네트워크 대역을 지정
- `--apiserver-advertise-address` : `api-server`의 주소를 결정

```bash
$ sudo kubeadm init --control-plane-endpoint 192.168.100.100 --pod-network-cidr 172.16.0.0/16 --apiserver-advertise-address=192.168.100.100
```

만약 다음과 같은 오류가 발생한다면❔

```
 This error is likely caused by:
                - The kubelet is not running
                - The kubelet is unhealthy due to a misconfiguration of the node in some way (required cgroups disabled)
```

--- 접은글

**cgroup driver 오류**

docker가 `1.22` 버전으로 오면서 `cgroupfs`를 지원하지 않는다고한다.

```shell
$ docker info | grep 'Cgroup Driver'
 
 Cgroup Driver: cgroupfs
```

해결방법: `/etc/docker/daemon.json` 파일을 생성(`sudo`로)하고 system을 재시작한 뒤 `kubelet`재시작

`/etc/docker/daemon.json`

```shell
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
```

```shell
$ sudo systemctl restart docker
```

```shell
$ docker info | grep 'Cgroup Driver'

 Cgroup Driver: systemd
```

```shell
$ sudo systemctl daemon-reload && sudo systemctl restart kubelet
```

여기서 바로 다시 위의 `kumeadm init` 명령을 실행하면 안되고, `reset` 한 뒤 진행해줘야한다.

```shell
$ sudo kubeadm reset
```

이제 `kumeam init`을 다시 진행하면 정상적으로 진행될 것이다.

<br>

<br>

**인증파일 생성**

```shell
$ mkdir -p $HOME/.kube
$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
$ sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

쿠버네티스에 인증하기 위한 파일로, 절대 노출되면 안된다.

확인

```shell
$ kubectl get nodes
NAME     STATUS     ROLES                  AGE   VERSION
docker   NotReady   control-plane,master   17m   v1.22.8
```

여기서 오류가 나온다면 인증 파일 복사가 제대로 안된 것이다.

<br>

**Calico Network Add-on**

[Cluster Networking | Kubernetes](https://kubernetes.io/docs/concepts/cluster-administration/networking/#how-to-implement-the-kubernetes-networking-model)

`kubeadm init` 명령시 `add-on`을 완성하지 않았었기 때문에, 구성을 마무리해줘야한다. 여기서는 [`calio`]([About Calico (tigera.io)](https://projectcalico.docs.tigera.io/about/about-calico))방식을 사용할 예정이다.

[Install Calico networking and network policy for on-premises deployments (tigera.io)](https://projectcalico.docs.tigera.io/getting-started/kubernetes/self-managed-onprem/onpremises)를 참조하여 `calico`를 설치하자.

- cluster에 operator를 설치한다.

```shell
$ kubectl create -f https://projectcalico.docs.tigera.io/manifests/tigera-operator.yaml
```

- custom 리소스 다운 및 수정

```shell
$ curl https://projectcalico.docs.tigera.io/manifests/custom-resources.yaml -O
```

현재 디렉토리의 `custom-resources.yaml `파일 수정

`kubeadm init` 명령시 설정했던 pod의 cidr와 동일하게 맞춰줘야한다.

```yaml
...
cidr: 172.16.0.0/16
...
```

- `calio` 설치

```shell
$ kubectl create -f custom-resources.yaml
```

<br>

**pod의 목록 확인하기**

모두 `Running` 상태가 되어야한다.

```shell
$ watch kubectl get pods -A
```

```shell
NAMESPACE          NAME                                       ...
calico-apiserver   calico-apiserver-c9565f67b-2p29k           ...
calico-apiserver   calico-apiserver-c9565f67b-slthl           ...
calico-system      calico-kube-controllers-5d74cd74bc-sg7dn   ...
calico-system      calico-node-tgxks                          ...
calico-system      calico-typha-7447fdc844-txrdb              ...
kube-system        coredns-78fcd69978-4ztkq                   ...
kube-system        coredns-78fcd69978-jpwxx                   ...
kube-system        etcd-docker                                ...
kube-system        kube-apiserver-docker                      ...
kube-system        kube-controller-manager-docker             ...
kube-system        kube-proxy-5st98                           ...
kube-system        kube-scheduler-docker                      ...
tigera-operator    tigera-operator-7cf4df8fc7-kx87z           ...
```

또한 node가 `Ready`상태가 되어야한다.

```shell
$ kubectl get nodes        
NAME     STATUS   ROLES                  AGE   VERSION
docker   Ready    control-plane,master   38m   v1.22.8
```

<br>

**격리 해제하기**

`control plane`과 `node`를 한대에 구성한 경우, 컨테이너가 실행하지 못하도록 격리가 되어있는 것을 풀어줘야한다. 

```shell
$ kubectl taint node docker node-role.kubernetes.io/master-
```

여기까지 모두 완료가 되었다면 1대 구성이 끝난 것이다!

<br>

<br>

## 📋실습

앞선 과정에 이어서 `myweb` 이라는 간단한 서비스를 배포해보자

<br>

먼저 이미지를 받아온다.

```shell
$ kubectl create deployment myweb --image=ghcr.io/c1t1d0s7/go-myweb
```

확인

```shell
$ kubectl get deployments,replicasets,pods
NAME                    READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/myweb   1/1     1            1           5m33s

NAME                              DESIRED   CURRENT   READY   AGE
replicaset.apps/myweb-97dbf5749   1         1         1       5m33s

NAME                        READY   STATUS    RESTARTS   AGE
pod/myweb-97dbf5749-44tqx   1/1     Running   0          5m33s
```

pod가 `Running` 상태가 되어있어야한다.

- `pod`는 하나의 컨테이너이다.
- `replicaset` : 컨테이너를 복사하는 것
- `deployment` : `replicaset`를 복제해주는 것

<br>
쿠버네티스는 도커와 달리 포트포워딩을 하지 않아도 된다.

다음 명령을 통해 `pod`를 외부에 노출시킬 수 있다. 

- `expose`는 서비스이다.

```shell
$ kubectl expose deployment myweb --port=80 --protocol=TCP --target-port=8080 --name myweb-svc --type=NodePort
```

배포된 서비스를 확인해보자.

- `myweb-svc`는 로드밸런서의 역할을 한다.

```shell
$ kubectl get services
NAME         TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1       <none>        443/TCP        59m
myweb-svc    NodePort    10.101.117.78   <none>        80:30868/TCP   35s
```

`myweb-svc`의 포트를 확인하여 실제로 접속해보자! (포트는 랜덤이다)

![image-20220515014421448](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220515014421448.png)

```shell
$ curl 192.168.100.100:30868
Hello World!
myweb-97dbf5749-44tqx
```

<br>

다음으로 `pod`의 개수를 늘려보자

```shell
$ kubectl scale deployment myweb --replicas=3
```

```shell
$ kubectl get pods                           
NAME                    READY   STATUS    RESTARTS   AGE
myweb-97dbf5749-2shq4   1/1     Running   0          8s
myweb-97dbf5749-44tqx   1/1     Running   0          13m
myweb-97dbf5749-lplw5   1/1     Running   0          8s
```

생성된 pod에는 오토 스케일링 기능이 자동으로 되며, `curl` 명령어로 부한 분산(라운드 로빈)되는 것을 확인해볼 수 있다.

```shell
$ curl 192.168.100.100:30868
Hello World!
myweb-97dbf5749-44tqx
$ curl 192.168.100.100:30868
Hello World!
myweb-97dbf5749-lplw5
$ curl 192.168.100.100:30868
Hello World!
myweb-97dbf5749-2shq4
```

마지막으로 배포한 서비스를 삭제해보자.

```shell
$ kubectl delete service myweb-svc
$ kubectl delete deployment myweb
```

이번 실습은 명령어로 진행했으나, 실제로는 일반적으로 `yaml` 파일로 작업한다.

<br>

<br>

<br>

<br>

쿠버네티스를 어렵게 설치하는 방법 👉  https://github.com/kelseyhightower/kubernetes-the-hard-way  : 어렵지만, 쿠버네티스의 동작원리(본질)를 알기에 좋다.