# ArgoCD란? ArgoCD 개요 및 설치

#### GitOps

GitOps는 DevOps의 실천 방법 중 하나로, 애플리케이션의 배포와 운영에 관련된 <u>모든 요소들을 **Git에서 관리(Operation)**</u> 한다는 뜻이다. 

GitOps는 Git Pull 요청을 사용하여 인프라 프로비저닝 및 배포를 자동으로 관리한다. 

Git 레포지토리에는 전체 시스템 상태가 포함되어 있어 시스템 상태의 변화 추이를 확인하고 감사할 수 있다.

<br>

<img src="https://miro.medium.com/max/1400/1*PXYkUt_-XNkOFSk3F-KxbQ.png" alt="Continuous Delivery On Kubernetes With GitOps | by Luc Juggery | ITNEXT" style="zoom:50%;" />

출처: https://itnext.io/continuous-delivery-with-gitops-591ff031e8f9

<br>

**GitOps의 원칙**

- 모든 시스템은 선언적으로 선언되어야 한다.
- 시스템의 상태는 Git의 버전을 따라간다.
- 승인된 변화는 자동으로 시스템에 적용된다.
- 배포에 실패하면 이를 사용자에게 경고해야 한다.

<br>

#### ArgoCD

[ArgoCD](https://argo-cd.readthedocs.io/en/stable/)는 GitOps 방식으로 관리되는 **Manifest 파일의 변경사항을 감시**하며, **현재 배포된 환경의 상태와 Github Manifest 파일에 정의된 상태를 <u>동일하게 유지</u>**하는 역할을 수행한다.

<br> 

<img src="https://www.kangwoo.kr/wp-content/uploads/2020/01/gitops-003.png" alt="argocd – 지구별 여행자" style="zoom:67%;" />

출처: https://kangwoo.kr/tag/argocd/

**“Argo CD is a declarative, GitOps continuous delivery tool for Kubernetes.”**

한 마디로 ArgoCD는 <u>쿠버네티스를 위한 CD(Continuous Delivery) 툴</u>이라고 할 수 있다.

<br>

쿠버네티스(Kubernetes)의 구성 요소들을 관리 및 배포하기 위해서는 Manifest파일을 구성하여 실행해야하며,

이러한 파일들은 계속해서 변경되기 때문에 지속적인 관리가 필요하다.

이를 간편하게 Git으로 관리하는 방식이 바로 **GitOps**이고, GitOps를 실현시키며 쿠버네티스에 배포까지 해주는 툴이 바로 **ArgoCD**이다. 

<br>

<br>

#### 사전 요구 사항

ArgoCD를 설치 및 사용하기 위해서는 몇가지 사전 요구 사항이 존재한다.

- kubectl CLI가 설치되어있어야한다.

- kubeconfig 파일이 있어야한다. (`~/kube/config`) == Kubernetes 클러스터 환경을 준비한다.

<br>

### Argo CD 설치

먼저 `argocd` namespace를 생성하고 `kubectl` 명령을 통해 argocd를 kubernetes cluster에 배포한다.

```shell
kubectl create namespace argocd
```

```shell
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

다음 명령으로 정상적으로 배포되었는지 확인한다.

```shell
kubectl get all -n argocd                                
```

<br>

### ArgoCD CLI 설치

```shell
sudo curl -sSL -o /usr/local/bin/argocd https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64
chmod +x /usr/local/bin/argocd
```

<br>

### 외부 접근 설정

Argo CD 설치 시, <u>기본적으로 API 서버는 외부 주소로 노출되지 않는다.</u>

아래와 같이 4가지 방법으로 API 서버를 외부에서 접속할 수 있다.

<br>

**1. Service Type을 Load Balancer로 설정**

```shell
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
```

<br>

**2. Service Type을 NodePort로 설정**

```shell
kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "NodePort"}}'
```

<br>

**3. Ingress 설정**

아래 가이드를 참고하여 Ingress를 설정한다.

https://argoproj.github.io/argo-cd/operator-manual/ingress/

<br>

**4. Port Forwarding 설정**

아래 명령을 실행하여 Port Forwarding을 설정한 뒤, `http://localhost:8080`으로 서버에 접속할 수 있다.

