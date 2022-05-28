# [Kubernetes] k8s Authentication(인증)과 RBAC(인가) + 실습

<br>

### 📌Index

- [k8s Authentication(인증)](#k8s-authentication인증)
- [RBAC](#rbac)
- [실습](#실습)
  - 💻 실습 1 : SA 만들기
  - 💻 실습 2 : 사용자 생성을 위한 x509 인증서를 만든 후, ClusterRoleBinding을 통해 Role 부여하기

<br>

<br>

## k8s Authentication(인증)

[Authenticating | Kubernetes](https://kubernetes.io/docs/reference/access-authn-authz/authentication/)

쿠버네티스에는 계정, 사용자라는 개념이 존재하며, 

크게 2가지 컨셉 ServiceAccount(SA)와 NormalUser가 있다.

<br>

#### 1. Service Account(SA) 

쿠버네티스가 관리하는 SA 사용자로, 사용자가 아닌 Pod가 사용한다.

<br>

우리가 **따로 지정하지 않더라도 파드를 만들 때 SA가 설정**된다.

파드의 정보를 yaml 형식으로 확인하면 `serviceAccount`가 default로 지정되어있는 것을 확인할 수 있다.

```shell
$ kubectl get pod <POD> -o yaml
...
serviceAccount: default
...
```

또한 **볼륨을 세팅하지 않더라도 무조건 볼륨 1개가 세팅**되고, 

이 **볼륨에는 SA 계정의 Token 정보**가 들어있다. 

그리고 애플리케이션은 이러한 **Token 정보로 쿠버네티스에 인증**을 받을 수 있다. 

```shell
$ kubectl describe pod <POD> 
...
 Environment:  <none>
    Mounts:
      #볼륨이 다음의 serviceaccount에 마운트된다
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-dw7h2 (ro)
Conditions:
  Type              Status
  Initialized       True 
  Ready             True 
  ContainersReady   True 
  PodScheduled      True 
Volumes:
  kube-api-access-dw7h2: #생성되는 볼륨
...
```

**모든 Pod는 만들어질 때 SA 계정의 토큰이 `/var/run/secrets/kubernetes.io/serviceaccount`에 볼륨으로 할당**된다.

<br>

정리하자면 **SA 계정을 만들고, SA 계정에 권한을 부여한 뒤, 파드를 만들 때 해당 SA 계정을 지정**하게되면

그 <u>**파드에서 실행되는 애플리케이션이 해당되는 SA 권한으로 쿠버네티스 작업을 수행**</u>할 수 있게된다. ⭐

(파드는 SA 계정을 통해서, SA계정에 부여받은 Token 정보를 가지고 작업을 할 수 있게 된다)

<br>

**리소스 확인**

```shell
$ kubectl api-resources| grep serviceacc
serviceaccounts                   sa           v1                                     true         ServiceAccount
```

<br>

**SA 생성**

```shell
$ kubectl create sa <NAME>
```

<br>

#### 2. Normal User

normal user는 **쿠버네티스가 관리하지 않는 일반 사용자**로, 인증서는 쿠버네티스가 발급해준다.

k8s에는 normal user account를 직접적으로 관리하는 object가 없고, 

normal user account는 API call 을 통해 cluster로 포함될 수 없다. 

일반 사용자는 API 호출을 통해 추가할 수 없지만, 

클러스터의 인증 기관 (CA) 에서 서명한 유효한 인증서를 제시하는 모든 사용자는 인증된것으로 간주한다.

<br>

#### 인증 방법

**1. x509 인증서**

쿠버네티스를 설치할 때 자동으로 생성되는 것으로, kubeconfig 파일에 인증서 내용이 직접 들어가 있다. 

이 인증서는 마스터 노드의 `/etc/kubernetes/pki` 디렉터리에 있는

 `ca.crt`를 루트 인증서로 하여 만들어진 하위 인증서 중 하나이다.

<br>

**2. Static Token(정적 토큰)**

- Bearer Token : http 헤더에 인증 토큰을 실어서 보낸다

단, 따로 암호화를 하지 않기 때문에, 외부에 노출되기 쉽다. 일반적으로 테스팅을 위한 용도로 사용한다.

http 헤더 예시: `Authorization: Bearer 31ada4fd-adec-460c-809a-9e56ceb75269`

- Bootstrap Token
- **Service Account Token⭐** : JSON Web Token(JWT) ([JSON Web Tokens - jwt.io](https://jwt.io/))

<u>SA 계정의 토큰 정보는 **secret에 저장**</u>된다. 

secret를 확인하면 token 정보, ca 인증서, namespace를 확인할 수 있다.

<br>

**3. OpenID Connect(OIDC) Token**

외부 인증을 표준화하는 인터페이스로, 중앙 집중화된 통제가 가능해지며, 안전하게 인증을 받을 수 있게된다.

- okta : 인증 서버(SaaS)
- AWS IAM

<br>

<br>

## RBAC

RBAC(Role-based Access Control)는 **조직 내 개별 사용자의 역할에 따라** 

**컴퓨터 또는 네트워크 리소스에 대한 액세스를 규제하는 인가(Authorization) 방식**이다. 

RBAC는 누가(주체), 무엇을(동사), 어디에(네임스페이스) 실행할 수 있는지 결정하는 

권한 또는 템플릿 집합을 수반하는 Identity 및 액세스 관리 형식이다. 

<br>

☁️ 참고

- Identification : 인증

- Authentication : 인증

- Authorization : 인가(권한을 부여하는 것)

- Credential : 자격 증명

<br>

**리소스 확인**

```shell
$ kubectl api-resources | grep rbac                             
clusterrolebindings                            rbac.authorization.k8s.io/v1           false        ClusterRoleBinding
clusterroles                                   rbac.authorization.k8s.io/v1           false        ClusterRole
rolebindings                                   rbac.authorization.k8s.io/v1           true         RoleBinding
roles                                          rbac.authorization.k8s.io/v1           true         Role
```

`rolebindings`, `roles`는 네임스페이스(NS)를 사용하고,

`clusterrolebinding`, `clusterroles`은 네임스페이스를 사용하지 않는 것을 확인할 수 있다.

<br>

#### Role과 ClusterRole

- Role : **특정 네임스페이스에 한정**된 정책 (특정 네임스페이스 + '어디서 무엇을 어떻게')
- ClusterRole : **클러스터 전체**에 한정된 정책 (클러스터 전체 + '어디서 무엇을 어떻게')
- RoleBinding : 역할이 **특정 네임스페이스에 한정**된 정책을 따르도록 적용 (어떤 역할이 특정 네임스페이스에서 하는가?)
  - Role <-> RoleBinding <-> SA/User
  - Role 리소스와 SA/User를 연결시켜준다.
- ClusterRoleBinding : 역할이 **클러스터 전체**에 한정된 정책을 따르도록 적용 (어떤 역할이 클러스터 전체에서 하는가?)
  - ClusterRole <-> ClusterRoleBinding <-> SA/User
  - ClusterRole과 SA/User를 연결시켜준다.

<br>

쿠버네티스에 대한 요청이 처리되는 전체 과정을 요약하면 아래와 같다.

<br>

<img src="https://blog.kakaocdn.net/dn/bY5UR9/btrCKXtfd0l/txTivfQwjImvDMnIDoe8L1/img.png" alt="img" style="zoom: 33%;" />

출처: https://happycloud-lee.tistory.com/259?category=832243

<br>

다음으로, [RBAC 권한 부여 사용](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)의 예제를 하나씩 확인해보자.

<br>

#### Role 예제

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: default
  name: pod-reader
rules:
- apiGroups: [""] # "" core API group을 지칭
  resources: ["pods"]
  verbs: ["get", "watch", "list"] #pod에 대해서 요청 동사 get,watch,list를 할 수 있다.
```

`rules`에 사용자(여기서는 `pod-reader`)가 어떤 권한을 행사할 수 있는지 설정한다.

<br>

#### 요청 동사

| HTTP 동사 | 요청 동사                                                    | 예시                                                         |
| --------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| POST      | create                                                       | `kubectl create` <br>`kubectl apply`                         |
| GET, HEAD | get(개별 리소스), list(전체 오브젝트 내용을 포함한 리소스 모음), watch(개별 리소스 또는 리소스 모음을 주시) | get : `kubectl get po myweb`<br>list : `kubectl get pos`<br>watch : `kubectl get po -w` |
| PUT       | update                                                       | `kubectl edit`<br>`kubectl replace`                          |
| PATCH     | patch                                                        | `kubectl patch`                                              |
| DELETE    | delete(개별 리소스), deletecollection(리소스 모음)           | delete : `kubectl delete po myweb`<br>deletecollection : `kubectl delete po --all` |

<br>

`kubectl` 명령 시 `-v` 옵션을 사용하면 실제로 `kubectl`이 어떻게 요청하는 지 확인할 수 있다.

```shell
$ kubectl get po -v=7
I0528 15:32:20.350320  145956 loader.go:372] Config loaded from file:  /home/vagrant/.kube/config
I0528 15:32:20.355731  145956 round_trippers.go:432] GET https://127.0.0.1:6443/api/v1/namespaces/default/pods?limit=500
I0528 15:32:20.355761  145956 round_trippers.go:438] Request Headers:
I0528 15:32:20.355765  145956 round_trippers.go:442]     Accept: application/json;as=Table;v=v1;g=meta.k8s.io,application/json;as=Table;v=v1beta1;g=meta.k8s.io,application/json
I0528 15:32:20.355768  145956 round_trippers.go:442]     User-Agent: kubectl/v1.22.8 (linux/amd64) kubernetes/7061dbb
I0528 15:32:20.364805  145956 round_trippers.go:457] Response Status: 200 OK in 7 milliseconds
NAME                                      READY   STATUS    RESTARTS        AGE
myweb-env                                 1/1     Running   0               64m
nfs-client-provisioner-758f8cd4d6-2sqcr   1/1     Running   28 (3h6m ago)   4d10h
```

```shell
$  kubectl delete -f myweb.yaml -v=7
I0528 15:34:40.029470  147843 loader.go:372] Config loaded from file:  /home/vagrant/.kube/config
F0528 15:34:40.031655  147843 helpers.go:116] error: the path "myweb.yaml" does not exist
goroutine 1 [running]:
k8s.io/kubernetes/vendor/k8s.io/klog/v2.stacks(0xc0000c2001, 0xc000047980, 0x5a, 0xb5)
        /workspace/src/k8s.io/kubernetes/_output/dockerized/go/src/k8s.io/kubernetes/vendor/k8s.io/klog/v2/klog.go:1026 +0xb9
