# [Kubernetes] Worker Node 추가 구성하기 : Join

본 글은 [여기](https://nayoungs.tistory.com/176)에 이어서 진행한다.

`Vagrant`를 통해 `Worker Node`로 사용할 1대의 VM을 구축한 뒤, ` k8s` 관련 패키지들을 설치 및 설정하고

`Control Plane`과 `Worker Node`가 동시에(1대에) 구축되어 있던 기존의 VM에 새로 구축한 `Worker Node`를 `join`할 예정이다.

<br>

<br>

### 📌Index

- [VM 생성하기](#vm-생성하기)
- [Docker 설치 및 설정하기](#docker-설치-및-설정하기)
- [kubeadm, kubelet, kubectl 설치하기](#kubeadm-kubelet-kubectl-설치하기)
- [K8s Cluster에 Join하기](#k8s-cluster에-join하기)

<br>

<br>

## ✔️ VM 생성하기

`Vagrantfile`을 사용하여 `ubuntu` VM을 생생하자.

```yaml
Vagrant.configure("2") do |config| 
    # Control Plane과 Worker Node가 동시에 구축된 기존의 VM 
    config.vm.define "docker" do |centos|
    config.vm.boot_timeout = 1800
        centos.vm.box = "ubuntu/focal64"
        centos.vm.hostname = "docker"
        centos.vm.network "private_network", ip: "192.168.100.100"
        centos.vm.provider "virtualbox" do |vb|
            vb.name = "docker"
            vb.cpus = 2
            vb.memory = 4096    
        end
    end

    # Worker Node로 구성할 새로운 VM
    config.vm.define "worker" do |centos|
    config.vm.boot_timeout = 1800
        centos.vm.box = "ubuntu/focal64"
        centos.vm.hostname = "worker"
        centos.vm.network "private_network", ip: "192.168.100.101"
        centos.vm.provider "virtualbox" do |vb|
            vb.name = "worker"
            vb.cpus = 2
            vb.memory = 4096    
        end
    end
end
```

`Vagrantfile`이 존재하는 디렉토리로 이동하여 다음 명령을 실행하자.

```shell
vagrant up worker
```

<br>

<br>

## ✔️ Docker 설치 및 설정하기

앞서 구축한 VM에 SSH 접속 후 Docker 설치 및 설정을 진행한다. 

<br>

```
$ sudo apt-get update
```

```
$ sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release
```

```
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```

```
$ echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```

```
$ sudo apt-get update
```

```
$ sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```

docker가 1.22 버전으로 오면서 ` cgroupfs`를 지원하지 않게되었다.

```
$ sudo docker info | grep 'Cgroup Driver'
 
 Cgroup Driver: cgroupfs
```

만약 `Cgoup Driver`가 `cgroups`로 설정되어있다면 `/etc/docker/daemon.json`을 다음과 같이 작성한다.

`/etc/docker/daemon.json`

```
{
  "exec-opts": ["native.cgroupdriver=systemd"]
}
```

```shell
$ sudo systemctl restart docker
```

 `Cgoup Driver`가 `cgroups` 에서 `systemd` 로 변경된 것을 확인할 수 있다.

```
$ docker info | grep 'Cgroup Driver'

 Cgroup Driver: systemd
```

```
$ sudo systemctl daemon-reload
```

```
$ sudo usermod -aG docker vagrant
```

그룹에 `docker`를  추가한 것을 적용하기 위해, `exit` 한 뒤에 재접속한다.

```shell
$ exit
```

<br>

<br>

## ✔️ kubeadm, kubelet, kubectl 설치하기

- `kubeadm`: 클러스터를 부트스트랩하는 명령
- `kubelet`: 클러스터의 모든 머신에서 실행되는 파드와 컨테이너 시작과 같은 작업을 수행하는 컴포넌트(`kubelet`, `k-proxy`)
- `kubectl`: 클러스터와 통신하기 위한 커맨드 라인 유틸리티(클리이언트)

<br>

```
$ sudo apt-get install -y apt-transport-https ca-certificates curl
```

```
$ sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
```

```
$ echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
```

```
$ sudo apt-get update
```

```
$ sudo apt-get install kubeadm=1.22.8-00 kubelet=1.22.8-00 kubectl=1.22.8-00 -y
```

패키지 업데이트 시 쿠버네티스까지 업데이트되면 안되기때문에 `apt-mark hold`로 잠금해준다.

```shell
$ sudo apt-mark hold kubelet kubeadm kubectl
```

<br>

<br>

## ✔️K8s Cluster에 Join하기

[join nodes](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#join-nodes)에 따라 진행해보자.

<br>

#### Joining your nodes

 클러스터에 새 노드를 추가하려면 각 머신에 대해 다음 사항들을 만족해야한다. 

- SSH to the machine
- Become root (e.g. `sudo su -`)
- [Install a runtime](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/#installing-runtime) if needed
- Run the command that was output by `kubeadm init`. For example:

```shell
$ kubeadm join --token <token> <control-plane-host>:<control-plane-port> --discovery-token-ca-cert-hash sha256:<hash>
```

<br>

**토큰 목록 확인하기**

```shell
$ kubeadm token list
```

**토큰은 24시간만 유효**하고,  

따라서 24시간전에 생성한 토큰이라면 만료되어서 목록에서 확인할 수 없다.

<br>

**토큰 생성하기**

```shell
$ kubeadm token create
```

토큰을 생성한 뒤 생성된 토큰을 토큰 목록에서 확인할 수 있다.

```shell
$ kubeadm token list  
TOKEN                     TTL         EXPIRES                USAGES                   DESCRIPTION                                                EXTRA GROUPS
u3odgd.idt2ukfxqqbo8j31   23h         2022-05-17T00:44:09Z   authentication,signing   <none>                                                     system:bootstrappers:kubeadm:default-node-token
```

**토큰 해시값 확인하기**

```shell
$ openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //'
```

<br>

`etc/kubernetes/pki`에는 클러스터 내의 각 구성요소들의 CA 키와 인증서들이 존재한다.

```shell
$ ls  /etc/kubernetes/pki           
apiserver-etcd-client.crt     apiserver.crt  etcd                    front-proxy-client.key
apiserver-etcd-client.key     apiserver.key  front-proxy-ca.crt      sa.key
apiserver-kubelet-client.crt  ca.crt         front-proxy-ca.key      sa.pub
apiserver-kubelet-client.key  ca.key         front-proxy-client.crt
```

<br>

#### join 하기

```shell
$ sudo kubeadm join --token <token> <control-plane-host>:<control-plane-port> --discovery-token-ca-cert-hash sha256:<hash>
```

`control-plane-port` : 컨트롤 플레인 노드의 쿠버네티스 apiserver의 포트번호로, 기본적으로 6443을 사용한다.

<br>
알맞은 값을 넣어 join 명령을 실행한 뒤 성공하면 다음과 같은 결과를 확인할 수 있다.

```shell
This node has joined the cluster:
* Certificate signing request was sent to apiserver and a response was received.
* The Kubelet was informed of the new secure connection details.

Run 'kubectl get nodes' on the control-plane to see this node join the cluster.
```

`Control Plane`에서 `kubectl get nodes` 명령을 실행하면, `worker` 노드가 정상적으로 `join`된 것을 확인할 수 있다.

```shell
$ kubectl get nodes
NAME     STATUS   ROLES                  AGE     VERSION
docker   Ready    control-plane,master   41h     v1.22.8
worker   Ready    <none>                 3m30s   v1.22.8
```

참고로 `worker` 노드는 역할(`ROLES`)에 아무것도 붙으면 안된다.

<br>

`join` 후 시간이 흐른 뒤, `kubectl get pods -A` 명령 시 모든 것들이 `Running`상태이고, `READY`가 `1/1` 이 되었다면, 정상적으로 워커노드는 `Ready` 상태가 된 것이다. 

```shell
$ kubectl get pods -A 
NAMESPACE          NAME                                       READY   STATUS    RESTARTS         AGE
calico-apiserver   calico-apiserver-5f79f45d44-l6sx4          1/1     Running   2 (108m ago)     45h
calico-apiserver   calico-apiserver-5f79f45d44-w4g8m          1/1     Running   2 (108m ago)     45h
calico-system      calico-kube-controllers-5d74cd74bc-t7xwr   1/1     Running   2 (108m ago)     45h
calico-system      calico-node-fpqnj                          0/1     Running   3 (107m ago)     45h
calico-system      calico-node-v5mnw                          0/1     Running   0                4h19m
calico-system      calico-typha-69974c84d7-z9rdf              1/1     Running   4 (108m ago)     45h
kube-system        coredns-78fcd69978-kk922                   1/1     Running   2 (108m ago)     46h
kube-system        coredns-78fcd69978-w4jg2                   1/1     Running   2 (108m ago)     46h
kube-system        etcd-docker                                1/1     Running   4 (108m ago)     46h
kube-system        kube-apiserver-docker                      1/1     Running   4 (108m ago)     46h
kube-system        kube-controller-manager-docker             1/1     Running   4 (108m ago)     46h
kube-system        kube-proxy-qqnnd                           1/1     Running   0                4h19m
kube-system        kube-proxy-qrbcs                           1/1     Running   3 (108m ago)     46h
kube-system        kube-scheduler-docker                      1/1     Running   4 (108m ago)     46h
tigera-operator    tigera-operator-7cf4df8fc7-r4stp           1/1     Running   429 (108m ago)   45h
```

