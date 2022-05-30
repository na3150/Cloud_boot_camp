# [Kubernetes] k8s minikube 설치 및 사용법



<img src="https://res.cloudinary.com/devdevil/image/upload/v1602583480/illunex_blog/2020-09-29-thumb.jpg" alt="MiniKube에서 배포해보기 – 일루넥스 블로그" style="zoom:50%;" />

<br>

[minikube](https://minikube.sigs.k8s.io/docs/start/)는 **local 시스템에 쉽게 클러스터를 구축 및 세팅할 수 있게 해주는 도구**이다.

<br>

minikube를 설치하기에 앞서 kubernetes CLI 와 docker 명령어를 설치하자. 

결과 테스트 및 실습 시 `kubectl`, `docker` 명령어를 사용하기 위함이다.

두가지 모두 chocolatey로 설치가 가능하다. 

- 윈도우에 kubernetes cli 설치하기

```shell
$ choco install kubernetes-cli --version=1.22.4
```

- 윈도우에 docker 명령어 설치하기

```shell
$ choco install docker-cli
```

<br>

#### minikube 설치

minikube 또한 다음과 같이 **choco를 사용하여 설치**할 수 있다.

```shell
$ choco install minikube
```

<br>

#### cluster 생성 및 실행

```shell
$ minikube start
```

처음으로 start하는 경우에는, k8s가 설치된 Linux 이미지를 자동으로 받고, `minikube`라는 이름의 VM을 실행한다.

 `~/.kube/config` 파일 setting까지 완료해주며, 자동으로 `kubeadm init`을 실행시킨다.

<br>

`minikube start`를 하게되면, 자동으로 minikube라는 이름의 profile이 생성된다.

이 profile에는 CPU, Memory, k8s 버전 등이 저장된다. 

```shell
$ minikube profile list
|----------|------------|---------|----------------|------|---------|---------|-------|
| Profile  | VM Driver  | Runtime |       IP       | Port | Version | Status  | Nodes |
|----------|------------|---------|----------------|------|---------|---------|-------|
| minikube | virtualbox | docker  | 192.168.59.104 | 8443 | v1.22.9 | Stopped |     1 |
|----------|------------|---------|----------------|------|---------|---------|-------|
```

<br>

minikube는 기본적으로 dynaminc provisioning을 위해 standard라는 스토리지 클래스가 존재하며,

```shell
$ kubectl get sc
NAME                 PROVISIONER                RECLAIMPOLICY   VOLUMEBINDINGMODE   ALLOWVOLUMEEXPANSION   AGE
standard (default)   k8s.io/minikube-hostpath   Delete          Immediate           false                  8h
```

기본적으로 minikube context, cluster, user가 존재한다.

```shell
$ kubectl config get-contexts
CURRENT   NAME                             CLUSTER         AUTHINFO           NAMESPACE
          kubernetes-admin@cluster.local   cluster.local   kubernetes-admin
*         minikube                         minikube        minikube           default
$ kubectl config get-clusters
NAME
cluster.local
minikube
$ kubectl config get-users
NAME
kubernetes-admin
minikube
```

<br>

`minikube start` 에는  `--memory`, `--driver`, `--nodes` 등 **다양한 옵션**이 존재한다.

```shell
$ minikube start --help
```

단, 옵션은 start 시에만 적용되기 때문에, 변경하려면 삭제 후 다시 start 해야한다.

<br>

**추가 옵션을 사용한 클러스터 생성/시작**

```shell
$ minikube start --cpus 4 --memory 4G --disk-size 30G --driver virtualbox --kubernetes-version v1.22.9
```

<br>

#### cluster 중지

```shell
$ minikube stop
```

<br>

#### cluster 상태

```shell
$ minikube status
```

<br>

#### VM 접속

```shell
$ minikube ssh
```

ssh 접속 후 `/etc/os-release` 파일을 확인하면,

```shell
$ cat /etc/os-release
```

minikube는 자체적으로 만든 os를 사용한다.

따라서 별도로 패키지 설치가 불가능하다.

또한 VM 내에 docker는 설치되어있으나, k8s 명령어는 설치되어있지 않다

- 패키지 관리자 X
- kubectl  명령 X
- docker 명령 O

<br>

#### VM 내의 Docker Engine 사용

앞서 윈도우에 docker 명령어를 설치했어야 가능하다.

```shell
$ choco install docker-cli
```

docker 서버에 접속하기 위해서는 다음과 같이 환경 변수 설정을 해야한다.

```shell
$ minikube docker-env

$Env:DOCKER_TLS_VERIFY = "1"
$Env:DOCKER_HOST = "tcp://192.168.59.100:2376" #docker host는 원격에 있다
$Env:DOCKER_CERT_PATH = "C:\Users\USER\.minikube\certs"  #인증서
$Env:MINIKUBE_ACTIVE_DOCKERD = "minikube"
# To point your shell to minikube's docker-daemon, run:
# & minikube -p minikube docker-env --shell powershell | Invoke-Expression
```

아래의 명령어를 실행하면 자동으로 docker-env 환경변수 세팅을 해준다.

```shell
$ minikube -p minikube docker-env --shell powershell | Invoke-Expression
```

단, 변수는 해당되는 터미널에서만 유용하기 때문에, 터미널 창을 닫으면 환경 변수 세팅은 없어진다.

따라서 새로 터미널 창을 실행할 때마다 해당 명령어로 환경 변수 세팅을 진행해야한다.

<br>

환경 변수 설정 후 docker 명령어를 원격에서 실행이 가능해진다.

docker 명령어가 앞서 설정한 환경 변수를 참조해서 실행하게 되는 것이다.

```shell
$ docker ps
```

<br>

#### cluster 삭제

```shell
$ minikube delete
```

VM 또한 삭제된다.

<br>

#### node 추가

```shell
$ minikube node list
$ minikube node add
```

VM을 추가로 생성하고, kubeadm join을 자동으로 진행해준다.

<br>

#### service 목록 확인

```shell
$ minikube service list
```

<br>

#### addon

minikube중 가장 좋은 기능은 addon으로, 손쉽게 addon을 추가할 수 있다.

다음 명령을 통해 minikube에서 추가할 수 있는 addon의 목록을 확인할 수 있다.

```shell
$ minikube addons list
```

disabled이 설치가 되지 않은 것이고, enabled가 설치된 것이다.

단**, addon에 따라 configure, 즉 세팅해줘야하는 경우가 있으므로 유의해서 사용**해야한다.

참고로 default-storeageclass와 storage-provisioner는 기본적으로 활성화되는 애드온이다.

<br>

**addon 설치/활성화하기**

```shell
$ minikube addons enable [addon]
```

**addon configuration**

```shell
$ minikube addons configure [addon]
```

<br>

#### 클러스터 기본 옵션 지정

start할 때마다 적용하고 싶은 옵션이 있다면, 다음과 같이 미리 세팅해둘 수 있다.

```shell
$ minikube config set cpus 2
$ minikube config set memory 4G
$ minikube config set driver virtualbox
$ minikube config set kubernetes-version v1.22.9
$ minikube config view
```

start할 때 기본적으로 설정이 적용되며, delete시 config 설정은 삭제된다.

**config 설정 확인**

```shell
$ minikube config view
```

<br>

#### **ControlPlane의 IP 확인하기**

```shell
$ minikube ip
```

<br>

#### ./minikube

`~/.minikube` 디렉토리에 minikube에 관련된 정보들이 저장된다. 

실제로 디렉토리를 들어가서 확인할 일은 잘 없고, 수정은 하지 않는 것을 권장한다.

<br>

단, minikube를 여러번 사용하다보면, 다양한 버전의 k8s이 설치되고, 

많은 tar파일들이 설치되기 때문에, 주기적으로 디렉토리를 삭제하는 것을 권장한다. 

<br>

<br>

**💻 실습 1** : nginx deployment 

테스트를 위한 간단한 cluster를 실행하고,

```shell
$ minikube start --cpus 2 --memory 4G --kubernetes-version v1.22.9
```

deployment를 배포 및 서비스를 포트포워딩한다.

```shell
$ kubectl create deployment myapp --image nginx --replicas 3
deployment.apps/myapp created
$ kubectl expose deployment myapp --name mysvc --port 80 --target-port 80
```

```shell
$ kubectl get po
NAME                     READY   STATUS    RESTARTS   AGE
myapp-6d8d776547-dfh72   1/1     Running   0          74s
myapp-6d8d776547-j889x   1/1     Running   0          74s
myapp-6d8d776547-qqsgs   1/1     Running   0          74s
```

svc의 type을 NodePort로 수정한다.

```shell
$ kubectl edit svc mysvc
```

```shell
$ kubectl get svc
NAME         TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP   10.96.0.1     <none>        443/TCP        8h
mysvc        NodePort    10.98.63.98   <none>        80:32723/TCP   4m5s
```

`minikube ip` 명령을 통해 ControlPlane의 IP를 확인하거나, 

```shell
$ minikube ip
192.168.59.104
```

`minikube service list`로 URL을 확인할 수 있다.

```shell
$ minikube service list
|-------------|------------|--------------|-----------------------------|
|  NAMESPACE  |    NAME    | TARGET PORT  |             URL             |
|-------------|------------|--------------|-----------------------------|
| default     | kubernetes | No node port |
| default     | mysvc      |           80 | http://192.168.59.104:32723 |
| kube-system | kube-dns   | No node port |
|-------------|------------|--------------|-----------------------------|
```

<br>

접속 확인

<br>

![image-20220530204446597](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220530204446597.png)

<br>

<br>

**💻 실습 2** : minikube로 metrics-server 설치하기

metrics-server를 활성화한다.

```shell
$ minikube addons enable metrics-server
    ▪ Using image k8s.gcr.io/metrics-server/metrics-server:v0.4.2
🌟  'metrics-server' 애드온이 활성화되었습니다
```

metrics-server가 enable된 것을 확인할 수 있다.

```shell
$ minikube addons list
...
| metrics-server              | minikube | enabled ✅   | kubernetes
...
```

metrics-server가 설치된 것을 확인할 수 있다.

```shell
$ kubectl get po -n kube-system
NAME                               READY   STATUS    RESTARTS      AGE
coredns-78fcd69978-n49hg           1/1     Running   0             16m
etcd-minikube                      1/1     Running   0             16m
kindnet-d6lrx                      1/1     Running   0             7m51s
kindnet-vv67r                      1/1     Running   0             7m51s
kube-apiserver-minikube            1/1     Running   0             16m
kube-controller-manager-minikube   1/1     Running   0             16m
kube-proxy-57jpm                   1/1     Running   0             7m56s
kube-proxy-jlf4m                   1/1     Running   0             16m
kube-scheduler-minikube            1/1     Running   0             16m
metrics-server-77c99ccb96-m44cj    1/1     Running   0             67s
storage-provisioner                1/1     Running   1 (16m ago)   16m
```

metrics서버가 설치되고, CPU 사용량이 측정되는 것을 확인할 수 있다.

```shell
$ kubectl top nodes
NAME       CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
minikube   136m         6%     1279Mi          32%
```

<br>

<br>

**💻 실습 3** : minikube로 metallb 설치하기

실습1에 이어서 서비스의 type을 LoadBalancer로 수정한다.

```shell
$ kubectl edit svc mysvc
service/mysvc edited
```

다음으로 metallb를 활성화한다.

```shell
$ minikube addons enable metallb
    ▪ Using image metallb/controller:v0.9.6
    ▪ Using image metallb/speaker:v0.9.6
🌟  'metallb' 애드온이 활성화되었습니다
```

```shell
$ kubectl get all -n metallb-system
NAME                              READY   STATUS    RESTARTS   AGE
pod/controller-66bc445b99-nkldf   1/1     Running   0          2m24s
pod/speaker-xcrzl                 1/1     Running   0          2m24s

NAME                     DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR                 AGE
daemonset.apps/speaker   1         1         1       1            1           beta.kubernetes.io/os=linux   2m24s

NAME                         READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/controller   1/1     1            1           2m24s

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/controller-66bc445b99   1         1         1       2m24s
```

그러나 시간이 지나도 EXTERNAL-IP가 계속 pending 상태이다. 즉, metallb가 제대로 작동하지 않는다는 뜻이다.

```shell
$ kubectl get svc
NAME         TYPE           CLUSTER-IP    EXTERNAL-IP   PORT(S)        AGE
kubernetes   ClusterIP      10.96.0.1     <none>        443/TCP        9h
mysvc        LoadBalancer   10.98.63.98   <pending>     80:32723/TCP   30m
```

앞서 설명했듯이 addon은 enable된다고해서 모두 작동되는 것은 아니다. 

addon에 따라 configure, 즉 세팅해줘야하는 경우가 있는데, 그중에 하나로 바로 metallb이다.

[여기](https://github.com/kubernetes-sigs/kubespray )에서도 확인할 수 있듯이 metallb에 사용할 네트워크 대역을 configure로 세팅해줘야 제대로 작동한다.

<br>

따라서 metallb configuration을 진행한다.

```shell
$ minikube addons configure metallb
```

여기서 중요한 것은, 아무 IP나 선택하면 안되고, 

```shell
$ minikube ip
192.168.59.105
```

`minikube ip` 로 확인한 ip 주소를 참고하여 네트워크 대역을 설정해주어야 한다.

```shell
$ minikube addons configure metallb
-- Enter Load Balancer Start IP: 192.168.59.200
-- Enter Load Balancer End IP: 192.168.59.209
    ▪ Using image metallb/speaker:v0.9.6
    ▪ Using image metallb/controller:v0.9.6
✅  metallb 이 성공적으로 설정되었습니다
```

configuration 완료 후, 실제로 metallb에는 이 설정이 configMap으로 저장된다.

컨피그맵 `config`가 생성된 것을 확인할 수 있고, 

```shell
$ kubectl get cm -n metallb-system
NAME               DATA   AGE
config             1      64s
kube-root-ca.crt   1      64s
```

describe 명령어로 확인해보면, 세팅한 네트워크 대역으로 설정된 것을 확인할 수 있다.

```shell
$ kubectl describe cm -n metallb-system config
Name:         config
Namespace:    metallb-system
Labels:       <none>
Annotations:  <none>

Data
====
config:
----
address-pools:
- name: default
  protocol: layer2
  addresses:
  - 192.168.59.200-192.168.59.209


BinaryData
====

Events:  <none>
```

`mysvc`를 확인하면 EXTERNAL-IP가 설정된 것을 확인할 수 있다.

```shell
$ kubectl get svc
NAME         TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE
kubernetes   ClusterIP      10.96.0.1       <none>           443/TCP        5m10s
mysvc        LoadBalancer   10.96.203.220   192.168.59.200   80:30257/TCP   4m54s
```

<br>

EXTERNAL-IP로 접속 확인

<br>

![image-20220530214911134](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220530214911134.png)

<br>

meteallb가 정상적으로 작동하는 것을 확인할 수 있다.

<br>

<br>

실습 