k8s.io/kubernetes/vendor/k8s.io/klog/v2.(*loggingT).output(0x30d3380, 0xc000000003, 0x0, 0x0, 0xc00048b030, 0x2, 0x27f4698, 0xa, 0x74, 0x40e300)
        /workspace/src/k8s.io/kubernetes/_output/dockerized/go/src/k8s.io/kubernetes/vendor/k8s.io/klog/v2/klog.go:975 +0x1e5
k8s.io/kubernetes/vendor/k8s.io/klog/v2.(*loggingT).printDepth(0x30d3380, 0xc000000003, 0x0, 0x0, 0x0, 0x0, 0x2, 0xc0002b0cf0, 0x1, 0x1)
        /workspace/src/k8s.io/kubernetes/_output/dockerized/go/src/k8s.io/kubernetes/vendor/k8s.io/klog/v2/klog.go:735 +0x185
k8s.io/kubernetes/vendor/k8s.io/klog/v2.FatalDepth(...)
...
```

<br>

☁️ 참고 

`kubectl auth can-i` 명령을 통해,

내가 해당 명령에 대한 권한을 가지고 있는지 체크해볼 수 있다.

```shell
$ kubectl auth can-i [VERB]
```

예시

```shell
$ kubectl auth can-i create pod
$ kubectl auth can-i get nodes
$ kubectl auth can-i update pods
```

<br>

#### ClusterRole 예제

```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  # "namespace" ClusterRole은 namespace를 지정하지 않는다
  name: secret-reader
