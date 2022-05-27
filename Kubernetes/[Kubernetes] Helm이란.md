# [Kubernetes] Helm이란?

<br>

### 📌Index

- [Helm이란?](#helm이란)
- [Helm 설치하기](#helm-설치하기)

- [Helm 사용법](#helm-사용법)

<br>

<br>

## Helm이란?

[Helm](https://helm.sh/)이란, **Kubernetes 패키지 관리를 도와주는 것**으로, yaml 파일의 모음이라고 할 수 있다.

<br>

Helm에 대한 많은 문서나 책에서 2버전을 다루고 있는데, 2버전은 더 이상 개발되지 않는다.

2버전은 3버전과 명령어도 다르고, 아키텍처 구조도 다르다. 

아래의 그림이 버전2의 아키텍처로,



<img src="https://miro.medium.com/max/1200/1*mClrYLFakC6B6f62vVnhcA.png" alt="img" style="zoom: 50%;" />



특히 가장 큰 차이점은 Helm Tiller의 여부이다.

Helm Tiller는 Pod로, 버전2에서 사용되었다가 

여러가지 보안 문제로 버전3에서부터는 더 이상 사용되지 않는다.

Tiller와 Client는 서로 gRPC로 통신을 했으나, **버전3부터는 Client에서 바로 API Server로 요청**한다.

아래의 그림이 Helm 버전3의 아키텍처이다.

<img src="https://developer.ibm.com/developer/default/blogs/kubernetes-helm-3/images/helm3-arch.png" alt="What's in Helm 3? - IBM Developer" style="zoom:50%;" />

출처: https://developer.ibm.com/blogs/kubernetes-helm-3/

<br>

`/kubespray/inventory/mycluster/group_vars/k8s_cluster/addon.yml` 파일을 보면,

```shell
# Helm deployment
helm_enabled: false
```

`helm_enable : false` 라고 설정되어있는데, true라고 설정하면 helm 버전2를 사용하게 된다.

버전2는 사용하지 않을 것이기 때문에, 앞으로 tiller라는 용어가 나오면 넘기면 된다.

<br>

Helm을 사용하기에 앞서, **3가지 주요 개념**을 꼭 알아야한다.

<br>

#### 1. Chart

Chart는 **helm의 리소스 패키지**로, 

k8s cluster에서 애플리케이션이 기동되기 위해 필요한 모든 리소스들이 포함되어 있다.

<br>

**chart 구조**

```null
<Chart Name>/
  Chart.yaml 
  values.yaml
  templates/ 
```

- Chart.yaml: 차트의 메타데이터(차트의 이름, 버전, 만든 사람 등)
- values.yaml: 패키지를 커스터마이즈/사용자화(value)
- templates: 실제 YAML 오브젝트 파일들이 있는 디렉토리

<br>

Helm 차트를 검색하는 사이트 : https://artifacthub.io/ 

- 단, 패키지를 가지고 있지는 않다(저장소가 아님)
- 예시 : [bitnami/charts: Bitnami Helm Charts (github.com)](https://github.com/bitnami/charts)

<br>

#### 2. Repository(저장소)

차트 저장소로, 차트를 모아두고 공유하는 장소이다.

<br>

#### 3. Release(릴리즈)

릴리즈는 k8s cluster에서 구동되는 **차트 인스턴스**이다. 

일반적으로 동일한 Chart를 여러 번 설치할 수 있고 이는 새로운 Release로 관리되게 된다. 

Release될 때 패키지된 차트와 Config가 결합되어 정상 실행되게 된다.

 <br>

아래 순서와 같이 연계된다고 보면 된다.

k8s cluster 내부에 **Helm Chart**를 원하는 **Repository에서 검색 후 설치** ▶ 각 설치에 따른 **새로운 Release 생성**

 <br>

<br>

## Helm 설치하기

Helm을 설치하기에 앞서, 몇가지 사전 요구사항이 있다.

- k8s cluster가 있어야한다.
- kubeconfig가 있어야한다. 없으면 apiserver를 찾아갈 수 없기 때문이다.
- helm이 설치되고 구성되어야한다.

<br>

이제 [Helm | Installing Helm](https://helm.sh/docs/intro/install/)에 따라 Helm을 설치해보자.

먼저 다음의 명령어들을 실행한다.

```shell
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm
```

다음으로 helm 명령어 자동완성을 위해 zsh 플러그인에 helm 추가한다.

`~/.zshrc`

```shell
plugins=(
...
	helm
)
```

수정 후 변경 사항을 적용할 수 있도록 다음 명령어를 실행한다.

```shell
$ source ~/.zshrc
```

설치 확인

```shell
$ helm version
```

<br>

<br>

## Heml 사용법

[Helm | Using Helm](https://helm.sh/docs/intro/using_helm/)

<br>

#### Artifact hub 검색

```shell
$ helm search hub wordpress
```

<br>

#### Repository 추가

```shell
$ helm repo add [레포지토리 이름] [레포지토리 주소]
```

여기서 레포지토리 이름을 어떻게 지정하느냐에 따라 패키지명이 달라진다. 

패키지 이름 앞에 ` 레포지토리이름/` 이 붙게 된다.

<br>

예시

```shell
$ helm repo add bitnami https://charts.bitnami.com/bitnami
```

--> wordpress 패키지 이름  : `bitnami/wordpress`

<br>

#### Repository 검색

Chart 리스트를 검색하여 출력한다.

```shell
$ helm search repo <저장소> <PATTERN>
```

예시 : bitnami 레포지토리에 저장된 Chart 목록을 출력한다.

```shell
$ helm search repo bitnami
```

<br>

#### Repository 리스트 출력

등록된 레포지토리(저장소) 목록을 출력한다.

```shell
$ helm repo list
```

<br>

#### Chart 업데이드

```shell
$ helm repo update
```

`apt update` 하듯이, 추가한 리파지토리의 인덱스 정보를 최신으로 업데이트 하는것이 필요하기 때문에

다음과 같이 helm 차트의 정보를 업데이트한다.

<br>

#### Chart 설치

```shell
$ helm install [NAME] [CHART] [flags]
```

`NAME` 은 릴리즈 이름이다.

설치 완료시 나오는 text는 레포지토리의 `NOTES.txt`이다. (없는 경우도 있음)

`NOTES.txt`는 간략하게 사용 방법이 설명되어있다.

```shell
$ helm install mywordpress bitnami/wordpress
```

<br>

다음과 같이 `--set` 옵션을 사용하여 value를 세팅할 수 있다. 

즉, 차트를 사용자화 할 수 있다.

```shell
$ helm install mywordpress bitnami/wordpress --set replicaCount=2
```

```shell
$ helm install mywordpess bitnami/wordpress --set replicaCount=2 --set service.type=NodePort
```

그러나 수정 사항이 많을 때에는 `--set` 옵션을 여러번 붙이는 것이 번거로우므로, 

일반적으로 yaml 파일로 설정한다. yaml 파일로 사용자화하는 것은 뒤에서 확인할 수 있다.

<br>

#### Chart 정보 확인

`values.yaml ` 확인

```shell
$ helm show values bitnami/wordpress
```

파일로 가져오기

```shell
$ helm show values bitnami/wordpress > wp-value.yaml
```

`chart.yaml `확인

```shell
$ helm show chart bitnami/wordpress
```

<br>

#### Chart 만들기

```shell
$ helm create [PACKAGE NAME]
```

패키지 이름으로 디렉토리가 만들어지며, 디렉토리 내부에 기본 뼈대가 만들어진다.

<br>

예시

```shell
$ helm create mypkg
$ cd mypkg
```

```shell
$ ls
Chart.yaml  charts  templates  values.yaml
```

```shell
$ ls templates 
NOTES.txt     deployment.yaml  ingress.yaml  serviceaccount.yaml
_helpers.tpl  hpa.yaml         service.yaml  tests
```

<br>

#### History 확인하기

```shell
$ helm history [NAME]
```

<br>

#### Rollback하기

```shell
$ helm rollback [NAME] [REVISION]
```

<br>

#### 릴리즈 목록 확인

```shell
$ helm list                                    
```

<br>

#### 릴리즈 삭제

```shell
$ helm uninstall [NAME]
```

또는

```shell
$ helm delete [NAME]
```



실제 리소스(파드, 컨트롤러 등)도 함께 지워진다.

<br>

#### 릴리즈 업그레이드

```shell
$ helm upgrade [NAME] [CHART] [FIAG]
```

파일의 내용(파라미터)을 수정한 경우 업그레이드를 한다.

<br>

예시

변경해야할 파라미터가 여러개인 경우, 차트 install 시 `--set` 옵션으로 일일이 지정하는 것은 번거롭기 때문에 

일반적으로 yaml 파일로 만들어준다.

```shell
$ helm show value bitnami/wordpress > wp-value.yaml
```

- `-f` : `yaml` 파일 지정

위와 같이 `helm show` 명령을 통해 파일 전체를 받아서 수정하는 것도 가능하고,

다음과 같이 필요한 부분만 지정하여 파일로 작성하는 것도 가능하다.

`wp-value.yaml`

```yaml
replicaCount: 2
service:
  type: LoadBalancer
```

```shell
$ helm upgrade mywordpress bitnami/wordpress -f wp-value.yaml
```

<br>

#### 릴리즈 업그레이드 히스토리

릴리즈가 업그레이드된 히스토리들을 확인할 수 있다.

```shell
$ helm history [NAME]
```

<br>

#### 릴리즈 롤백

지정한 REVISION으로 롤백한다.

```shell
$ helm rollback [NAME] [REVISION]
```

<br>

<br>

## Helm 실습

💻 실습 : Helm Chart로 Wordpress 배포하기

<br>

bitnami 레포지토리를 추가한다.

```shell
$ helm repo add bitnami https://charts.bitnami.com/bitnami
```

레포지토리가 추가된 것을 확인한다.

```shell
$ helm repo list
NAME    URL                               
bitnami https://charts.bitnami.com/bitnami
```

레포지토리에서 wordpress 차트를 검색한다.

```shell
$ helm search repo wordpress 
NAME                    CHART VERSION   APP VERSION     DESCRIPTION                                       
bitnami/wordpress       14.2.7          5.9.3           WordPress is the world's most popular blogging ...
bitnami/wordpress-intel 1.3.0           5.9.3           WordPress for Intel is the most popular bloggin...
```

`bitnami/wordpress` 차트를 설치한다.

```shell
$ helm install mywordpress bitnami/wordpress
```

설치하면 사용방법이 출력되는데, 다음과 같이 로그인 정보를 확인할 수 있다.

```shell
3. Login with the following credentials below to see your blog:

echo Username: user
echo Password: $(kubectl get secret --namespace monitor mywordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)
```

설명에 따라 다음과 같이 패스워드를 확인할 수 있다.

```shell
$ echo Password: $(kubectl get secret --namespace monitor mywordpress -o jsonpath="{.data.wordpress-password}" | base64 --decode)
Password: lIyCXapQF9
```

현재 기본 replicas는 1이고, 파드를 2개 생성하기 위해 replicas를 2로 수정해보자.

방법은 2가지가 있다.

- `--set` 옵션 사용하기

```shell
$ helm upgrade mywordpress bitnami/wordpress --set replicaCount=2
```

- yaml 파일을 작성하여 `-f` 옵션으로 지정하기

`wp-value.yaml`

```shell
replicaCount: 2
```

```shell
$ helm upgrade mywordpress bitnami/wordpress -f wp-value.yaml
```

<br>

2가지 방법 중 한가지 방법을 선택하여 업그레이드를 진행하면,

다음과 같이 history를 통해 확인할 수 있고,

```shell
$ helm history mywordpress 
REVISION        UPDATED                         STATUS          CHART                   APP VERSION    DESCRIPTION     
1               Fri May 27 16:10:56 2022        superseded      wordpress-14.3.1        5.9.3          Install complete
2               Fri May 27 16:15:13 2022        deployed        wordpress-14.3.1        5.9.3          Upgrade complete
```

파드도 2개 생성된 것을 확인할 수 있다.

```shell
$ kubectl get all
NAME                              READY   STATUS             RESTARTS      AGE
pod/mywordpress-ff494df9c-djpfg   0/1     Running            0             3m30s
pod/mywordpress-ff494df9c-h4qrk   0/1     Running            0             3m30s
pod/mywordpress-mariadb-0         0/1     Running            0             3m40s

NAME                          TYPE           CLUSTER-IP     EXTERNAL-IP       PORT(S)                      AGE
service/mywordpress           LoadBalancer   10.233.7.247   192.168.100.240   80:30803/TCP,443:30166/TCP   7m47s
service/mywordpress-mariadb   ClusterIP      10.233.23.89   <none>            3306/TCP                     7m47s

NAME                          READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mywordpress    /2     2                0      7m47s

NAME                                    DESIRED   CURRENT   READY   AGE
replicaset.apps/mywordpress-ff494df9c   2         2          2      7m47s

NAME                                   READY   AGE
statefulset.apps/mywordpress-mariadb   1/1     7m47s
```

로드밸런서의 `EXTERNAL-IP`로 접속해서 확인해보자.

<br>

![image-20220527114201905](https://raw.githubusercontent.com/na3150/typora-img/main/img/image-20220527114201905.png) 

<br>

정상적으로 접속 되는 것을 확인할 수 있다.

<br>

마지막으로 설치된 릴리즈를 삭제하면, 리소스까지 함께 지워진다.

```shell
$ helm uninstall mywordpress
```

<br>

<br>

<br>

<br>

참고

https://tech.ktcloud.com/51
