# [Kubernetes] Kubeconfig파일이란?

<br>

kubeconfig 파일은 **k8s의 설정 파일**로, `kubectl` 명령어로 apiserver에 접근할 때 사용할 인증 정보를 담고있다.

cluster, user, context에 대한 정보를 담는 config파일이다. 

<br>

여기서 **context란 user와 cluster 사이의 관계를 매핑**한 것으로,  

context에는 여러 종류가 있을 수 있으며, 현재 사용하는 context를 current-context라 한다. 

즉, **어떤 context를 사용하느냐에 따라 cluster와 user가 결정**되는 것이다.

<br>

**kubeconfig 파일의 위치**는 `~/.kube/config` 이다. 

<br>

#### kubeconfig 파일 내용 확인

다음 명령어를 통해 파일 내용을 확인할 수 있다.

```shell
$ kubectl config view           
apiVersion: v1
clusters: #쿠버네티스 클러스터 -> 여러개 가능
- cluster:
    certificate-authority-data: DATA+OMITTED  #CA인증서
    server: https://127.0.0.1:6443  #요청할 서버 : apiserver의 주소
  name: cluster.local
contexts:
- context:
    cluster: cluster.local
    user: kubernetes-admin
  name: kubernetes-admin@cluster.local
current-context: kubernetes-admin@cluster.local
kind: Config
preferences: {}
users: #사용자 -> 여려명 가능
- name: kubernetes-admin #계정
  user:
    client-certificate-data: REDACTED #클라이언트의 인증서(공개키)
    client-key-data: REDACTED  #개인키
```

`/etc/kubernetes/pki`에 인증서와 키가 존재하며, `kubectl`은 항상 `~/.kube/config`을 가장 먼저 찾는다.

위치가 홈 디렉토리가 아니라면 `KUBECONFIG` 환경 변수를 설정하거나, 

`--kubeconfig` 옵션을 사용하여 다른 kubeconfig 파일을 사용할 수 있다.

예시

```shell
$ kubectl config view --kubeconfig=ny-kubeconfig
```

<br>

실제로 `/.kube/config` 파일만 있다면, 즉 서버의 위치만 알려준다면

`kubectl` 명령어를 사용할 수 있다.  다음은 윈도우에 kubeconfig 파일을 추가하고 `kube get nodes` 명령을 실행한 결과이다.

```shell
PS C:\Users\USER> ls ~/.kube/config


    디렉터리: C:\Users\USER\.kube


Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a----      2022-05-26   오후 2:25           5668 config


PS C:\Users\USER> kubectl get nodes
NAME    STATUS   ROLES                  AGE   VERSION
node1   Ready    control-plane,master   11d   v1.22.8
node2   Ready    <none>                 11d   v1.22.8
node3   Ready    <none>                 9d    v1.22.8
```

서버를 찾아서 정상적으로 결과가 출력되는 것을 확인할 수 있다.

<br>

#### context 확인하기

**context 목록 확인하기**

CURRENT가 `*`인 것은, 현재 사용하고있는 current-context라는 의미이다.

```shell
$ kubectl config get-contexts
CURRENT   NAME                             CLUSTER         AUTHINFO           NAMESPACE
*         kubernetes-admin@cluster.local   cluster.local   kubernetes-admin   
```

**current-context 확인하기**

```shell
$ kubectl config current-context
```

<br>

#### cluster 목록 확인하기

```shell
$ kubectl config get-clusters
```

<br>

#### context 전환하기⭐

kubeconfig 파일에 임의로 cluster와 user, 그리고 context를 추가해보자.

```shell
- cluster:
    server: https://1.1.1.1
  name: mycluster
  ...
- context:
    cluster: mycluster
    user: myadmin
  name: myadmin@mycluster 
  ...
users:
- name: myadmin  
```

저장 후 확인하면 cluster와 context가 추가된 것을 확인할 수 있다.

```shell
$ kubectl config get-clusters
NAME
cluster.local
mycluster
$ kubectl config get-contexts
CURRENT   NAME                             CLUSTER         AUTHINFO           NAMESPACE
*         kubernetes-admin@cluster.local   cluster.local   kubernetes-admin   monitor
          myadmin@mycluster                mycluster       myadmin    
```

context를 전환하는 방법은,

kubeconfig 파일 내에 다음과 같이 직접 선언하거나

```shell
current-context: kubernetes-admin@cluster.local
```

명령형 커맨드를 통해 current-context를 전환할 수 있다.

```shell
$ kubectl config use-context myadmin@mycluster
```

그리고 또 다른 방법으로 [kubectx](https://nayoungs.tistory.com/entry/Kubernetes-kubectx-kubens-%EC%84%A4%EC%B9%98-%EB%B0%8F-powerlevel10-%EC%BB%A4%EC%8A%A4%ED%84%B0%EB%A7%88%EC%9D%B4%EC%A7%95#kubectx%EB%-E%--%-F)가 있다.

```shell
$ kubectx myadmin@mycluster
```

`kubectx`는 손쉽게 cluster context를 변경할 수 있는 툴로, 실제로 많이 사용된다.

<br>

#### 그 외

```shell
current-context  -- Display the current-context
delete-cluster   -- Delete the specified cluster from the kubeconfig
delete-context   -- Delete the specified context from the kubeconfig
delete-user      -- Delete the specified user from the kubeconfig
get-clusters     -- Display clusters defined in the kubeconfig
get-contexts     -- Describe one or many contexts
get-users        -- Display users defined in the kubeconfig
rename-context   -- Rename a context from the kubeconfig file
set              -- Set an individual value in a kubeconfig file
set-cluster      -- Set a cluster entry in kubeconfig
set-context      -- Set a context entry in kubeconfig
set-credentials  -- Set a user entry in kubeconfig
unset            -- Unset an individual value in a kubeconfig file
use-context      -- Set the current-context in a kubeconfig file
view             -- Display merged kubeconfig settings or a specified kubeconfig file
```

그 외에도 다양한 커맨드 명령들이 존재한다.

<br>

<br>