rules:
- apiGroups: [""] #core group
  #
  # at the HTTP level, the name of the resource for accessing Secret
  # objects is "secrets"
  resources: ["secrets"]
  verbs: ["get", "watch", "list"]
```

<br>

`kubectl get clusterroles` 명령을 통해 클러스터 내의 clusterrole들을 확인할 수 있는데, 

이때 `system:`이 붙은 clusterrole는 쿠버네티스 설치 시에 기본적으로 만들어져있는 clusterrole이다.

```shell
$ kubectl get clusterroles
system:aggregate-to-edit                                               2022-05-16T15:21:20Z
system:aggregate-to-view                                               2022-05-16T15:21:20Z
system:auth-delegator                                                  2022-05-16T15:21:20Z  
...
view                                                                   2022-05-16T15:21:20Z
edit                                                                   2022-05-16T15:21:20Z
admin                                                                  2022-05-16T15:21:20Z
cluster-admin                                                          2022-05-16T15:21:20Z
```

많은 clusterrole 중에 **일반적으로 사용하는 role**은 다음과 같다. (우리가 사용자에게 사용하라고 만들어놓은 role들이다)

- view: 읽을 수 있는 권한
- edit: 생성/삭제/변경 할 수 있는 권한
- admin: 모든것 관리(-RBAC의 ClusterRole 제외)
- cluster-admin: 모든것 관리

<br>

#### RoleBinding 예제

```yaml
apiVersion: rbac.authorization.k8s.io/v1
# This role binding allows "jane" to read pods in the "default" namespace.
# You need to already have a Role named "pod-reader" in that namespace.
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects: #사용자
#1개 이상의 사용자(subject) 지정 가능
- kind: User #일반 사용자
  name: jane # .kube/config에서 users에서 user의 name
  apiGroup: rbac.authorization.k8s.io
