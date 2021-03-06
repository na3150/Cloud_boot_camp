# [Kubernetes] k8s ์ค๋ธ์ ํธ(Objects)

<br>

### ๐Index

- [์ฟ ๋ฒ๋คํฐ์ค ์ค๋ธ์ ํธ๋?](#์ฟ ๋ฒ๋คํฐ์ค-์ค๋ธ์ ํธ๋)

- [์ค๋ธ์ ํธ์ ๋ฒ์ ](#์ค๋ธ์ ํธ์-๋ฒ์ )
- [์ค๋ธ์ ํธ์ ์ ์](#์ค๋ธ์ ํธ์-์ ์)
- [์ค๋ธ์ ํธ ๊ด๋ฆฌ](#์ค๋ธ์ ํธ-๊ด๋ฆฌ)

<br>

<br>

## ์ฟ ๋ฒ๋คํฐ์ค ์ค๋ธ์ ํธ๋?



<img src="https://res.cloudinary.com/practicaldev/image/fetch/s--Z6e4Iuz2--/c_limit%2Cf_auto%2Cfl_progressive%2Cq_auto%2Cw_880/https://cdn-images-1.medium.com/max/2000/1%2A0ovezrF2X2I2uSujya48Ig.png" alt="Kubernetes Monitoring: Kube-State-Metrics - DEV Community" style="zoom:67%;" />

์ถ์ฒ: https://dev.to/chrisedrego/kubernetes-monitoring-kube-state-metrics-2bbi

<br>

- [์ฟ ๋ฒ๋คํฐ์ค ์ค๋ธ์ ํธ ์ดํดํ๊ธฐ | Kubernetes](https://kubernetes.io/ko/docs/concepts/overview/working-with-objects/kubernetes-objects/)

- [๋ ํผ๋ฐ์ค | Kubernetes](https://kubernetes.io/ko/docs/reference/)

์ฟ ๋ฒ๋คํฐ์ค ์ค๋ธ์ ํธ๋ ํด๋ฌ์คํฐ ๋ด๋ถ์ ์ํฐํฐ๋ก์, ์ดํ ์ค๋ชํ  ํ๋, ์ปจํธ๋กค๋ฌ, ์๋น์ค ๋ฑ์ ์ธ์คํด์ค๋ฅผ ์๋ฏธํ๋ค.

๊ฐ๊ฐ์ ์ค๋ธ์ ํธ๋ ์ฟ ๋ฒ๋คํฐ์ค API์ ๋ฆฌ์์ค ์ข๋ฅ์ ๋ง๊ฒ ์ค์ ๋๊ณ  ์์ฑ๋๋ค.

**์ฟ ๋ฒ๋คํฐ์ค ์ค๋ธ์ ํธ**๋ ์ฟ ๋ฒ๋คํฐ์ค ์์คํ์์ **์์์ฑ**์ ๊ฐ์ง๋ ์ค๋ธ์ ํธ๋ก,

์ค๋ธ์ ํธ๋ ์ง์ ๋ ์ํ๊ฐ ์ ์ง๋๋๋ก ์ฟ ๋ฒ๋คํฐ์ค์ ์ํด ์ ์ด๋๋ค.

<br>

##### ์ฟ ๋ฒ๋คํฐ์ค์์ ์ฌ์ฉ ๊ฐ๋ฅํ ์ค๋ธ์ ํธ ๋ฆฌ์คํธ

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

- `SHORTNAMES`๋ ๋ชจ๋ ์๋ฌธ์์ด๊ณ , `NAME`๊ณผ `KIND`๋ ์ ์ฌํด๋ณด์ด์ง๋ง `NAME`์ ๋ชจ๋ ์๋ฌธ์์ ๋๋ถ๋ถ ๋ณต์ํ์ธ ๋ฐ๋ฉด, `KIND`๋ ๋๋ฌธ์๋ก ์์ํ๋ค(๋ช์ฌ์ ์์์ ๋๋ฌธ์).

- `NAME` ์ `kubectl`์์ ํน์  ๋ฆฌ์์ค๋ฅผ ์ง์นญํ  ๋ ์ฌ์ฉํ๋ค. ์: `kubectl get services`, `kubectl get pods`

- `SHORTNAMES`์ `yaml` ํ์ผ์์ ์ฌ์ฉํ์ง ๋ชปํ๋ค. (๋ฌธ๋ฒ ์ค๋ฅ)

- `APIVERSION`์ ๋ฒ์ ๋ง ์ง์ ๋ ๊ฒ(๊ทธ๋ฃน์ด ์๋ ๊ฒฝ์ฐ)์ `Core ๊ทธ๋ฃน` ์ด๊ณ , ๊ทธ๋ฃน์ด ์๋ ๊ฒฝ์ฐ๋ `API ๊ทธ๋ฃน`์ด๋ค : `[์ค๋ธ์ ํธ ๊ทธ๋ฃน]/๋ฒ์ ` 

<br>

`Object`๋ฅผ ์ฌ์ฉํด์ ๋ง๋๋ ๊ฒ์ `Resource`๋ผ๊ณ ํ๋ฉฐ, ๊ฑฐ์ ๊ฐ์ ๊ฒ์ด๋ผ๊ณ  ์๊ฐํ๋ฉด ๋๋ค.

<br>

##### ํ์ฌ ์ฟ ๋ฒ๋คํฐ์ค ๋ฒ์ ์์ ์ง์๋๋ `api` ๋ฆฌ์คํธ

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

## ์ค๋ธ์ ํธ์ ๋ฒ์ 

[API Group](https://kubernetes.io/ko/docs/reference/using-api/#api-%EA%B7%B8%EB%A3%B9)

API ๊ทธ๋ฃน์ ์ฟ ๋ฒ๋คํฐ์ค API๋ฅผ ๋ ์ฝ๊ฒ ํ์ฅํ๊ฒ ํด์ฃผ๋ ๊ฒ์ผ๋ก, 

API ๊ทธ๋ฃน์ REST ๊ฒฝ๋ก์ ์ง๋ ฌํ๋ ์ค๋ธ์ ํธ์ `apiVersion` ํ๋์ ๋ช์๋๋ค.

<br>

##### ์์ ํ(Stable) 

- ๋ฒ์  ์ด๋ฆ์ด `vX`์ด๊ณ  `X` ๋ ์ ์๋ค. (์ : `v1`, `v2`)
- ์์ ํ๋ ๋ฒ์ 

##### ์ํ(Alpha) 

- ๋ฒ์  ์ด๋ฆ์ `alpha`๊ฐ ํฌํจ๋๋ค(์: `v1alpha1`).
- ์ผ๋ฐ์ ์ธ ์ฟ ๋ฒ๋คํฐ์ค ํ๊ฒฝ์์๋ ์ฌ์ฉ์ด ๋ถ๊ฐ๋ฅ
- ๊ธฐ๋ณธ์ ์ผ๋ก ๋นํ์ฑํ ์ํ
- ๊ฐ๋ฐ ์ค์ธ API๋ก, ์ค๋ฅ ๋ฐ ๋ฒ๊ทธ๊ฐ ๋ง์ ์ ์์
- ํ์คํธ ์ฉ๋์ ํด๋ฌ์คํฐ์๋ง ์ฌ์ฉํ๋ ๊ฒ์ ๊ถ์ฅ

##### ๋ฒ ํ(Beta)

- ๋ฒ์  ์ด๋ฆ์ `beta`๊ฐ ํฌํจ๋๋ค(์: `v2beta3`).
- ์ถฉ๋ถํ ๊ฒ์ฆ๋ ๋ฒ์ ์ผ๋ก, ์ค๋ฅ๋ ๊ฑฐ์ ์์
- ๋ฒ์ ์ด ์ฌ๋ผ๊ฐ ๋ ๊ธฐ๋ฅ ๋ณ๊ฒฝ์ด ์์ ์ ์๊ณ , ๊ธฐ๋ฅ์ด ๋ณ๊ฒฝ๋  ๋ downtime ๋ฐ์ํ  ์ ์์
- `Mission Critical` : ์ ๋ ์ฃฝ์ผ๋ฉด ์๋๋ ์๋น์ค(`24/7`)๋ก, ๊ฐ๋ฅํ๋ฉด `Beta`์๋น์ค๋ฅผ ์ฌ์ฉํ์ง ์๋ ๊ฒ์ ๊ถ์ฅ

<br>

์์ : `Alpha` --> `Beta` --> `Stable`

์์ : `v1alphaX` --> `v2alphaX` -->  `v1betaX` --> `v2betaX` -->  `v1`

<br>

<br>

## ์ค๋ธ์ ํธ์ ์ ์

๋ค์์ ์คํ์ ํธ๋ฅผ ์ ์(์์ฑ)ํ๋ `yaml` ํ์ผ์ ์์์ด๋ค.

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

##### `apiVersion`, `kind` ,`metadata`, `spec` ์ ๋๋ถ๋ถ์ ๋ฆฌ์์ค์ ํญ์ ์ ์ธ๋๋ค.

๋ฐ๋ผ์ ๋ค์์ ๊ธฐ๋ณธ์ ์ธ ๊ตฌ์กฐ๋ผ๊ณ  ํ  ์ ์๋ค.

```yaml
apiVersion:
kind:
metadata:
spec:
```

- `apiVersion` :  ํด๋น ์ค๋ธ์ ํธ๋ฅผ ์์ฑํ๊ธฐ ์ํด ์ฌ์ฉํ๊ณ  ์๋ ์ฟ ๋ฒ๋คํฐ์ค API ๋ฒ์ (์ง์ํ๋ ์ค๋ธ์ ํธ์ ๋ฒ์ )

- `kind` : ์ค๋ธ์ ํธ์ ์ข๋ฅ๋ก, `kind` ์ ์ข๋ฅ์ ๋ฐ๋ผ ์ง์ํ๋ `apiVersion`์ด ๋ค๋ฅด๋ค.

- `spec` : ์ค๋ธ์ ํธ์ ๋ํด ์ด๋ค ์ํ๋ฅผ ์๋ํ๋์ง(์ค๋ธ์ ํธ์ ๋ํ ์ ์ธ)
  - ์ด๋ค ์ข๋ฅ์ ์ค๋ธ์ ํธ๋ฅผ ์ ์ํ๋๋์ ๋ฐ๋ผ ๋ค๋ฅด๋ค.
  
  - ์ค๋ธ์ ํธ์ ๋ฐ๋ผ `spec`์ ์ ์ธํ์ง ์๋ ๊ฒฝ์ฐ๋ ์์ผ๋ ๊ทนํ ๋๋ฌผ๋ค.
  
- `meta-data` : ์ค๋ธ์ ํธ์ ๋ฉํ๋ฐ์ดํฐ
  - `์ด๋ฆ` ๋ฌธ์์ด, `UID`, ๊ทธ๋ฆฌ๊ณ  ์ ํ์ ์ธ `๋ค์์คํ์ด์ค`๋ฅผ ํฌํจํ์ฌ ์ค๋ธ์ ํธ๋ฅผ ์ ์ผํ๊ฒ ๊ตฌ๋ถ์ง์ด ์ค ๋ฐ์ดํฐ์ด๋ค.

<br>

#### kubectl explain

`ansible docs`์ ์ ์ฌํ๋ฉฐ, **๋ฆฌ์์ค๋ฅผ ์ด๋ป๊ฒ ์ ์ํ๋์ง์ ๋ํ ๋ด์ฉ**์ ํ์ธํ  ์ ์๋ค.

```shell
$ kubectl explain <resource>
```

ํด๋น ์ ๋ณด๋ ์ด ๋ช๋ น์ด๋ก๋ง ํ์ธํ  ์ ์์ผ๋ฉฐ, ํํ์ด์ง์์ ํ์ธํ  ์ ์๋ค

<br>

์์

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

- `Read-Only` ์์ฑ์ ์ฐ๋ฆฌ๊ฐ ์ ์ธํ๋ ๊ฒ์ด ์๋๋ผ(์ ์ธํ  ์ ์๊ณ ), ์ฟ ๋ฒ๋คํฐ์ค๊ฐ ์ฑ์ฐ๋ ํญ๋ชฉ์ด๋ค.

- `meta-data`๋ ๋ด์ฉ์ด ๋ณํ์ง ์์ง๋ง, `spec` ์ ๋ณํ  ์ ์๋ค.

- `-required` ์์ฑ์ ๋ฐ๋์ ์ ์ธํด์ผํ๋ ํญ๋ชฉ์ด๋ค.

<br>

ํ์ ๊ณ์ธต์ด ์๋ ๊ฒฝ์ฐ์๋ ๋ค์๊ณผ ๊ฐ์ด ๊ณ์ธต์ ์ผ๋ก ๋ด๋ ค๊ฐ๋ฉด์ ํ์ธํ  ์ ์๋ค.

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

`--reqursive` ์ต์์ ์ฌ์ฉํ๋ฉด, ์ด๋ฆ๋ง ๊ณ์ธต์ ์ผ๋ก ํ์ธํ  ์ ์๋ค

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

## ์ค๋ธ์ ํธ ๊ด๋ฆฌ

[์ฟ ๋ฒ๋คํฐ์ค ์ค๋ธ์ ํธ ๊ด๋ฆฌ | Kubernetes](https://kubernetes.io/ko/docs/concepts/overview/working-with-objects/object-management/)

**๊ด๋ฆฌ ๊ธฐ๋ฒ 3๊ฐ์ง**

| ๊ด๋ฆฌ๊ธฐ๋ฒ             | ๋์                 | ๊ถ์ฅ ํ๊ฒฝ     | ์ง์ํ๋ ์์์ ์ | ํ์ต ๋์ด๋ |
| -------------------- | -------------------- | ------------- | ------------------ | ----------- |
| ๋ช๋ นํ ์ปค๋งจ๋        | ํ์ฑ ์ค๋ธ์ ํธ        | ๊ฐ๋ฐ ํ๊ฒฝ     | 1+                 | ๋ฎ์        |
| ๋ช๋ นํ ์ค๋ธ์ ํธ ๊ตฌ์ฑ | ๊ฐ๋ณ ํ์ผ            | ํ๋ก๋์ ํ๊ฒฝ | 1                  | ๋ณดํต        |
| ์ ์ธํ ์ค๋ธ์ ํธ ๊ตฌ์ฑ | ํ์ผ์ด ์๋ ๋๋ ํฐ๋ฆฌ | ํ๋ก๋์ ํ๊ฒฝ | 1+                 | ๋์        |

- ๋ช๋ นํ ์ปค๋งจ๋ : `yaml` ํ์ผ์ ์์ฑํ์ง ์๊ณ , `kubectl` ๋ช๋ น์ด๋ก๋ง ๊ด๋ฆฌ(์ฒ๋ฆฌ)ํ๋ ๊ฒ
  - `kubectl create`
  - `kubectl run`
  - `kubectl expose`
  - ๋ณธ ๊ธ์์ ์์ ์งํํ๋ ๊ฒ๋ค์ ๋ช๋ นํ ์ปค๋งจ๋์ด๋ค.
- ๋ช๋ นํ ์ค๋ธ์ ํธ ๊ตฌ์ฑ : (์ ์ฐจํ)  `yaml`์ ์์๋๋ก ํ๋์ฉ ์คํ
  - `kubectl create -f a.yaml`
  - `kubectl apply -f a.yaml`
  - `kubectl replace -f a.yaml`
- ์ ์ธํ ์ค๋ธ์ ํธ ๊ตฌ์ฑ : ํ๋์ด์์`yaml` ํ์ผ์ ๋ชจ์์ ํ๋ฒ์ ์คํ
  - `kubectl create -f resources/`
  - `kubectl apply -f resources/`

<br>

<br>



์ฐธ๊ณ 

https://devbksheen.tistory.com/entry/%EC%BF%A0%EB%B2%84%EB%84%A4%ED%8B%B0%EC%8A%A4-API-%EC%98%A4%EB%B8%8C%EC%A0%9D%ED%8A%B8