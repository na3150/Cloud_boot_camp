# [Kubernetes] k8s Volume (1) : emptyDir, initContainer, hostPath

컨테이너 내의 디스크에 있는 파일 및 데이터들은 임시적이며, 컨테이너(파드)를 지워버리면 기본적으로 데이터들은 모두 사라지게된다.

따라서 별도의 라이프사이클을 가지고 있는 오브젝트(리소스)가 필요하고,

이를 위해 사용하는 것이 바로 [볼륨(Volume)](https://kubernetes.io/ko/docs/concepts/storage/volumes/)이다.
<br>

<img src="https://d33wubrfki0l68.cloudfront.net/aecab1f649bc640ebef1f05581bfcc91a48038c4/728d6/images/docs/pod.svg" alt="파드 생성 다이어그램" width=300/>

<br>

파드에 볼륨을 제공하게되면, 파드에 있는 모든 컨테이너는 해당 볼륨을 사용가능하다.

<br>

`spec.volumes.*`: 볼륨 유형

- 볼륨의 유형에 따라 Field는 모두 다르다.

```shell
$ kubectl explain pod.spec.volumes           
```

`spec.containers.volumeMounts`

- readOnly지정이 가능하며, default는 read-write이다.

```shell
$ kubectl explain pods.spec.containers.volumeMounts
...
   mountPath    <string> -required-
     Path within the container at which the volume should be mounted. Must not
     contain ':'.

   mountPropagation     <string>
     mountPropagation determines how mounts are propagated from the host to
     container and the other way around. When not set, MountPropagationNone is
     used. This field is beta in 1.10.

   name <string> -required-
     This must match the Name of a Volume.

   readOnly     <boolean>
     Mounted read-only if true, read-write otherwise (false or unspecified).
     Defaults to false.

   subPath      <string>
     Path within the volume from which the container's volume should be mounted.
     Defaults to "" (volume's root).

   subPathExpr  <string>
     Expanded path within the volume from which the container's volume should be
     mounted. Behaves similarly to SubPath but environment variable references
     $(VAR_NAME) are expanded using the container's environment. Defaults to ""
     (volume's root). SubPathExpr and SubPath are mutually exclusive.
```

<br>

<br>

## emptyDir

`emptyDir` 볼륨은 파드가 노드에 할당될 때 처음 생성되며, 해당 노드에서 파드가 실행되는 동안에만 존재한다. 

`emptyDir` 볼륨은 처음에는 비어있으며,  파드 내 모든 컨테이너는 `emptyDir` 볼륨에서 동일한 파일을 읽고 쓸 수 있지만, 

해당 볼륨은 각각의 컨테이너에서 동일하거나 다른 경로에 마운트될 수 있다. 

어떤 이유로든 노드에서 파드가 제거되면 `emptyDir` 의 데이터가 영구적으로 삭제된다.

<br>

볼륨(Volume)은 일반적으로 파드와 라이프사이클을 별개로 사용하기위해 구성하나,

**emptyDir는 파드의 라이프 사이클과 함께한다. 즉, 임시로 사용하기 위한 용도로 이용**한다. 

<br>

emtyDir의 용도

- 디스크 기반의 병합 종류와 같은 스크레치 공간
- 충돌로부터 복구하기 위해 긴 계산을 검사점으로 지정
- 웹 서버 컨테이너가 데이터를 처리하는 동안 컨텐츠 매니저 컨테이너가 가져오는 파일을 보관

<br>

`pods.spec.volumes.emptyDir`

- `medium` : 아무 것도 없는 default(local의 Disk) 또는 Memory(Ram Disk, 고속의 엔진 스토리지)
- `sizeLimit`

```shell
$ kubectl explain pods.spec.volumes.emptyDir
KIND:     Pod
VERSION:  v1

RESOURCE: emptyDir <Object>

DESCRIPTION:
     EmptyDir represents a temporary directory that shares a pod's lifetime.
     More info: https://kubernetes.io/docs/concepts/storage/volumes#emptydir

     Represents an empty directory for a pod. Empty directory volumes support
     ownership management and SELinux relabeling.

FIELDS:
   medium       <string>
     What type of storage medium should back this directory. The default is ""
     which means to use the node's default medium. Must be an empty string
     (default) or Memory. More info:
     https://kubernetes.io/docs/concepts/storage/volumes#emptydir

   sizeLimit    <string>
     Total amount of local storage required for this EmptyDir volume. The size
     limit is also applicable for memory medium. The maximum usage on memory
     medium EmptyDir would be the minimum value between the SizeLimit specified
     here and the sum of memory limits of all containers in a pod. The default
     is nil which means that the limit is undefined. More info:
     http://kubernetes.io/docs/user-guide/volumes#emptydir
```

<br>

**💻 실습** 

emptyDir는 임시로 사용할 빈 볼륨으로, 파드 삭제 시 볼륨도 함께 삭제된다.

`myweb-pod.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: myweb-pod
spec:
  containers:
    - name: myweb1
      image: httpd
      volumeMounts:
        - name: emptyvol
          mountPath: /empty #마운트할 위치, 디렉토리가 없으면 자동으로 만들어준다.
    - name: myweb2
      image: ghcr.io/c1t1d0s7/go-myweb:alpine
      volumeMounts:
        - name: emptyvol
          mountPath: /empty #마운트할 위치
  volumes: #리스트 형태로 여러개를 작성할 수 있다.
    - name: emptyvol
      emptyDir: {} #아무것도 세팅하지 않는 다는 의미
```

**`volumeMounts.name`과 `volumes.name`은 매칭이 되어야한다** ⭐

다음과 같이 실행된 것을 확인할 수 있다.

```shell
$ kubectl get pods          
NAME        READY   STATUS    RESTARTS   AGE
myweb-pod   2/2     Running   0          16s
```

`kubectl describe`명령을 통해 상세 정보를 확인해보자.

```shell
$ kubectl describe po myweb-pod 
...
Containers:
  myweb1:
    Container ID:   containerd://559ed2aed61e7bb37052d02b9592ece2125a96ffe2d85e7acb66d1a41a26f65d
    Image:          httpd
    Image ID:       docker.io/library/httpd@sha256:2d1f8839d6127e400ac5f65481d8a0f17ac46a3b91de40b01e649c9a0324dea0
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Mon, 23 May 2022 17:20:59 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts: #마운트 확인
      /empty from emptyvol (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-5hdfs (ro)
  myweb2:
    Container ID:   containerd://b800f31bf16ccb08dc141a80a44492b175e15533f2a38be7cdf1f812fdb1c702
    Image:          ghcr.io/c1t1d0s7/go-myweb:alpine
    Image ID:       ghcr.io/c1t1d0s7/go-myweb@sha256:925dd88b5abbe7b9c8dbbe97c28d50178da1d357f4f649c6bc10a389fe5a6a55
    Port:           <none>
    Host Port:      <none>
    State:          Running
      Started:      Mon, 23 May 2022 17:20:59 +0000
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts: #마운트 확인
      /empty from emptyvol (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-5hdfs (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  emptyvol:
    Type:       EmptyDir (a temporary directory that shares a pod's lifetime) #EmptyDir 확인,파드의 라이프타임을 공유 -> 파드가 지워지면 볼륨도 함께 삭제된다.
    Medium:     
    SizeLimit:  <unset>
  kube-api-access-5hdfs:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    ConfigMapOptional:       <nil>
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type    Reason     Age   From               Message
  ----    ------     ----  ----               -------
  Normal  Scheduled  63s   default-scheduler  Successfully assigned default/myweb-pod to node3
  Normal  Pulling    62s   kubelet            Pulling image "httpd"
  Normal  Pulled     60s   kubelet            Successfully pulled image "httpd" in 1.94853979s
  Normal  Created    60s   kubelet            Created container myweb1
  Normal  Started    60s   kubelet            Started container myweb1
  Normal  Pulled     60s   kubelet            Container image "ghcr.io/c1t1d0s7/go-myweb:alpine" already present on machine
  Normal  Created    60s   kubelet            Created container myweb2
  Normal  Started    60s   kubelet            Started container myweb2
```

파드에 직접 접속해보자.

루트(/) 밑에 `/empty` 디렉토리가 만들어진 것을 확인할 수 있다.

```shell
$ kubectl exec -it myweb-pod -c myweb1 -- bash
root@myweb-pod:/# ls
bin   dev    etc   lib    media  opt   root  sbin  sys  usr
boot  empty  home  lib64  mnt    proc  run   srv   tmp  var
```

`empty/` 디렉토리의 파일 a, b, c를 생성해보자.

```shell
root@myweb-pod:/# cd empty/
root@myweb-pod:/empty# touch a b c
root@myweb-pod:/empty# ls
a  b  c
```

`myweb2`에 접속하면, `/empty` 디렉토리에 파일 a, b, c가 존재하는 것을 확인할 수 있다. 

참고 : myweb2는 alphine이기 때문에 bash가 없고, sh로 실행해야한다.

```shell
$ kubectl exec -it myweb-pod -c myweb2 -- sh 
/ # ls /empty/
a  b  c
```

즉, **동일한 파드 내의 컨테이너들이 같은 볼륨을 공유**하고 있는 것을 확인할 수 있다.

<br>

<br>

## initContainer(초기화 컨테이너)

initContainer를 살펴보기 전에, gitRepo를 먼저 살펴보자.

<br>

[gitRepo](https://kubernetes.io/ko/docs/concepts/storage/volumes/#gitrepo)는 기본적으로 **EmptyDir와 기능이 같으나, git 저장소를 동기화**할 수 있다.

EmptyDir는 비어있는 것을 처음 사용하지만, gitRepo는 EmptyDir 동일한 형태이나

**git 레포지토리에 있는 데이터를 채워서(복제해서) 파드에게 제공**한다. 

그러나 gitRepo는 사용 중지되었고, 상당히 많이 사용되는 기능이었다.

gitRepo를 대체할 수 있는 유일한 방법이 바로 초기화컨테이너(initContainer)이다.

<br>

##### ⭐초기화 컨테이너(initContainer)⭐

**파드가 생성될 때, 단 1번만 실행되고, 종료**한다.

실행되는 애플리케이션은 반드시 종료되는 애플리케이션이어야하며,

VM의 user-data와 유사한 성격을 가지고있다.

다음 실습으로 gitRepo의 기능을 initContainer를 통해 달성해보자.

<br>

**💻 실습**

`init-pod.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-pod
spec:
  initContainers:
    - name: gitpull
      image: alpine/git
      args:
        - clone # git에서 코드를 가져온다
        - -b
        - v2.18.1
        - https://github.com/kubernetes-sigs/kubespray.git
        - /repo #volueMounts의 mountPath와 매칭
      volumeMounts:
        - name: gitrepo
          mountPath: /repo
  containers:
    - name: gituse
      image: busybox
      args:  #sh을 계속(무한대로)실행시키기 위한 방법 tail -f /dev/null
        - tail
        - -f
        - /dev/null
      volumeMounts:
        - name: gitrepo
          mountPath: /kube #마운트 위치 : /kube 디렉토리로 파일들이 복사된다.
  volumes:
    - name: gitrepo
      emptyDir: {}
```

```shell
$ kubectl create -f init-pod.yaml
```

watch로 확인해보면, `init-pod`가 실행되고, 완료된 뒤에 종료된다.

init-pod의 STATUS : `Init` --> `PodInitializing` --> `Running`

```shell
$ watch kubectl get po                                 k8s-node1: Mon May 23 17:53:06 2022

NAME        READY   STATUS     RESTARTS   AGE
init-pod    0/1     Init:0/1   0          11s
myweb-pod   2/2     Running    0          32m
$ kubectl get pods                               k8s-node1: Mon May 23 18:01:16 2022

NAME        READY   STATUS    RESTARTS        AGE
init-pod    1/1     Running   0               8m21s
myweb-pod   2/2     Running   2 (2m33s ago)   40m
```

직접 `init-pod`에 접속해서 `/kube` 디렉토리를 확인해보면 정상적으로 git clone되어 데이터가 저장된 것을 확인할 수 있다.

```shell
$ kubectl exec -it init-pod -- sh            
Defaulted container "gituse" out of: gituse, gitpull (init)
/ # cd /kube
/kube # ls
CNAME                      cluster.yml                requirements-2.10.txt
CONTRIBUTING.md            code-of-conduct.md         requirements-2.11.txt
Dockerfile                 contrib                    requirements-2.9.txt
LICENSE                    docs                       requirements-2.9.yml
Makefile                   extra_playbooks            requirements.txt
OWNERS                     facts.yml                  reset.yml
OWNERS_ALIASES             index.html                 roles
README.md                  inventory                  scale.yml
RELEASE.md                 legacy_groups.yml          scripts
SECURITY_CONTACTS          library                    setup.cfg
Vagrantfile                logo                       setup.py
_config.yml                mitogen.yml                test-infra
ansible.cfg                recover-control-plane.yml  tests
ansible_version.yml        remove-node.yml            upgrade-cluster.yml
```

<br>

정리하자면,

init 컨테이너가 먼저 생성된 뒤, 볼륨과 연결되어 git clone으로 코드(데이터)를 저장한 후 종료된다.

그 뒤에 busybox가 실행되고, 마운팅되어 볼륨을 사용한다.

initContainer는 상당히 많이 사용되는 기법이기 때문에 반드시 알아둬야한다.

<br>

<br>

## hostPath

[hostPath](https://kubernetes.io/ko/docs/concepts/storage/volumes/#hostpath)는 Docker의 바인드(bind)방식과 매우 유사하다.

hostPath는 **호스트의 특정 경로를 컨테이너의 볼륨으로 제공**할 수 있다.

즉, `hostPath` 볼륨은 호스트 노드의 파일시스템에 있는 파일이나 디렉터리를 파드에 마운트 한다.

<br>

`explain pod.spec.volumes.hostPath`

```shell
$ kubectl explain pod.spec.volumes.hostPath
KIND:     Pod
VERSION:  v1

RESOURCE: hostPath <Object>

DESCRIPTION:
     HostPath represents a pre-existing file or directory on the host machine
     that is directly exposed to the container. This is generally used for
     system agents or other privileged things that are allowed to see the host
     machine. Most containers will NOT need this. More info:
     https://kubernetes.io/docs/concepts/storage/volumes#hostpath

     Represents a host path mapped into a pod. Host path volumes do not support
     ownership management or SELinux relabeling.

FIELDS:
   path <string> -required-
     Path of the directory on the host. If the path is a symlink, it will follow
     the link to the real path. More info:
     https://kubernetes.io/docs/concepts/storage/volumes#hostpath

   type <string>
     Type for HostPath Volume Defaults to "" More info:
     https://kubernetes.io/docs/concepts/storage/volumes#hostpath
```

<br>

필요한 `path` 속성 외에도, `hostPath` 볼륨에 대한 `type` 을 마음대로 지정할 수 있다.

필드가 `type` 에 지원되는 값은 다음과 같다.

| 값                  | 행동                                                         |
| :------------------ | :----------------------------------------------------------- |
|                     | 빈 문자열 (기본값)은 이전 버전과의 호환성을 위한 것으로, hostPath 볼륨은 마운트 하기 전에 아무런 검사도 수행되지 않는다. |
| `DirectoryOrCreate` | 만약 주어진 경로에 아무것도 없다면, 필요에 따라 Kubelet이 가지고 있는 동일한 그룹과 소유권, 권한을 0755로 설정한 빈 디렉터리를 생성한다. => 디렉토리가 없으면 만든다 |
| `Directory`         | 주어진 경로에 디렉터리가 있어야 함                           |
| `FileOrCreate`      | 만약 주어진 경로에 아무것도 없다면, 필요에 따라 Kubelet이 가지고 있는 동일한 그룹과 소유권, 권한을 0644로 설정한 빈 파일을 생성한다. |
| `File`              | 주어진 경로에 파일이 있어야 함                               |
| `Socket`            | 주어진 경로에 UNIX 소캣이 있어야 함                          |
| `CharDevice`        | 주어진 경로에 문자 디바이스가 있어야 함                      |
| `BlockDevice`       | 주어진 경로에 블록 디바이스가 있어야 함                      |

<br>

**💻 실습**

<br>

```shell
$ sudo mkdir /web_contents
$ sudo echo "<h1> Hello hostPath </h1>" | sudo tee /web_contents/index.html
<h1> Hello hostPath </h1>
```

`/mnt/web_contents/index.html`

```
<h1> Hello hostPath </h1>
```

`myweb-rs-hp.yaml`

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: myweb-rs-hp
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
      containers:
        - name: myweb
          image: httpd
          volumeMounts:
            - name: web-contents
              mountPath: /usr/local/apache2/htdocs/
      volumes:
        - name: web-contents # 이름 언더바 불가능
          hostPath:
            type: Directory
            path: /web_contents
```

```shell
$ kubectl create -f myweb-rs-hp.yaml 
```

상태를 확인해보면, node1의 파드만 정상적으로 실행중이고, 나머지는 제대로 만들어지지 않는 것을 확인할 수 있다.

```shell
$  kubectl get rs,po -o wide
NAME                          DESIRED   CURRENT   READY   AGE     CONTAINERS   IMAGES   SELECTOR
replicaset.apps/myweb-rs-hp   3         3         1       7m56s   myweb        httpd    app=web

NAME                    READY   STATUS              RESTARTS   AGE     IP              NODE    NOMINATED NODE   READINESS GATES
pod/myweb-rs-hp-9bshq   1/1     Running             0          7m55s   10.233.90.104   node1   <none>           <none>
pod/myweb-rs-hp-jbks7   0/1     ContainerCreating   0          7m56s   <none>          node3   <none>           <none>
pod/myweb-rs-hp-r9zcr   0/1     ContainerCreating   0          7m55s   <none>          node2   <none>           <none>
```

`kubectl describe` 명령을 통해 EVENTS를 확인해보자.

```shell
$ kubectl describe po myweb-rs-hp-jbks7 
...
Events:
  Type     Reason       Age                    From               Message
  ----     ------       ----                   ----               -------
  Normal   Scheduled    8m40s                  default-scheduler  Successfully assigned default/myweb-rs-hp-jbks7 to node3
  Warning  FailedMount  7m36s (x8 over 8m40s)  kubelet            MountVolume.SetUp failed for volume "web-contents" : hostPath type check failed: /web_contents is not a directory
```

node2,3의 컨테이너가 제대로 생성되지 않는 이유는 node2,3에 `/web_contents` 디렉토리가 없기 때문이다.

<br>

pod가 만들어지는 순서를 생각해보자.

볼륨을 지정하면, 스케쥴링이 되고 볼륨 존재 여부를 먼저 체크한다.

볼륨이 정상적으로 있으면 이미지를 pulling하고, 컨테이너를 create, start 한다.

<br>
**`hostPath`는 local 스토리지로, 로컬에 있는 파드에는 볼륨 제공이 가능**하지만, 
**<u>네트워크 스토리지가 아니기 때문</u>에 네트워크를 넘어서 다른 노드의 파드에 제공하는 것은 불가능**하다⭐

<br>

**☁️ 참고**
로컬 스토리지: 다른 호스트에 스토리지 볼륨을 제공할 수 없다

- emptyDir
- hostPath
- gitRepo
- local

<br>

그러면 이제 node2와 3에도 `/web_contents` 디렉토리를 만들어주자.

```shell
$ ssh node2 sudo mkdir /web_contents  
$ ssh node3 sudo mkdir /web_contents
$ ssh node2 "echo "Hello hostPath" | sudo tee /web_contents/index.html" 
Hello hostPath
$ ssh node3 "echo "Hello hostPath" | sudo tee /web_contents/index.html"
Hello hostPath
```

디렉토리를 생성하고 시간이 조금 지난 뒤에 파드의 상태를 다시 확인하면,

정상적으로 `Running`되고 있는 것을 확인할 수  있다.

```shell
$ kubectl get pods                     
NAME                READY   STATUS    RESTARTS   AGE
myweb-rs-hp-9bshq   1/1     Running   0          19m
myweb-rs-hp-jbks7   1/1     Running   0          19m
myweb-rs-hp-r9zcr   1/1     Running   0          19m
```

<br>

<br>