roleRef: #사용자와 역할(Role)을 연결
  # "roleRef" specifies the binding to a Role / ClusterRole
  kind: Role #Role 또는 ClusterRole
  name: pod-reader # this must match the name of the Role or ClusterRole you wish to bind to
  apiGroup: rbac.authorization.k8s.io
```

사용자의 name(여기서는 jane)은 `.kube/config`의 users의 user의 name과 매칭이 되어야한다.

예제 설명 : jane 사용자에게 pod-reader라는 역할(Role)이 연결된다. 

<br>

#### ClusterRoleBinding 예제

```yaml
apiVersion: rbac.authorization.k8s.io/v1
# This cluster role binding allows anyone in the "manager" group to read secrets in any namespace.
kind: ClusterRoleBinding
metadata: #namespace를 쓰지 않는다
  name: read-secrets-global
subjects:
- kind: Group #그룹을 지정할 수 있다
  name: manager # Name is case sensitive
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: secret-reader
  apiGroup: rbac.authorization.k8s.io
```

예제 설명 : manager에게 secret-reader라는 ClusterRole이 연결된다.

<br>

[여기](https://nayoungs.tistory.com/entry/Kubernetes-k8s-Volume-%EB%8F%99%EC%A0%81-%ED%94%84%EB%A1%9C%EB%B9%84%EC%A0%80%EB%8B%9D-with-NFS-%EA%B8%B0%EB%B3%B8-%EC%8A%A4%ED%86%A0%EB%A6%AC%EC%A7%80-%ED%81%B4%EB%9E%98%EC%8A%A4)에서 생성했던 `nfs-subdir-external-provisioner`의 `rbac.yaml` 파일을 주석과 함께 살펴보자. 

https://github.com/kubernetes-sigs/nfs-subdir-external-provisioner/blob/master/deploy/rbac.yaml

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nfs-client-provisioner #SA 계정
  # replace with namespace where provisioner is deployed
  namespace: default
---
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: nfs-client-provisioner-runner
rules:
  - apiGroups: [""] #core group
    resources: ["nodes"] 
    verbs: ["get", "list", "watch"] #nfs 파드는 다른 노드의 정보를 볼 수 있어야한다
  - apiGroups: [""] #core group
    resources: ["persistentvolumes"]
    verbs: ["get", "list", "watch", "create", "delete"] #pv는 만들고 삭제하는 것까지 가능해야한다
  - apiGroups: [""]
    resources: ["persistentvolumeclaims"]
    verbs: ["get", "list", "watch", "update"] #pvc에 pv에 대한 정보를 업데이트 할 수 있어야한다
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: ["get", "list", "watch"] #스토리지 클래스 리소스를 볼 수 있어야한다
  - apiGroups: [""]
    resources: ["events"] #describe 명령어로 확인하는 Events
    verbs: ["create", "update", "patch"] #이벤트를 만들고, 업데이트하고, 변경할 수 있어야한다
---
kind: ClusterRoleBinding #ClusterRole과 SA 계정을 연결
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: run-nfs-client-provisioner
subjects: #사용자 계정
  - kind: ServiceAccount #계정 지정
    name: nfs-client-provisioner
    # replace with namespace where provisioner is deployed
    namespace: default
roleRef:
  kind: ClusterRole #역할 지정
  name: nfs-client-provisioner-runner
  apiGroup: rbac.authorization.k8s.io
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: leader-locking-nfs-client-provisioner
  # replace with namespace where provisioner is deployed
  namespace: default
rules:
  - apiGroups: [""]
    resources: ["endpoints"]
    verbs: ["get", "list", "watch", "create", "update", "patch"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: leader-locking-nfs-client-provisioner
  # replace with namespace where provisioner is deployed
  namespace: default
subjects:
  - kind: ServiceAccount
    name: nfs-client-provisioner
    # replace with namespace where provisioner is deployed
    namespace: default
roleRef:
  kind: Role
  name: leader-locking-nfs-client-provisioner
  apiGroup: rbac.authorization.k8s.io
```