```
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

<br>

외부 접근 설정 후 IP주소 및 포트를 확인하여 접속한다.

```shell
kubectl describe svc argocd-server -n argocd
```

![argocd](https://raw.githubusercontent.com/na3150/typora-img/main/img/argocd.png)

<br>

<br>

### ArgoCD 로그인

Argo CD의 웹 UI 로그인 계정은 admin이고, admin 계정 암호는 다음 명령으로 확인할 수 있다.

```shell
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo
```

admin과 확인한 패스워드로 접속하면 다음과 같은  화면을 확인할 수 있다.

![image-20220607114629129](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220607114629129.png)

CLI로도 로그인이 가능하다.

```shell
$ argocd login --insecure <ARGOCD_SERVER_DOMAIN>:<PORT>
```

```shell
$ argocd login 192.168.100.241
WARNING: server certificate had error: x509: cannot validate certificate for 192.168.100.241 because it doesn't contain any IP SANs. Proceed insecurely (y/n)? y
Username: admin
Password: 
'admin:login' logged in successfully
Context '192.168.100.241' updated
```

<br>

### Application 생성하기

이제 Argo CD를 활용하여 샘플 애플리케이션을 배포해보자.

GitHub URL👉 https://github.com/argoproj/argocd-example-apps

<br>

#### ArgoCD CLI 사용

아래 명령을 실행하여 샘플 애플리케이션을 생성한다.

```shell
$ argocd app create sample-app \
 --repo https://github.com/argoproj/argocd-example-apps.git \
 --path guestbook \
 --dest-server https://kubernetes.default.svc \
 --dest-namespace default
application 'sample-app' created
```

생성한 sample-app을 조회해보면 STATUS가 `OutOfSync`이다.

`OutOfSync` STATUS는 애플리케이션이 아직 배포되지 않고, Kubernetes 리소스가 생성되지 않은 초기 상태이다.

```shell
$ argocd app get sample-app
Name:               sample-app
Project:            default
Server:             https://kubernetes.default.svc
Namespace:          default
URL:                https://192.168.100.241/applications/sample-app
Repo:               https://github.com/argoproj/argocd-example-apps.git
Target:             
Path:               guestbook
SyncWindow:         Sync Allowed
Sync Policy:        <none>
Sync Status:        OutOfSync from  (53e28ff)
Health Status:      Missing

GROUP  KIND        NAMESPACE  NAME          STATUS     HEALTH   HOOK  MESSAGE
       Service     default    guestbook-ui  OutOfSync  Missing        
apps   Deployment  default    guestbook-ui  OutOfSync  Missing   
```

아래 명령을 실행하여 sample-app을 동기화한다.

**동기화하면 kubectl apply 명령을 실행**하여 애플리케이션을 클러스터에 배포한다.

저장소에서 Manifest를 검색하고 Mainefest의 `kubectl apply`를 수행한다. 

```shell
argocd app sync sample-app
```

```shell
$ argocd app get sample-app
Name:               sample-app
Project:            default
Server:             https://kubernetes.default.svc
Namespace:          default
URL:                https://192.168.100.241/applications/sample-app
Repo:               https://github.com/argoproj/argocd-example-apps.git
Target:             
Path:               guestbook
SyncWindow:         Sync Allowed
Sync Policy:        <none>
Sync Status:        Synced to  (53e28ff)
Health Status:      Healthy

GROUP  KIND        NAMESPACE  NAME          STATUS  HEALTH   HOOK  MESSAGE
       Service     default    guestbook-ui  Synced  Healthy        service/guestbook-ui created
apps   Deployment  default    guestbook-ui  Synced  Healthy        deployment.apps/guestbook-ui created
```

<br>

웹 UI에서도 정상적으로 애플리케이션이 생성 및 Synced된 것을 확인할 수 있다.

![image-20220607164032936](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220607164032936.png)

<br>

#### 웹 UI 활용

웹 UI를 사용하여 애플리케이션을 배포 및 동기화하는 과정은 다음 링크를 참조하면 된다.

https://argo-cd.readthedocs.io/en/stable/getting_started/#creating-apps-via-ui

<br>

<br>

<br>

<br>

Reference

- https://daddyprogrammer.org/post/14102/argocd-kubernetes-cluster-deploy/
- https://gruuuuu.github.io/cloud/argocd-gitops/

- https://yunsangjun.github.io/cicd/2019/08/04/installing-argocd.html
