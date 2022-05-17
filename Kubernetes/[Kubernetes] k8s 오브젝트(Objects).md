# [Kubernetes] k8s 오브젝트(Objects)

<br>

### 📌Index

- [쿠버네티스 오브젝트란?](#쿠버네티스-오브젝트란)

- [오브젝트의 버전](#오브젝트의-버전)
- [오브젝트의 정의](#오브젝트의-정의)
- [오브젝트 관리](#오브젝트-관리)

<br>

<br>

## 쿠버네티스 오브젝트란?



<img src="https://res.cloudinary.com/practicaldev/image/fetch/s--Z6e4Iuz2--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://cdn-images-1.medium.com/max/2000/1%2A0ovezrF2X2I2uSujya48Ig.png" alt="Kubernetes Monitoring: Kube-State-Metrics - DEV Community" style="zoom:67%;" />

출처: https://dev.to/chrisedrego/kubernetes-monitoring-kube-state-metrics-2bbi

<br>

- [쿠버네티스 오브젝트 이해하기 | Kubernetes](https://kubernetes.io/ko/docs/concepts/overview/working-with-objects/kubernetes-objects/)

- [레퍼런스 | Kubernetes](https://kubernetes.io/ko/docs/reference/)

쿠버네티스 오브젝트란 클러스터 내부의 엔티티로서, 이후 설명할 파드, 컨트롤러, 서비스 등의 인스턴스를 의미한다.

각각의 오브젝트는 쿠버네티스 API의 리소스 종류에 맞게 설정되고 생성된다.

**쿠버네티스 오브젝트**는 쿠버네티스 시스템에서 **영속성**을 가지는 오브젝트로,

오브젝트는 지정된 상태가 유지되도록 쿠버네티스에 의해 제어된다.

<br>

##### 쿠버네티스에서 사용 가능한 오브젝트 리스트

```shell
$ kubectl api-resources
```

```shell
NAME                              SHORTNAMES   APIVERSION                             NAMESPACED   KIND
bindings                                       v1                                     true         Binding
componentstatuses                 cs           v1                                     false        ComponentStatus
configmaps                        cm           v1                                     true         ConfigMap
endpoints                         ep           v1                                     true         Endpoints
events                            ev           v1                                     true         Event
....
mutatingwebhookconfigurations                  admissionregistration.k8s.io/v1        false        MutatingWebhookConfiguration
validatingwebhookconfigurations                admissionregistration.k8s.io/v1        false        ValidatingWebhookConfiguration
...
```

- `SHORTNAMES`는 모두 소문자이고, `NAME`과 `KIND`는 유사해보이지만 `NAME`은 모두 소문자에 대부분 복수형인 반면, `KIND`는 대문자로 시작한다(명사의 시작은 대문자).

- `NAME` 은 `kubectl`에서 특정 리소스를 지칭할 때 사용한다. 예: `kubectl get services`, `kubectl get pods`

- `SHORTNAMES`은 `yaml` 파일에서 사용하지 못한다. (문법 오류)

- `APIVERSION`에 버전만 지정된 것(그룹이 없는 경우)은 `Core 그룹` 이고, 그룹이 있는 경우는 `API 그룹`이다 : `[오브젝트 그룹]/버전` 

<br>

`Object`를 사용해서 만드는 것을 `Resource`라고하며, 거의 같은 것이라고 생각하면 된다.

<br>

##### 현재 쿠버네티스 버전에서 지원되는 `api` 리스트

```shell
$ kubectl api-versions
```

```shell
admissionregistration.k8s.io/v1
apiextensions.k8s.io/v1
apiregistration.k8s.io/v1
apps/v1
authentication.k8s.io/v1
authorization.k8s.io/v1
autoscaling/v1
autoscaling/v2beta1
autoscaling/v2beta2
batch/v1
batch/v1beta1
certificates.k8s.io/v1
coordination.k8s.io/v1
...
```

<br>

<br>

## 오브젝트의 버전

[API Group](https://kubernetes.io/ko/docs/reference/using-api/#api-%EA%B7%B8%EB%A3%B9)

API 그룹은 쿠버네티스 API를 더 쉽게 확장하게 해주는 것으로, 

API 그룹은 REST 경로와 직렬화된 오브젝트의 `apiVersion` 필드에 명시된다.

<br>

##### 안정화(Stable) 

- 버전 이름이 `vX`이고 `X` 는 정수다. (예 : `v1`, `v2`)
- 안정화된 버전

##### 알파(Alpha) 

- 버전 이름에 `alpha`가 포함된다(예: `v1alpha1`).
- 일반적인 쿠버네티스 환경에서는 사용이 불가능
- 기본적으로 비활성화 상태
- 개발 중인 API로, 오류 및 버그가 많을 수 있음
- 테스트 용도의 클러스터에만 사용하는 것을 권장

##### 베타(Beta)

- 버전 이름에 `beta`가 포함된다(예: `v2beta3`).
- 충분히 검증된 버전으로, 오류는 거의 없음
- 버전이 올라갈 때 기능 변경이 있을 수 있고, 기능이 변경될 때 downtime 발생할 수 있음
- `Mission Critical` : 절대 죽으면 안되는 서비스(`24/7`)로, 가능하면 `Beta`서비스를 사용하지 않는 것을 권장

<br>

순서 : `Alpha` --> `Beta` --> `Stable`

예시 : `v1alphaX` --> `v2alphaX` -->  `v1betaX` --> `v2betaX` -->  `v1`

<br>

<br>

## 오브젝트의 정의

다음은 오프젝트를 정의(생성)하는 `yaml` 파일의 예시이다.

[`application/deployment.yaml`](https://raw.githubusercontent.com/kubernetes/website/main/content/ko/examples/application/deployment.yaml)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deployment
spec:
  selector:
    matchLabels:
      app: nginx
  replicas: 2 # tells deployment to run 2 pods matching the template
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.14.2
        ports:
        - containerPort: 80
```

##### `apiVersion`, `kind` ,`metadata`, `spec` 은 대부분의 리소스에 항상 선언된다.

따라서 다음을 기본적인 구조라고 할 수 있다.

```yaml
apiVersion:
kind:
metadata:
spec:
```

- `apiVersion` :  해당 오브젝트를 생성하기 위해 사용하고 있는 쿠버네티스 API 버전(지원하는 오브젝트의 버전)

- `kind` : 오브젝트의 종류로, `kind` 의 종류에 따라 지원하는 `apiVersion`이 다르다.

- `spec` : 오브젝트에 대해 어떤 상태를 의도하는지(오브젝트에 대한 선언)
  - 어떤 종류의 오브젝트를 정의하느냐에 따라 다르다.
  
  - 오브젝트에 따라 `spec`을 선언하지 않는 경우도 있으나 극히 드물다.
  
- `meta-data` : 오브젝트의 메타데이터
  - `이름` 문자열, `UID`, 그리고 선택적인 `네임스페이스`를 포함하여 오브젝트를 유일하게 구분지어 줄 데이터이다.

<br>

#### kubectl explain

`ansible docs`와 유사하며, **리소스를 어떻게 정의하는지에 대한 내용**을 확인할 수 있다.

```shell
$ kubectl explain <resource>
```

해당 정보는 이 명령어로만 확인할 수 있으며, 홈페이지에서 확인할 수 없다

<br>

예시

```shell
$ kubectl explain pods
KIND:     Pod
VERSION:  v1

DESCRIPTION:
     Pod is a collection of containers that can run on a host. This resource is
     created by clients and scheduled onto hosts.

FIELDS:
   apiVersion   <string>
     APIVersion defines the versioned schema of this representation of an
     object. Servers should convert recognized schemas to the latest internal
     value, and may reject unrecognized values. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources

   kind <string>
     Kind is a string value representing the REST resource this object
     represents. Servers may infer this from the endpoint the client submits
     requests to. Cannot be updated. In CamelCase. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds

   metadata     <Object>
     Standard object's metadata. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata

   spec <Object>
     Specification of the desired behavior of the pod. More info:
     https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status
 ...
```

- `Read-Only` 속성은 우리가 선언하는 것이 아니라(선언할 수 없고), 쿠버네티스가 채우는 항목이다.

- `meta-data`는 내용이 변하지 않지만, `spec` 은 변할 수 있다.

- `-required` 속성은 반드시 선언해야하는 항목이다.

<br>

하위 계층이 있는 경우에는 다음과 같이 계층적으로 내려가면서 확인할 수 있다.

```shell
$ kubectl explain pods.kind
```

```shell
$ kubectl explain pods.metadata
```

```shell
$ kubectl explain pods.spec.containers
```

<br>

`--reqursive` 옵션을 사용하면, 이름만 계층적으로 확인할 수 있다

```shell
$ kubectl explain pods --recursive
KIND:     Pod
VERSION:  v1

DESCRIPTION:
     Pod is a collection of containers that can run on a host. This resource is
     created by clients and scheduled onto hosts.

FIELDS:
   apiVersion   <string>
   kind <string>
   metadata     <Object>
      annotations       <map[string]string>
      clusterName       <string>
      creationTimestamp <string>
      deletionGracePeriodSeconds        <integer>
      deletionTimestamp <string>
      finalizers        <[]string>
...
```

<br>

<br>

## 오브젝트 관리

[쿠버네티스 오브젝트 관리 | Kubernetes](https://kubernetes.io/ko/docs/concepts/overview/working-with-objects/object-management/)

**관리 기법 3가지**

| 관리기법             | 대상                 | 권장 환경     | 지원하는 작업자 수 | 학습 난이도 |
| -------------------- | -------------------- | ------------- | ------------------ | ----------- |
| 명령형 커맨드        | 활성 오브젝트        | 개발 환경     | 1+                 | 낮음        |
| 명령형 오브젝트 구성 | 개별 파일            | 프로덕션 환경 | 1                  | 보통        |
| 선언형 오브젝트 구성 | 파일이 있는 디렉터리 | 프로덕션 환경 | 1+                 | 높음        |

- 명령형 커맨드 : `yaml` 파일을 작성하지 않고, `kubectl` 명령어로만 관리(처리)하는 것
  - `kubectl create`
  - `kubectl run`
  - `kubectl expose`
  - 본 글에서 앞서 진행했던 것들은 명령형 커맨드이다.
- 명령형 오브젝트 구성 : (절차형)  `yaml`을 순서대로 하나씩 실행
  - `kubectl create -f a.yaml`
  - `kubectl apply -f a.yaml`
  - `kubectl replace -f a.yaml`
- 선언형 오브젝트 구성 : 하나이상의`yaml` 파일의 모음을 한번에 실행
  - `kubectl create -f resources/`
  - `kubectl apply -f resources/`

<br>

<br>



참고

https://devbksheen.tistory.com/entry/%EC%BF%A0%EB%B2%84%EB%84%A4%ED%8B%B0%EC%8A%A4-API-%EC%98%A4%EB%B8%8C%EC%A0%9D%ED%8A%B8