deployment를 만들 때 ServiceAccount를 지정하여,

컨테이너의 앱이 Api Server에 요청할 때 SA 계정의 토큰으로 인증을 받고, 

SA에 부여된 역할들로 수행할 수 있게된다.

<br>

<br>

## 실습

**💻 실습 1** : SA 만들기

<br>

다음과 같이 sa `myuesr1`을 생성한다.

```shell
$ kubectl create sa myuser1
serviceaccount/myuser1 created
```

sa `myuser1` 생성 후 `kubectl get` 명령을 통해 확인할 수 있고,

```shell
$ kubectl get sa
NAME                     SECRETS   AGE
myuser1                  1         4s
```

`kubectl describe` 명령을 통해 확인해보면 Token이 생성된 것을 확인할 수 있다.

```shell
$ kubectl describe sa myuser1
Name:                myuser1
Namespace:           default
Labels:              <none>
Annotations:         <none>
Image pull secrets:  <none>
Mountable secrets:   myuser1-token-6gfd8
Tokens:              myuser1-token-6gfd8
Events:              <none>
```

그리고 해당 토큰이 secret으로 생성되어있는 것을 확인할 수 있다.

SA 계정의 토큰 정보는 **secret에 저장**된다. 

```shell
$ kubectl get secret
NAME                                 TYPE                                  DATA   AGE
myuser1-token-6gfd8                  kubernetes.io/service-account-token   3      25s
```

<br>

**💻 실습 2** : 사용자 생성을 위한 x509 인증서를 만든 후, ClusterRoleBinding을 통해 Role 부여하기

Private Key 생성

```
$ openssl genrsa -out myuser.key 2048
```

x509 인증서 요청 생성

```
$ openssl req -new -key myuser.key -out myuser.csr -subj "/CN=myuser"
```

현재 자체적으로 만든 인증서이기 때문에 이 인증서로는 인증을 받을 수 없다.

따라서, 다음과 같은 csr 오브젝트를 이용하여 서명을 받아보자.

```shell
$ kubectl api-resources | grep cer
\certificatesigningrequests        csr          certificates.k8s.io/v1                 false        CertificateSigningRequest
```

다음과 같이 `CertificateSigningRequest`을 생성하는 yaml 파일을 작성하는데,

앞서 만든 인증서를 인코딩해줘야하기 때문에 다음 명령을 통해 한줄로 인코딩 후 복사해둔다.

```shell
$ cat myuser.csr | base64 | tr -d "\n"
```

`csr.yaml`

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: myuser-csr
spec:
  usages: #사용 용도 -> 여러개 지정 가능
  - client auth #클라이언트 인증
  signerName: kubernetes.io/kube-apiserver-client #서명하는 사람, 서명하는 이름
  request: LS0tLS1CRUdJTiB... #인코딩 결과 붙여넣기
```

```shell
$ kubectl create -f csr.yaml
```

create 후 `kubectl get` 명령어로 확인할 수 있다. 이때 `REQUESTOR`는 '나'이다.

```shell
$ kubectl get csr
NAME         AGE   SIGNERNAME                            REQUESTOR          REQUESTEDDURATION   CONDITION
myuser-csr   5s    kubernetes.io/kube-apiserver-client   kubernetes-admin   <none>              Pending
```

현재 상태가 Pending이기 때문에 다음 명령을 통해 `myuser-csr`를 허용/승인 해줘야한다.

```shell
$ kubectl certificate approve myuser-csr
```

다시 상태를 확인해보면 `Approved` 승인 및 `Issued` 발급된 것을 확인할 수 있다.

```shell
$ kubectl get csr
NAME         AGE     SIGNERNAME                            REQUESTOR          REQUESTEDDURATION   CONDITION
myuser-csr   2m57s   kubernetes.io/kube-apiserver-client   kubernetes-admin   <none>              Approved,Issued
```

yaml 형식으로 상세 정보를 확인해보면,

```shell
$ kubectl get csr myuser-csr -o yaml
```

`status.certificates`가 발급된 인증서이다.

```yaml
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  creationTimestamp: "2022-05-28T17:08:25Z"
  name: myuser-csr
  resourceVersion: "1296680"
  uid: c3d63ed4-e858-42bc-a8eb-8061b972401e
spec:
  groups:
  - system:masters
  - system:authenticated
  request: LS0tLS1CRU...
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
  username: kubernetes-admin
status:
  certificate: LS0tLS1CRU... #발급된 인증서
  conditions:
  - lastTransitionTime: "2022-05-28T17:11:11Z"
    lastUpdateTime: "2022-05-28T17:11:11Z"
    message: This CSR was approved by kubectl certificate approve.
    reason: KubectlApprove
    status: "True"
    type: Approved
```

다음 명령으로 `jsonpath`를 통해 `status.certificates`만 추출하고, 

파이프라인을 통해 출력을 넘겨받아 디코딩한 후 `myuser.crt` 파일에 넣으면,

`myuser.crt`가 바로 서명된 인증서가 된다.

```shell
$ kubectl get csr myuser-csr -o jsonpath='{.status.certificate}' | base64 -d > myuser.crt
```

`myuser.crt` x509 인증서를 text로 해석해서 출력해보면 

Issuer(발급자)와 Subject(발급자)가 다른 것을 확인할 수 있고,

Issuer : kubernetes 즉, 쿠버네티스 CA가 발급해준 인증서인 것이다.

```shell
$ openssl x509 -in myuser.crt --text
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: ...
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN = kubernetes
        Validity
            Not Before: May 28 17:06:11 2022 GMT
            Not After : May 28 17:06:11 2023 GMT
        Subject: CN = myuser
...
```

이제 생성한 인증서 `myuser.crt`를 이용하여  Kubeconfig 사용자를 생성한다.

직접 kubeconfig 파일을 수정하거나, 다음과 같이 커맨드 명령어를 통해 생성할 수 있다.

이때 `--embed-certs` 옵션을 사용하면 자동으로 인코딩되어 깔끔하게 파일에 작성된다.

```shell
$ kubectl config set-credentials myuser --client-certificate=myuser.crt --client-key=myuser.key --embed-certs=true
```

<br>

다음으로 Kubeconfig 컨텍스트를 생성해보자.

마찬가지로 직접 kubeconfig 파일에 작성할 수 있고, 다음과 같이 커맨드 명령어를 통해 생성할 수 있다.

```shell
$ kubectl config set-context myuser@cluster.local --cluster=cluster.local --user=myuser --namespace=default
```

`kubectl config` 명령을 통해 생성된 user, cluser, context를 확인할 수 있다.

```shell
$ kubectl config get-users
NAME
myuser
$ kubectl config get-clusters
NAME
mycluster
$ kubectl config get-contexts
CURRENT   NAME                             CLUSTER         AUTHINFO           NAMESPACE
          myuser@cluster.local             cluster.local   myuser             default
```

다음 명령을 통해 current-context로 설정한다.

```shell
$ kubectl config use-context myuser@cluster.local
```

`kubectl auth can-i` 명령을 통해 내가 권한이 있는지 체크해볼 수 있는데,

아직 아무런 권한도 부여하지 않았기 때문에 `no` 인 것을 확인할 수 있다.

```shell
$ kubectl auth can-i create pod

no
```

clusterrolebinding을 통해 사용자에게 view Role(역할)을 부여해보자.

먼저 원래 context로 다시 전환한다.

```shell
$ kubectl config use-context kubernetes-admin@cluster.local
```

그리고 다음과 같이 ClusterRoleBinding 파일을 작성한다.

`myuser-view-crb.yaml`

```yaml
apiVersion: rbac.authorization.k8s.io/v1
	kind: ClusterRoleBinding
	metadata:
	  name: myuser-view-crb
	roleRef: #역할 지정 (1개만 가능)
	  - apiGroup: rbac.authorization.k8s.io
	    kind: ClusterRole
	    name: view #view 역할 부여
	subjects: #사용자(대상, 여러개 가능)
	  - apiGroup: rbac.authorization.k8s.io
	    kind: User
	    name: myuser
```

```shell
$ kubectl create -f myuser-view-crb.yaml
```

view 역할(Role)을 myuser 사용자에게 할당한 것을 확인할 수 있다.

```shell
$ kubectl describe clusterrolebinding myuser-view-crb
Name:         myuser-view-crb
Labels:       <none>
Annotations:  <none>
Role:
  Kind:  ClusterRole
  Name:  view
Subjects:
  Kind  Name    Namespace
  ----  ----    ---------
  User  myuser  
```

다시 사용자를 전환하면

```shell
$ kubectl config use-context myuser@cluster.local
```

view 권한을 부여받은 것을 확인할 수 있다.

```shell
$ kubectl get pods
NAME                                      READY   STATUS    RESTARTS         AGE
myweb-env                                 1/1     Running   0                3h30m
nfs-client-provisioner-758f8cd4d6-2sqcr   1/1     Running   28 (5h32m ago)   4d12h
```

<br>

<br>

<br>

참고

- https://seungjuitmemo.tistory.com/248

- https://velog.io/@jean1042/kubernetes-Service-Account-Authentication-RBAC

- https://happycloud-lee.tistory.com/259?category=832243

- https://tribal1012.tistory.com/332

- https://kubernetes.io/docs/reference/access-authn-authz/rbac/

- [인가 개요 | Kubernetes](https://kubernetes.io/ko/docs/reference/access-authn-authz/authorization/)